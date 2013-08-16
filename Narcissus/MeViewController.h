//
//  MeViewController.h
//  Narcissus
//
//  Created by Khaos Tian on 8/12/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AvatarView;

@interface MeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *OTPButton;

- (IBAction)showOTPView:(id)sender;

@end
