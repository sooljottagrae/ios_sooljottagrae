//
//  ViewController.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 4..
//  Copyright © 2016년 alcoholic. All rights reserved.


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


@property (strong, nonatomic) CAGradientLayer *gradient;            //배경그라이언트


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //뷰생성에 관련된 함수
    [self createView];
    
    //배경 그라디언트 크기 설정
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundColorGradient)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    
#ifdef DEBUG
    self.email_ID.text = @"sooljotta@sooljotta.com";
    self.password.text = @"sooljotta";
    self.forgotPassword.enabled = YES;
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"LOGIN"];
#endif
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //자동로그인 설정
    [self autoLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//자동로그인
-(void)autoLogin{
   // NSLog(@"%d",[[NSUserDefaults standardUserDefaults] boolForKey:@"LOGIN"]);
    
    BOOL loginKey = [[NSUserDefaults standardUserDefaults] boolForKey:@"LOGIN"];
    
    if(loginKey == YES){
        NSString *email = nil;
        NSString *tokenString = nil;
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"EMAIL"] != nil){
            email = [[NSUserDefaults standardUserDefaults] objectForKey:@"EMAIL"];
        }
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"TOKEN"] != nil){
            tokenString = [[NSUserDefaults standardUserDefaults] objectForKey:@"TOKEN"];
        }
        
        [self verifiedUser:email token:tokenString];
        
    }

}

//view 기초 설정
-(void) createView{
    
    self.view.backgroundColor = [UIColor clearColor];
    
    //배경 그라디언트
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0xffffff,1.0) CGColor],(id)[THEMA_BG_COLOR CGColor],nil];
    gradient.locations =[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.05], [NSNumber numberWithFloat:0.95], nil];
    
    
    self.gradient = gradient;
    [self.view.layer insertSublayer:gradient atIndex:0];
    

    
    //로그인뷰
    self.loginView.backgroundColor = [UIColor clearColor];
    
    //로그인뷰 배경화면 투명화
    self.loginViewBgColor = [[UIView alloc]init];
    self.loginViewBgColor.frame = self.loginView.bounds;
    self.loginViewBgColor.backgroundColor = UIColorFromRGB(0xFFFFFF, 0.84);
    self.loginViewBgColor.layer.cornerRadius = 10.0f;
    self.loginViewBgColor.layer.masksToBounds = YES;
    
    [self.loginView addSubview:self.loginViewBgColor];
    
    //그외 버튼 등을 다시 올린다
    [self.loginView addSubview:self.loginTitle];
    [self.loginView addSubview:self.email_ID];
    [self.loginView addSubview:self.password];
    
    
    self.loginButton.layer.cornerRadius = 3.0f;
    self.loginButton.layer.masksToBounds = YES;
    [self.loginView addSubview:self.loginButton];
    
    
    [self.loginView addSubview:self.divTitle];
    
    
    //페이스북 로그인 버튼 액션 설정
    [self.facebookLogin addTarget:self
                           action:@selector(loginFacebookButtonClicked)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.loginView addSubview:self.facebookLogin];
    
    [self.loginView addSubview:self.line];
    [self.loginView addSubview:self.forgotPassword];
    [self.loginView addSubview:self.signIn];
    
    //패스워드 찾기 버튼 비활성화
    self.forgotPassword.enabled = NO;

}


//배경 그라디언트 설정
-(void) backgroundColorGradient{
    self.gradient.frame = self.view.bounds;
}

//로그인 버튼 액션
-(IBAction)loginButtonAction:(UIButton *)sender{
    //값 체크
    if(![self checkLoginParameter]){
        return;
    }
    
    //로그인 파라미터설정
    NSDictionary *parameters = @{@"email":self.email_ID.text, @"password":self.password.text};
    
    //로그인
    [[RequestObject sharedInstance] sendToServer:@"/api/users/login/"
                                      parameters:parameters
                                         success:^(NSURLResponse *response, id responseObject, NSError *error) {
                                             [self verifiedUser:self.email_ID.text token:responseObject[@"token"]];
                                         } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                                             NSLog(@"%@",error);
                                             [self showAlertMessage:@"입력하신 회원정보가 일치하지 않거나 없습니다. 다시확인해주세요"];
                                         }];
}

