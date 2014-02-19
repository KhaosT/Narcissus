//
//  LocationCore.h
//  Narcissus
//
//  Created by Khaos Tian on 8/12/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONALocationCore : NSObject

+ (ONALocationCore *)defaultCore;

- (NSDictionary *)currentLocation;
- (NSArray *)nearbyBeacons;

@end
