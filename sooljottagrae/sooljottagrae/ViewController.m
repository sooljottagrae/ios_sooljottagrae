//
//  ViewController.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 4..
//  Copyright © 2016년 alcoholic. All rights reserved.
//#90c4fd    #fab0bf    #b35d80
//#a08fce    #71a2e4

#import "ViewController.h"
#import "RequestObject.h"
#import "MainViewController.h"
#import "SignInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <QuartzCore/CALayer.h>

@interface ViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *loginView;           //로그인뷰
@property (strong, nonatomic) IBOutlet UILabel *loginTitle;         //로그인타이틀
@property (strong, nonatomic) IBOutlet UITextField *email_ID;       //이메일
@property (strong, nonatomic) IBOutlet UITextField *password;       //패스워드
@property (strong, nonatomic) IBOutlet UIButton *loginButton;       //로그인버튼
@property (strong, nonatomic) IBOutlet UILabel *divTitle;           //or Title
@property (strong, nonatomic) IBOutlet UIButton *facebookLogin;     //페이스북 로그인 버튼
@property (strong, nonatomic) IBOutlet UIView *line;
@property (strong, nonatomic) IBOutlet UIButton *forgotPassword;
@property (strong, nonatomic) IBOutlet UIButton *signIn;

@property (strong, nonatomic) UIView *loginViewBgColor;             //로그인뷰 배경화면


@property (strong, nonatomic) UITextField *targetTextField;         //유형틀린 필드

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //뷰생성에 관련된 함수
    [self createView];
    
    //로그인성공시 처리
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(verifiedUser)
                                                 name:LoginSuccess
                                               object:nil];
    
    
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"LOGIN"] == YES){
        [self verifiedUser];
    }
}


-(void) createView{
    
    self.loginView.backgroundColor = [UIColor clearColor];
    
    //로그인뷰 배경화면 투명화
    self.loginViewBgColor = [[UIView alloc]init];
    self.loginViewBgColor.frame = self.loginView.bounds;
    self.loginViewBgColor.backgroundColor = UIColorFromRGB(0xFFFFFF, 0.94);
    self.loginViewBgColor.layer.cornerRadius = 10.0f;
    self.loginViewBgColor.layer.masksToBounds = YES;
    
    [self.loginView addSubview:self.loginViewBgColor];
    
    
    [self.loginView addSubview:self.loginTitle];
    [self.loginView addSubview:self.email_ID];
    [self.loginView addSubview:self.password];
    
    
    
    self.loginButton.layer.cornerRadius = 3.0f;
    self.loginButton.layer.masksToBounds = YES;
    [self.loginView addSubview:self.loginButton];
    
    
    [self.loginView addSubview:self.divTitle];
    
    
    // Handle clicks on the button
    [self.facebookLogin addTarget:self
                           action:@selector(loginFacebookButtonClicked)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.loginView addSubview:self.facebookLogin];
    
    [self.loginView addSubview:self.line];
    [self.loginView addSubview:self.forgotPassword];
    [self.loginView addSubview:self.signIn];
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//로그인 로직
/*******************************************
 * 서버에서 전송받는 값에 따라서 처리한다.
 * 틀릴경우)
 *  - 이미 있는 고객 (비밀번호 여부 묻기 )
 *  - 없는 고객 알림창후 회원가입으로 유도
 * 맞을 경우)
 *  - 값을 전달 받을 것을 가지고 로그인 여부 파악
 *******************************************/
-(IBAction)loginButtonAction:(UIButton *)sender{
    
    if(![self checkLoginParameter]){
        return;
    }
    
    //[[RequestObject sharedInstance] loginID:self.email_ID.text passwd:self.password.text];
    [self verifiedUser];
}

-(BOOL) checkLoginParameter{
    
    NSString *string = self.email_ID.text;
    NSString *expression = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    self.targetTextField.backgroundColor = [UIColor clearColor];
    
    if(!match){
        
        [self shoeAlertMessage:@"이메일 형식이 틀립니다"];
        self.email_ID.backgroundColor = UIColorFromRGB(0xFF0000, 0.5);
        self.targetTextField = self.email_ID;
        return NO;
    }
    
    if([self.password.text length] < 8){
        [self shoeAlertMessage:@"비밀번호는 8자리이상 입력하십시오."];
        self.password.backgroundColor = UIColorFromRGB(0xFF0000, 0.5);
        self.targetTextField = self.password;
        return NO;
    }
    
    
    return YES;
}
-(void) shoeAlertMessage:(NSString *)message{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"알림창"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nullable action){
                                                         [alertController dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    
    
    [alertController addAction:okButton];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}


//facebook login action
-(void)loginFacebookButtonClicked
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
                                                     //넘겨온 값을 서버로 전송을 한다.
                                                     [self loginFacebook:result];
                                                 }
                                             }];
                                        }
                                    }
                                }
                            }];
}


//비밀번호 찾기 (이메일인증을 보낼지에 대한 여부 )
//사파리로 넘기는 방법을 찾을것
-(IBAction)clickedForgotPasswordButton:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"비밀번호찾기"
                                                                             message:@"이메일을 보내서 비밀번호 변경 하시겠습니까?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    //보내기
    UIAlertAction *send = [UIAlertAction actionWithTitle:@"이메일인증 전송"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     //코드 구현
                                                     NSLog(@">>%@",self.email_ID.text);
                                                 }];
    
    //취소
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    
    [alertController addAction:cancel];
    [alertController addAction:send];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
    
    
}

-(IBAction)clickedSignInButton:(id)sender{
    //회원가입 화면으로 넘어간다.
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
    
    SignInViewController *signInVC = [stb instantiateViewControllerWithIdentifier:@"SignInViewController"];
    [self presentViewController:signInVC animated:YES completion:nil];
    
    
}

//로그인
-(void) loginFacebook:(id)result{
    
    NSString *email = [result objectForKey:@"email"];
    
    //로그인 호출
    
    [[RequestObject sharedInstance] loginID:email token:[FBSDKAccessToken currentAccessToken].tokenString];
}


//로그인후 메인화면으로 넘어간다
-(void) verifiedUser{
    //메인 화면으로 넘어가는 작업을 실시한다.
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MainViewController *mainVC = [storyBoard instantiateViewControllerWithIdentifier:@"MAIN_VIEW"];
    
    
    [self presentViewController:mainVC animated:YES completion:nil];
}



#pragma UITextField - Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