//로그인을 위한 체크함수
-(BOOL) checkLoginParameter{
    
    NSString *string = self.email_ID.text;
    NSString *expression = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
    NSError *error = NULL;
    
    //이메일 형식을 확인 하기 위한 정규식
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    self.targetTextField.backgroundColor = [UIColor clearColor];
    
    if(!match){
        
        [self showAlertMessage:@"이메일 형식이 틀립니다"];
        self.email_ID.backgroundColor = UIColorFromRGB(0xfad2dd, 0.6f);
        self.targetTextField = self.email_ID;
        self.targetTextField.selected = YES;
        return NO;
    }
    
    if([self.password.text length] < 8){
        [self showAlertMessage:@"비밀번호는 8자리이상 입력하십시오."];
        self.password.backgroundColor = UIColorFromRGB(0xfad2dd, 0.6f);
        self.targetTextField = self.password;
        self.targetTextField.selected = YES;
        return NO;
    }
    
    
    return YES;
}

//알림창 보여주기
-(void) showAlertMessage:(NSString *)message{
    
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
    [login logInWithReadPermissions: @[@"public_profile"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    NSLog(@"Process error");
                                } else if (result.isCancelled) {
                                    NSLog(@"Cancelled");
                                } else {
                                   // NSLog(@"Logged in %@",result.grantedPermissions);
                                   
                                    if ([result.grantedPermissions containsObject:@"public_profile"]) {
                                        if ([FBSDKAccessToken currentAccessToken] != nil) {
                                            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                                            [parameters setValue:@"id,name,email" forKey:@"fields"];
                                            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                                             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                 //NSLog(@"%@", result);
                                                 if (error) {
                                                     //넘겨온 값을 서버로 전송을 한다.
                                                     
                                                 }else{
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
                                                                             message:@"비밀번호를 변경하는 이메일을 보내시겠습니까?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    //보내기
    UIAlertAction *send = [UIAlertAction actionWithTitle:@"이메일인증 전송"
                                                   style:UIAlertActionStyleDestructive
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     //코드 구현
                                                     NSString *string = self.email_ID.text;
                                                     NSString *expression = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
                                                     NSError *error = NULL;
                                                     
                                                     NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                                                                            options:NSRegularExpressionCaseInsensitive
                                                                                                                              error:&error];
                                                     
                                                     NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
                                                     
                                                     self.targetTextField.backgroundColor = [UIColor clearColor];
                                                     
                                                     if(!match){
                                                         [self showAlertMessage:@"이메일 형식이 틀립니다"];
                                                         self.email_ID.backgroundColor = UIColorFromRGB(0xfad2dd, 0.6f);
                                                         self.targetTextField = self.email_ID;
                                                         self.targetTextField.selected = YES;
                                                     }
                                                     
                                                     
                                                     NSLog(@">>%@",self.email_ID.text);
                                                 }];
    
    //취소
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    
    [alertController addAction:send];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
    
    
}

//회원가입 화면으로 넘긴다. - (홍준 최종 수정)
-(IBAction)clickedSignInButton:(id)sender{
    //회원가입 화면으로 넘어간다.
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
    
    SignInViewController *signInVC = [stb instantiateViewControllerWithIdentifier:@"SignInViewController"];
    [self presentViewController:signInVC animated:YES completion:nil];
    
    
}

//페이스로 로그인 성공시
-(void) loginFacebook:(id)result{
    
    NSString *email = [result objectForKey:@"email"];
    
    //로그인 호출
    
    NSDictionary *parameters = @{@"email":email, @"token":[FBSDKAccessToken currentAccessToken].tokenString};
    
    
    
//    [[RequestObject sharedInstance] sendToServer:@"/api/user/fblogin"
//                                          params:parameters
//                                         success:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                             [self verifiedUser:email token:responseObject[@"token"]];
//                                         } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                             
//                                         }];
    
    
    [self verifiedUser:email token:[FBSDKAccessToken currentAccessToken].tokenString];
}


//로그인후 메인화면으로 넘어간다
-(void) verifiedUser:(NSString *)email token:(NSString *)tokenString{
    //메인 화면으로 넘어가는 작업을 실시한다.
    
    //인증된 값을 저장한다.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LOGIN"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"EMAIL"];
    
    if(tokenString != nil || [tokenString length] > 0){
        [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"TOKEN"];
    }
    
    //메인뷰로 넘어간다.
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *mainVC = [storyBoard instantiateViewControllerWithIdentifier:@"MAIN_VIEW"];
    
    [self presentViewController:mainVC animated:NO completion:nil];
}



#pragma UITextField - Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    //이메일이 입력될 경우 패스워드 찾기가 활성화 된다.
    if(textField.tag == 0){
        if([textField.text length] > 0){
            self.forgotPassword.enabled = YES;
        }else{
            self.forgotPassword.enabled = NO;
        }
    }
    
    return YES;
}

@end
