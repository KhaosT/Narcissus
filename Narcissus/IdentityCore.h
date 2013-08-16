//
//  IdentityCore.h
//  Narcissus
//
//  Created by Khaos Tian on 8/12/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdentityCore : NSObject

+ (IdentityCore *)defaultCore;



- (NSString *)currentOTPString;

@end
