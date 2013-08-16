//
//  IdentityCore.m
//  Narcissus
//
//  Created by Khaos Tian on 8/12/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import "IdentityCore.h"
#import "AeroGearOTP.h"
#import "UserManager.h"

#import "DDLog.h"
#import "DDFileLogger.h"

#define IDENTITY_SERVICE_UUID @"DDDD28AD-53BC-4B74-83B0-68F0E3C21FC2"
#define IDENTITY_CHAR_1_UUID @"C57314FB-8BA1-4751-BB90-4911E7BF8D31"
#define IDENTITY_TOTP_CHAR_UUID @"927C330A-0CB4-4FB6-87F1-E9C4F4CD8676"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface  IdentityCore()<CBPeripheralDelegate,CBPeripheralManagerDelegate>{
    CBPeripheralManager         *_identityManager;
    NSDictionary                *_userIdentity;
    AGTotp                      *_generator;
    
    CBMutableService            *_identityService;
    CBMutableCharacteristic     *_identityCharacteristic_1;
    CBMutableCharacteristic     *_identityCharacteristic_TOTP;
}

@end

@implementation IdentityCore

+ (IdentityCore *)defaultCore
{
    static IdentityCore *identityCore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        identityCore = [[self alloc]init];
    });
    return identityCore;
}

- (id)init
{
    if (self = [super init]) {
        _userIdentity = @{@"UUID": [[UserManager defaultManager]userUUID]};
        
        NSString *secret = [[UserManager defaultManager]userOTPSecret];
        
        NSData *secretData = [AGBase32 base32Decode:secret];
        _generator = [[AGTotp alloc]initWithSecret:secretData];

        _identityManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:@{CBPeripheralManagerOptionRestoreIdentifierKey: @"Oltica-Identity"}];
        DDLogVerbose(@"Init");
    }
    return self;
}

- (NSString *)currentOTPString
{
    return [_generator now];
}

- (void)prepareForAdvertising
{
    DDLogVerbose(@"PrepareForAdvertising");

    if (!_identityService) {
        DDLogVerbose(@"NonService");
        _identityService = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:IDENTITY_SERVICE_UUID] primary:YES];
        _identityCharacteristic_1 = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:IDENTITY_CHAR_1_UUID] properties:CBCharacteristicPropertyRead value:[NSJSONSerialization dataWithJSONObject:_userIdentity options:0 error:nil] permissions:CBAttributePermissionsReadable];
        _identityCharacteristic_TOTP = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:IDENTITY_TOTP_CHAR_UUID] properties:(CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite) value:nil permissions:(CBAttributePermissionsReadable|CBAttributePermissionsWriteable)];
        _identityService.characteristics = @[_identityCharacteristic_1,_identityCharacteristic_TOTP];
        [_identityManager addService:_identityService];
    }
}

#pragma mark - CBPeripheralDelegate
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    NSLog(@"%@",dict);
    DDLogVerbose(@"RestoreWithState:%@",dict);
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self prepareForAdvertising];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Added");
    NSDictionary *advertisingData = @{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:IDENTITY_SERVICE_UUID]]};
    [peripheral startAdvertising:advertisingData];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    DDLogVerbose(@"ReadRequest");
    if ([request.characteristic isEqual:_identityCharacteristic_TOTP]) {
        NSString *totpstring = [_generator now];
        DDLogVerbose(@"ReadRequestIsTOTP:%@",totpstring);
        NSData *totpdata= [totpstring dataUsingEncoding:NSUTF8StringEncoding];
        request.value = totpdata;
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

@end
