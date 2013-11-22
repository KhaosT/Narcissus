//
//  LocationCore.m
//  Narcissus
//
//  Created by Khaos Tian on 8/12/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "LocationCore.h"
#import "UserManager.h"

#define BEACON_UUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"

@interface LocationCore()<CLLocationManagerDelegate>{
    CLLocationManager   *_locationManager;
    
    CLBeaconRegion      *_beaconRegion;
    
    NSArray             *_nearbyBeacons;
    
    NSNumber            *_lastMajor;
    NSNumber            *_lastMinor;
}

@end

@implementation LocationCore

+ (LocationCore *)defaultCore
{
    static LocationCore *locationCore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationCore = [[self alloc]init];
    });
    return locationCore;
}

- (id)init
{
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:[[NSUUID alloc]initWithUUIDString:BEACON_UUID] identifier:@"Indoor"];
        _beaconRegion.notifyOnEntry = YES;
        _beaconRegion.notifyOnExit = YES;
        _beaconRegion.notifyEntryStateOnDisplay = NO;
        
#warning Workaround for Background
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
        [_locationManager startUpdatingLocation];
        
        [_locationManager startMonitoringForRegion:_beaconRegion];
        [_locationManager requestStateForRegion:_beaconRegion];
    }
    return self;
}

- (NSDictionary *)currentLocation
{
    if (_lastMajor) {
        NSDictionary *locationInfo = @{@"major": _lastMajor,@"minor" : _lastMinor};
        return locationInfo;
    }
    return nil;
}

- (NSArray *)nearbyBeacons
{
    return _nearbyBeacons;
}

- (void)checkInWithMajor:(NSNumber *)major Minor:(NSNumber *)minor
{
    /*NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"",[[UserManager defaultManager]userUUID],major,minor]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    }];*/
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([region isEqual:_beaconRegion]) {
        NSLog(@"ALCL:%@,%d",region,state);
        if (state == CLRegionStateInside || state == CLRegionStateUnknown) {
            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
        }
        if (state == CLRegionStateOutside) {
            [_locationManager stopMonitoringForRegion:_beaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"Range:%@",beacons);
    NSArray *knownBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity > %d", CLProximityUnknown]];
    _nearbyBeacons = [knownBeacons copy];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidRangeBeacons" object:nil];
    CLBeacon *nearestBeacon = [knownBeacons firstObject];
    NSLog(@"Pro:%f",nearestBeacon.accuracy);
    if (![_lastMajor isEqualToNumber:nearestBeacon.major]||![_lastMinor isEqualToNumber:nearestBeacon.minor]) {
        if (![_lastMajor isEqualToNumber:nearestBeacon.major]) {
            _lastMajor = [nearestBeacon.major copy];
            NSLog(@"MajorChanged");
        }
        if (![_lastMinor isEqualToNumber:nearestBeacon.minor]) {
            _lastMinor = [nearestBeacon.minor copy];
            NSLog(@"MinorChanged");
        }
        if (_lastMajor && _lastMinor) {
            NSDictionary *locationInfo = @{@"major": _lastMajor,@"minor" : _lastMinor};
            [[NSNotificationCenter defaultCenter]postNotificationName:@"IndoorLocationDidUpdated" object:locationInfo];
            [self checkInWithMajor:_lastMajor Minor:_lastMinor];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Error:%@",[error description]);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [manager startRangingBeaconsInRegion:_beaconRegion];
    NSLog(@"Enter%@", region);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [manager stopMonitoringForRegion:_beaconRegion];
    [self checkInWithMajor:@0 Minor:@0];
    NSLog(@"Exit %@", region);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"ErrorMonitoring:%@",[error description]);
}

@end
