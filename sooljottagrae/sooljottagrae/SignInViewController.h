//
//  SignInViewController.h
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 4..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *pwdTextField;
@property (nonatomic, weak) IBOutlet UITextField *pwdConfirmTextField;

@property (nonatomic, strong) NSDictionary *userInfo;

@end
