//
//  ONASetupViewController.m
//  Narcissus
//
//  Created by Khaos Tian on 2/10/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import "ONASetupViewController.h"

@interface ONASetupViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *intoTextLabel;

@end

@implementation ONASetupViewController

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
    [_loadingIndicator startAnimating];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSetUpView) name:@"DidUpdateAuthInformation" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateText) name:@"WillStartAuthProcess" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)updateText
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _intoTextLabel.text = @"Processing...";
    });
}

- (void)dismissSetUpView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
