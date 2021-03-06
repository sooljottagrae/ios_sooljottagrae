//
//  SignInViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 4..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "SignInViewController.h"
#import "WelcomeViewController.h"
#import "RequestObject.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameTextField setPlaceholder:@"영어, _를 포함한 12자리 이하"];
    [self.emailTextField setPlaceholder:@"가입 인증 시 사용할 이메일"];
    [self.pwdTextField setPlaceholder:@"비밀번호"];
    [self.pwdConfirmTextField setPlaceholder:@"비밀번호 확인"];
    
    UITapGestureRecognizer *tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapped:)];
    //tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:tapGesture];
    
}

- (void) gestureTapped:(UIGestureRecognizer *)sender {
    NSLog(@"Tapped");
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signInBtn:(id)sender {
    
    self.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys: self.nameTextField.text, @"nickname", self.emailTextField.text, @"email", self.pwdTextField.text, @"password", self.pwdTextField.text, @"password2",nil];
    
    NSLog(@"%@", self.userInfo);
    
//    [[RequestObject sharedInstance] sendToServer:@"/api/users/signup/"
//                                      parameters:self.userInfo
//                                         success:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                             NSLog(@"%@",responseObject);
//                                         } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                             NSLog(@"%@",responseObject[@"email"]);
//                                         }];
    
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
