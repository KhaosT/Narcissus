//
//  MapViewController.m
//  Narcissus
//
//  Created by Khaos Tian on 8/12/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import "MapViewController.h"
#import "LocationCore.h"

#import <CoreLocation/CoreLocation.h>

@interface MapViewController ()<UIScrollViewDelegate,UIBarPositioningDelegate>{
    UINavigationBar     *_navigationBar;
    UIImageView         *_mapView;
    UIScrollView        *_mapScrollerView;
    
    UIImageView         *_userPin;
    
    NSDictionary        *_currentMapInfo;
    
    NSNumber            *_currentMapNo;
    
    id                  _IndoorLocationDidUpdated;
    id                  _DidRangeBeacons;
    
    UIButton            *_locationFollowUserButton;
    BOOL                _shouldFollowUser;
}

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"map"];
        _shouldFollowUser = YES;
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)configureView
{
    _mapScrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44)];
    _mapScrollerView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    _mapScrollerView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    _mapScrollerView.backgroundColor = [UIColor whiteColor];
    _mapScrollerView.delegate = self;
    _mapScrollerView.maximumZoomScale = 3.0;
    [self.view addSubview:_mapScrollerView];
    _mapView = [[UIImageView alloc]initWithFrame:_mapScrollerView.frame];
    [_mapScrollerView addSubview:_mapView];
    _locationFollowUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _locationFollowUserButton.frame = CGRectMake(15, [UIScreen mainScreen].bounds.size.height - 90, 28, 28);
    UIImage *locationButtonImage = [UIImage imageNamed:@"locationfollowUser"];
    [_locationFollowUserButton setImage:[locationButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.view addSubview:_locationFollowUserButton];
    _navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44)];
    _navigationBar.delegate = self;
    UINavigationItem *topItem = [[UINavigationItem alloc]initWithTitle:@"Map"];
    [_navigationBar setItems:@[topItem]];
    [self.view addSubview:_navigationBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    [_locationFollowUserButton addTarget:self action:@selector(changeLocationFollowMode:) forControlEvents:UIControlEventTouchUpInside];
    NSDictionary *locationInfo = [[LocationCore defaultCore]currentLocation];
    if (locationInfo) {
        [self setupMapWithMajorID:@"1"];
        [self setUserLocation];
    }
    
	// Do any additional setup after loading the view.
}

- (void)setupMapWithMajorID:(NSString *)major
{
    NSBundle *mapInfoBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle]URLForResource:@"IndoorMap_2" withExtension:@"bundle"]];
    NSDictionary *mapInfo = [NSDictionary dictionaryWithContentsOfURL:[mapInfoBundle URLForResource:@"info" withExtension:@"plist"]];
    _currentMapInfo = mapInfo;
    _navigationBar.topItem.title = [_currentMapInfo objectForKey:@"name"];
    UIImage *mapImage = [UIImage imageWithContentsOfFile:[mapInfoBundle pathForResource:[mapInfo objectForKey:@"mapName"] ofType:[mapInfo objectForKey:@"mapType"]]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapScrollerView setContentSize:mapImage.size];
        _mapView.frame = CGRectMake(0, 0, mapImage.size.width, mapImage.size.height);
        [_mapView setImage:mapImage];
    });
    _currentMapNo = [mapInfo objectForKey:@"major"];
}

- (void)changeLocationFollowMode:(id)sender
{
    if (_shouldFollowUser) {
        _shouldFollowUser = NO;
        _locationFollowUserButton.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    }else{
        _shouldFollowUser = YES;
        _locationFollowUserButton.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _IndoorLocationDidUpdated = [[NSNotificationCenter defaultCenter]addObserverForName:@"IndoorLocationDidUpdated" object:nil queue:[[NSOperationQueue alloc]init] usingBlock:^(NSNotification *note) {
        NSDictionary *locationInfo = note.object;
        NSBundle *mapInfoBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle]URLForResource:@"IndoorMap_2" withExtension:@"bundle"]];
        NSDictionary *mapInfo = [NSDictionary dictionaryWithContentsOfURL:[mapInfoBundle URLForResource:@"info" withExtension:@"plist"]];
        _currentMapInfo = mapInfo;
        if (_currentMapNo) {
            if (![[locationInfo objectForKey:@"major"]isEqualToNumber:_currentMapNo]) {
                [self setupMapWithMajorID:[[locationInfo objectForKey:@"major"] stringValue]];
            }
        }else{
            [self setupMapWithMajorID:[[locationInfo objectForKey:@"major"] stringValue]];
        }
    }];
    
    _DidRangeBeacons = [[NSNotificationCenter defaultCenter]addObserverForName:@"DidRangeBeacons" object:nil queue:[[NSOperationQueue alloc]init] usingBlock:^(NSNotification *note) {
        [self setUserLocation];
    }];
}

