//
//  UserManager.m
//  Narcissus
//
//  Created by Khaos Tian on 8/14/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import "UserManager.h"
#import "Security.h"

@interface UserManager(){
    NSString            *_userUUID;
    NSString            *_userName;
    NSString            *_OTPSec;
    NSString            *_userAvatarImageUrl;
}

@end

@implementation UserManager

+ (UserManager *)defaultManager
{
    static UserManager *userManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userManager = [[self alloc]init];
    });
    return userManager;
}

- (id)init
{
    if (self = [super init]) {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isLogin"]) {
            _isAuthed = YES;
            _userUUID = [[NSUserDefaults standardUserDefaults]stringForKey:@"UUID"];
            _userName = [[NSUserDefaults standardUserDefaults]stringForKey:@"userName"];
            _OTPSec = [Security getContentForName:@"OTPSec"];
            _userAvatarImageUrl = [[NSUserDefaults standardUserDefaults]stringForKey:@"userAvatar"];
        }

    }
    return self;
}

- (void)loginWithID:(NSString *)userID Password:(NSString *)password success:(void (^)(NSDictionary *userInfo))successHandle fail:(void (^)(NSDictionary *error))failHandle
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.oltica.org/v1/narcissus/login/%@/%@",userID,password]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *resp, NSData *data, NSError *err) {
        NSDictionary *returnJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([[returnJson objectForKey:@"state"]isEqualToString:@"Success"]) {
            _userUUID = [returnJson objectForKey:@"UUID"];
            _OTPSec = [returnJson objectForKey:@"OTPSec"];
            _userName = [returnJson objectForKey:@"name"];
            _userAvatarImageUrl = [returnJson objectForKey:@"avatar"];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isLogin"];
            [[NSUserDefaults standardUserDefaults]setObject:_userUUID forKey:@"UUID"];
            [[NSUserDefaults standardUserDefaults]setObject:_userName forKey:@"userName"];
            [[NSUserDefaults standardUserDefaults]setObject:_userAvatarImageUrl forKey:@"userAvatar"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [Security setName:@"OTPSec" WithContent:_OTPSec];
            successHandle(returnJson);
        }else{
            failHandle(returnJson);
        }
    }];
}

- (NSString *)userUUID
{
    return _userUUID;
}

- (NSString *)userOTPSecret
{
#warning Read Secret from Keychain
    return _OTPSec;
}

- (UIImage *)userAvatar
{
    UIImage *avatar = [UIImage imageNamed:@"avatar-n.jpg"];
    return avatar;
}

- (NSString *)userName
{
    return _userName;
}

- (NSString *)userAvatarURL
{
    return _userAvatarImageUrl;
}

@end
