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
    
    self.profileImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.profileImageView.layer.borderWidth = 20.0;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2;
    self.profileImageView.layer.masksToBounds = YES;
    
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
    
    [self addChildViewController:settingVC];
    //[settingVC addBlurView];
    [self.view addSubview:settingVC.view];
    
//    settingVC.menuView.frame = CGRectMake(-self.view.frame.size.width*0.35, 0, self.view.frame.size.width*0.35, self.view.frame.size.height);
    
    /*
    [UIView transitionWithView:self.view duration:10
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^ {
                        settingVC.menuView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                        [self.view addSubview:settingVC.view];
                    }
                    completion:nil];
    
    [UIView animateWithDuration:5
     
                     animations:^ {
                         settingVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         settingVC.menuView.frame = CGRectMake(0, 0, self.view.frame.size.width*0.35, self.view.frame.size.height);
                         
                     }
                     completion:nil];
     */

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
