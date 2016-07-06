//
//  RequestObject.h
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 4..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <Foundation/Foundation.h>

//Notification을 위한 플래그
static NSString *const LoginSuccess = @"LOGIN_SUCCESS";


@interface RequestObject : NSObject


+ (instancetype) sharedInstance;

//로그인
-(void) loginID:(NSString *)email passwd:(NSString *)passWord;
-(void) loginID:(NSString *)email token:(NSString *)tokenString;




@end
