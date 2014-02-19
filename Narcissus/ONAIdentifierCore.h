//
//  ONAIdentifierCore.h
//  Narcissus
//
//  Created by Khaos Tian on 2/10/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SETUP_SERVICE_UUID @"F7C1C89B-F3BC-43B0-8FC0-19C5D5251DCE"
#define SETUP_CHARACTERISTIC_UUID @"282FDA3C-9957-4821-95FE-9F8C4DB81E18"

@interface ONAIdentifierCore : NSObject

@property (nonatomic,readonly) NSString *name;
@property (nonatomic,readonly) NSString *userToken;
@property (nonatomic,readonly) UIImage *userAvatar;
@property (nonatomic,readonly) BOOL isAuth;

+ (ONAIdentifierCore *)sharedCore;

- (void)logout;

@end
