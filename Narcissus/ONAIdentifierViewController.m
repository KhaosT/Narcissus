//
//  ONAIdentifierViewController.m
//  Narcissus
//
//  Created by Khaos Tian on 2/10/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import "ONAIdentifierViewController.h"
#import "ONAIdentifierCore.h"
#import "ONASetupViewController.h"
#import "ONALocationCore.h"
#import "MapViewController.h"

@interface ONAIdentifierViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

- (IBAction)showMap:(id)sender;
- (IBAction)logout:(id)sender;

@end

@implementation ONAIdentifierViewController

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
    [self updateViewInfo];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateViewInfo) name:@"DidUpdateAuthInformation" object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![[ONAIdentifierCore sharedCore]isAuth]) {
        ONASetupViewController *setupVC = [[ONASetupViewController alloc]initWithNibName:@"ONASetupViewController" bundle:nil];
        
        [self presentViewController:setupVC animated:YES completion:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{

}

- (void)updateViewInfo
{
    [ONALocationCore defaultCore];
    dispatch_async(dispatch_get_main_queue(), ^{
        _avatarImageView.image = [ONAIdentifierCore sharedCore].userAvatar;
        _nameLabel.text = [ONAIdentifierCore sharedCore].name;
    });
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

- (IBAction)showMap:(id)sender {
    MapViewController *mapVC = [[MapViewController alloc]init];
    [self presentViewController:mapVC animated:YES completion:nil];
}

- (IBAction)logout:(id)sender {
    [[ONAIdentifierCore sharedCore]logout];
    ONASetupViewController *setupVC = [[ONASetupViewController alloc]initWithNibName:@"ONASetupViewController" bundle:nil];
    [self presentViewController:setupVC animated:YES completion:nil];
}
@end
