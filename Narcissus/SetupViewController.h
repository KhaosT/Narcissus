//
//  SetupViewController.h
//  Narcissus
//
//  Created by Khaos Tian on 8/14/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)login:(id)sender;

@end
