//
//  RequestObject.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 4..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

//하나의 객체로 모든 통신을 관리하는 객체

#import "RequestObject.h"
#import "AFNetworking.h"

static NSString *const SERVER_HOST = @"";
static NSString *const LOGIN_API = @"";


@implementation RequestObject

+ (instancetype) sharedInstance{
    static RequestObject *object = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[RequestObject alloc]init];
    });
    
    return object;
}

//로그인
-(void) loginID:(NSString *)email passwd:(NSString *)passWord{
    
}

//페이스북 로그인후 처리
// @param : email , tokenString
// 1. 서버에 전송
// 2. 로그인 로직
-(void) loginID:(NSString *)email token:(NSString *)tokenString{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //AFNSerializer를 통한 파라미터 전달법
    NSString *urlString = @"http://ios.yevgnenll.me/api/images/";
    NSDictionary *parameters = @{@"email":email, @"token":tokenString};
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    

    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    
    
    [dataTask resume];
}

@end
