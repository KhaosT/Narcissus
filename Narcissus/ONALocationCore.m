//
//  LocationCore.m
//  Narcissus
//
//  Created by Khaos Tian on 8/12/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ONALocationCore.h"
#import "ONAIdentifierCore.h"
#import "AFNetworking.h"

#define BEACON_UUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"

@interface ONALocationCore()<CLLocationManagerDelegate>{
    CLLocationManager   *_locationManager;
    
    CLBeaconRegion      *_beaconRegion;
    
    NSArray             *_nearbyBeacons;
    
    NSNumber            *_lastMajor;
    NSNumber            *_lastMinor;
}

@end

@implementation ONALocationCore

+ (ONALocationCore *)defaultCore
{
    static ONALocationCore *locationCore = nil;
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
    if ([ONAIdentifierCore sharedCore].isAuth) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"token":[ONAIdentifierCore sharedCore].userToken,@"major": major,@"minor": minor};
        [manager POST:@"NULL" parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Success: %@", responseObject);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error:%@",error);
              }];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([region isEqual:_beaconRegion]) {
        NSLog(@"ALCL:%@,%ld",region,state);
        if (state == CLRegionStateInside || CLRegionStateUnknown) {
            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
        }
        if (state == CLRegionStateOutside) {
            NSLog(@"Stoped");
            [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"Range:%@",beacons);
    NSArray *knownBeacons = [beacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity > %d", CLProximityUnknown]];
    _nearbyBeacons = knownBeacons;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidRangeBeacons" object:nil];
    CLBeacon *nearestBeacon = [knownBeacons firstObject];
    NSLog(@"Pro:%f",nearestBeacon.accuracy);
    if (nearestBeacon) {
        if (![_lastMajor isEqualToNumber:nearestBeacon.major]||![_lastMinor isEqualToNumber:nearestBeacon.minor]) {
            if (![_lastMajor isEqualToNumber:nearestBeacon.major]) {
                _lastMajor = nearestBeacon.major;
                NSLog(@"MajorChanged");
            }
            if (![_lastMinor isEqualToNumber:nearestBeacon.minor]) {
                _lastMinor = nearestBeacon.minor;
                NSLog(@"MinorChanged");
            }
            if (_lastMajor && _lastMinor) {
                NSDictionary *locationInfo = @{@"major": _lastMajor,@"minor" : _lastMinor};
                [[NSNotificationCenter defaultCenter]postNotificationName:@"IndoorLocationDidUpdated" object:locationInfo];
                [self checkInWithMajor:_lastMajor Minor:_lastMinor];
            }
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
    [manager stopRangingBeaconsInRegion:_beaconRegion];
    [self checkInWithMajor:@0 Minor:@0];
    NSLog(@"Exit %@", region);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"ErrorMonitoring:%@",[error description]);
}

@end