- (void)setUserLocation
{
    if (!_userPin) {
        UIImage *locationPinImage = [UIImage imageNamed:@"locationPin"];
        _userPin = [[UIImageView alloc]initWithImage:[locationPinImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _userPin.hidden = YES;
        [_mapView addSubview:_userPin];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.33 animations:^{
            _userPin.hidden = NO;
            _userPin.center = [self calculateUserLocation];
            if (_shouldFollowUser) {
                [_mapScrollerView zoomToRect:CGRectMake(_userPin.center.x - 100.0, _userPin.center.y - 100.0, 200, 200) animated:YES];
            }
        }];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:_IndoorLocationDidUpdated];
    [[NSNotificationCenter defaultCenter]removeObserver:_DidRangeBeacons];
}

- (CGPoint)calculateUserLocation
{
    NSArray *nearbyBeacons = [[[LocationCore defaultCore]nearbyBeacons]copy];
    /*if (nearbyBeacons.count > 2) {
        CLBeacon *nearestBeacon = [nearbyBeacons objectAtIndex:0];
        CLBeacon *secondBeacon = [nearbyBeacons objectAtIndex:1];
        CLBeacon *thirdBeacon = [nearbyBeacons objectAtIndex:2];
        
        float distanceTo1 = nearestBeacon.accuracy;
        float distanceTo2 = secondBeacon.accuracy;
        float distanceTo3 = thirdBeacon.accuracy;
        
        CGPoint firstPoint = CGPointMake([[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[nearestBeacon.minor stringValue]]objectForKey:@"x"] floatValue], [[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[nearestBeacon.minor stringValue]]objectForKey:@"y"] floatValue]);
        
        CGPoint secondPoint = CGPointMake([[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[secondBeacon.minor stringValue]]objectForKey:@"x"] floatValue], [[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[secondBeacon.minor stringValue]]objectForKey:@"y"] floatValue]);
        
        CGPoint thirdPoint = CGPointMake([[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[thirdBeacon.minor stringValue]]objectForKey:@"x"] floatValue], [[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[thirdBeacon.minor stringValue]]objectForKey:@"y"] floatValue]);
        
        CGFloat b1Tob2 = [self distanceBetweenPoint1:firstPoint andPoint2:secondPoint];
        CGFloat b2Tob3 = [self distanceBetweenPoint1:secondPoint andPoint2:thirdPoint];
        CGFloat b1Tob3 = [self distanceBetweenPoint1:firstPoint andPoint2:thirdPoint];
        
        CGPoint centerofThreeBeacons = CGPointMake(((firstPoint.x*b2Tob3 + secondPoint.x * b1Tob3 + thirdPoint.x * b1Tob2)/(b1Tob2+b2Tob3+b1Tob3)), ((firstPoint.y*b2Tob3 + secondPoint.y * b1Tob3 + thirdPoint.y * b1Tob2)/(b1Tob2+b2Tob3+b1Tob3)));
        
        CGPoint diff = [self diffBetweenPoint1:centerofThreeBeacons andPoint2:firstPoint];
        
        CGFloat distanceNearest = [self distanceBetweenPoint1:firstPoint andPoint2:centerofThreeBeacons];
        
        CGFloat ratio = distanceTo1 * 10000;
        
        CGFloat fix = MIN(distanceNearest/ratio,1.0);
        
        CGPoint userCenter = CGPointMake(centerofThreeBeacons.x + (diff.x * fix), centerofThreeBeacons.y + (diff.y * fix));
        
        return userCenter;
    }else{
        CLBeacon *nearestBeacon = [nearbyBeacons objectAtIndex:0];
        CGPoint firstPoint = CGPointMake([[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[nearestBeacon.minor stringValue]]objectForKey:@"x"] floatValue], [[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[nearestBeacon.minor stringValue]]objectForKey:@"y"] floatValue]);

        return firstPoint;
    }*/
    CLBeacon *nearestBeacon = [nearbyBeacons objectAtIndex:0];
    CGPoint firstPoint = CGPointMake([[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[nearestBeacon.minor stringValue]]objectForKey:@"x"] floatValue], [[[[_currentMapInfo objectForKey:@"beacons"] objectForKey:[nearestBeacon.minor stringValue]]objectForKey:@"y"] floatValue]);
    
    return firstPoint;
}

- (CGPoint)diffBetweenPoint1:(CGPoint)p1 andPoint2:(CGPoint)p2
{
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    CGPoint diff = CGPointMake(xDist, yDist);
    return diff;
}

- (CGFloat)distanceBetweenPoint1:(CGPoint)p1 andPoint2:(CGPoint)p2
{
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _mapView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
