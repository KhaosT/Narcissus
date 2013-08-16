//
//  MeViewController.m
//  Narcissus
//
//  Created by Khaos Tian on 8/12/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import "MeViewController.h"

#import "IdentityCore.h"
#import "UserManager.h"
#import "UIImageView+AFNetworking.h"

@interface MeViewController (){
    
}

@end

@implementation MeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Me", @"Me");
        self.tabBarItem.image = [UIImage imageNamed:@"avatar"];
        // Custom initialization
    }
    return self;
}

/*- (void)loadView
{
    self.view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.view.backgroundColor = [UIColor whiteColor];
    AvatarView *useravatar = [[AvatarView alloc]initWithFrame:CGRectMake(0, 0, 166, 166)];
    useravatar.backgroundColor = [UIColor clearColor];
    useravatar.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:useravatar];
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_avatarView setImageWithURL:[NSURL URLWithString:[[UserManager defaultManager]userAvatarURL]] placeholderImage:[UIImage imageNamed:@"avatarPlaceHolder"]];
    UIInterpolatingMotionEffect *mx = [[UIInterpolatingMotionEffect alloc]
                                       initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    mx.maximumRelativeValue = @39.0;
    mx.minimumRelativeValue = @-39.0;
    
    UIInterpolatingMotionEffect *mx2 = [[UIInterpolatingMotionEffect alloc]
                                        initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    mx2.maximumRelativeValue = @39.0;
    mx2.minimumRelativeValue = @-39.0;
    
    [_avatarView addMotionEffect:mx];
    [_avatarView addMotionEffect:mx2];
    [_userName addMotionEffect:mx];
    [_userName addMotionEffect:mx2];
    _userName.text = [[UserManager defaultManager]userName];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showOTPView:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"One Time Password" message:[[IdentityCore defaultCore]currentOTPString] delegate:Nil cancelButtonTitle:@"Done" otherButtonTitles: nil];
    [alert show];
}

@end
