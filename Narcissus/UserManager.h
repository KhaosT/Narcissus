//
//  UserManager.h
//  Narcissus
//
//  Created by Khaos Tian on 8/14/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

@property (nonatomic, readonly) BOOL    isAuthed;

+ (UserManager *)defaultManager;

- (void)reinit;

- (void)loginWithID:(NSString *)userID Password:(NSString *)password success:(void (^)(NSDictionary *userInfo))successHandle fail:(void (^)(NSDictionary *error))failHandle;

- (NSString *)userUUID;
- (NSString *)userOTPSecret;

- (UIImage *)userAvatar;
- (NSString *)userName;
- (NSString *)userAvatarURL;

@end
