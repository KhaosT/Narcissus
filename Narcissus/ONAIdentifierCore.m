//
//  ONAIdentifierCore.m
//  Narcissus
//
//  Created by Khaos Tian on 2/10/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import "ONAIdentifierCore.h"
#import "AFNetworking.h"
#import "ONALocationCore.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ONAIdentifierCore ()<CBPeripheralManagerDelegate>{
    CBPeripheralManager *_manager;
    
    CBMutableService    *_controlService;
    CBMutableCharacteristic *_controlCharacteristic;
}

@property (nonatomic,readwrite) NSString *name;
@property (nonatomic,readwrite) NSString *userToken;
@property (nonatomic,readwrite) UIImage *userAvatar;
@property (nonatomic,readwrite) BOOL isAuth;

@end

@implementation ONAIdentifierCore

+ (ONAIdentifierCore *)sharedCore
{
    static ONAIdentifierCore *core = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        core = [[ONAIdentifierCore alloc]init];
    });
    return core;
}

- (ONAIdentifierCore *)init
{
    if (self = [super init]) {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isAuth"]) {
            [ONALocationCore defaultCore];
            _isAuth = YES;
            _name = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
            _userToken = [[NSUserDefaults standardUserDefaults]stringForKey:@"token"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"avatar.jpg"];
            _userAvatar = [[UIImage alloc]initWithContentsOfFile:filePath];
        }else{
            _manager = [[CBPeripheralManager alloc]initWithDelegate:self queue:dispatch_queue_create("peripheralQueue", DISPATCH_QUEUE_SERIAL)];
            _isAuth = NO;
        }
    }
    return self;
}

- (void)logout
{
    _name = nil;
    _userAvatar = nil;
    _userToken = nil;
    _isAuth = NO;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"token"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isAuth"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"avatar.jpg"];
    [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DidUpdateAuthInformation" object:nil];
}

- (void)authWithToken:(NSString *)token
{
    _userToken = token;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"WillStartAuthProcess" object:nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": token};
    [manager POST:@"NULL" parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Success: %@", responseObject);
              if ([responseObject objectForKey:@"name"]) {
                  _name = [responseObject objectForKey:@"name"];
              }
              _isAuth = YES;
              [[NSUserDefaults standardUserDefaults]setObject:_userToken forKey:@"token"];
              [[NSUserDefaults standardUserDefaults]setObject:_name forKey:@"name"];
              [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isAuth"];
              [[NSUserDefaults standardUserDefaults]synchronize];
              NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"NULL",token]];
              [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
                  if (!err) {
                      _userAvatar = [UIImage imageWithData:data];
                      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                      NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"avatar.jpg"];
                      
                      [UIImageJPEGRepresentation(_userAvatar, 1.0) writeToFile:filePath atomically:YES];
                      [[NSNotificationCenter defaultCenter]postNotificationName:@"DidUpdateAuthInformation" object:nil];
                  }else{
                      NSLog(@"Error:%@",err);
                  }
              }];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error:%@",error);
    }];
}

- (void)prepareAdv
{
    _controlService = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:SETUP_SERVICE_UUID] primary:YES];
    _controlCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:SETUP_CHARACTERISTIC_UUID] properties:(CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify) value:nil permissions:(CBAttributePermissionsReadable|CBAttributePermissionsWriteable)];
    _controlService.characteristics = @[_controlCharacteristic];
    [_manager addService:_controlService];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self prepareAdv];
            break;
            
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (!error) {
        [_manager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:SETUP_SERVICE_UUID]]}];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSMutableData *data = [[NSMutableData alloc]init];
    for (CBATTRequest *aReq in requests){
        [data appendData:aReq.value];
        [peripheral respondToRequest:aReq withResult:CBATTErrorSuccess];
    }
    _userToken = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [self authWithToken:_userToken];
}

@end
