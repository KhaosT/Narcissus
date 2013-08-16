//
//  SetupViewController.m
//  Narcissus
//
//  Created by Khaos Tian on 8/14/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import "SetupViewController.h"
#import "UserManager.h"

@interface SetupViewController ()

@end

@implementation SetupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [[UserManager defaultManager]loginWithID:_usernameField.text Password:_passwordField.text success:^(NSDictionary *userInfo) {
        NSLog(@"%@",userInfo);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DidLogin" object:nil];
    } fail:^(NSDictionary *error) {
        NSLog(@"%@",error);
    }];
}

@end
