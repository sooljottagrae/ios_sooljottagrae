//
//  ViewController.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 4..
//  Copyright © 2016년 alcoholic. All rights reserved.
//#90c4fd    #fab0bf    #b35d80
//#a08fce    #71a2e4

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIView *loginView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //로그인뷰 배경화면 투명화
    UIView *loginViewBgColor = [[UIView alloc]initWithFrame:self.loginView.bounds];
    loginViewBgColor.backgroundColor = [UIColor colorWithRed:254 green:254 blue:254 alpha:0.7];
    
    
    [self.loginView addSubview:loginViewBgColor];
    
    //Custom Facebook Login Button
    UIButton *myLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    myLoginButton.frame=CGRectMake(self.loginView.frame.size.width/2-(195/2) ,self.loginView.frame.size.height-74, 195,38);
    [myLoginButton setBackgroundImage:[UIImage imageNamed:@"Facebook-login"] forState:UIControlStateNormal];
    

    // Handle clicks on the button
    [myLoginButton addTarget:self
                      action:@selector(loginButtonClicked)
            forControlEvents:UIControlEventTouchUpInside];
    
    // Add the button to the view
    [self.loginView addSubview:myLoginButton];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//facebook login action
-(void)loginButtonClicked
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"email"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    NSLog(@"Process error");
                                } else if (result.isCancelled) {
                                    NSLog(@"Cancelled");
                                } else {
                                    NSLog(@"Logged in");
                                   
                                    if ([result.grantedPermissions containsObject:@"email"]) {
                                        if ([FBSDKAccessToken currentAccessToken]) {
                                            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                                            [parameters setValue:@"id,name,email" forKey:@"fields"];
                                            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                                             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                 if (!error) {
                                                     NSLog(@"fetched user:%@", result);
                                                 }
                                             }];
                                        }
                                    }
                                }
                            }];
}

-(void) loginSession:(id)result{
   
    
}
@end
