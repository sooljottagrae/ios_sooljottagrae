//
//  SignInViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 4..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "SignInViewController.h"
#import "WelcomeViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameTextField setPlaceholder:@"영어, _를 포함한 12자리 이하"];
    [self.emailTextField setPlaceholder:@"가입 인증 시 사용할 이메일"];
    [self.pwdTextField setPlaceholder:@"비밀번호"];
    [self.pwdConfirmTextField setPlaceholder:@"비밀번호 확인"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signInBtn:(id)sender {
    self.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys: self.nameTextField.text, @"name", self.emailTextField.text, @"email", self.pwdTextField.text, @"password", nil];
    
    NSLog(@"%@", self.userInfo);
    
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
    
    WelcomeViewController *welcomeVC = [stb instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    
    welcomeVC.profileNmae = self.nameTextField.text;
    
    //[welcomeVC.profileNameLabel setText:self.nameTextField.text];
    
    [self presentViewController:welcomeVC animated:YES completion:nil];
    
}
- (IBAction)cancelBtn:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
