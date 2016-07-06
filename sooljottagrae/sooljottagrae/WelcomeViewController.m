//
//  WelcomeViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SettingViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *profileImage = [UIImage imageNamed:@"Profile1"];
    
    [self.profileImageView setImage:profileImage];
    
    [self.profileNameLabel setText:self.profileNmae];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)exploreBtn:(id)sender {
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
    SettingViewController *settingVC = [stb instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    settingVC.profileName = self.profileNmae;
    
    [settingVC setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self addChildViewController:settingVC];
    [self.view addSubview:settingVC.view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
