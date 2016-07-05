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

//서버정보
static NSString *const SERVER_HOST = @"";  //서버 주소
static NSString *const LOGIN_API_FB = @""; //페이스북 로그인 API
static NSString *const LOGIN_API_NM = @""; //일반 로그인 API



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
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //AFNSerializer를 통한 파라미터 전달법
    NSString *urlString = [NSString stringWithFormat:@"%@%@",SERVER_HOST,LOGIN_API_FB];
    NSDictionary *parameters = @{@"email":email, @"password":passWord};
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            
            if([[responseObject objectForKey:@"CODE"] isEqualToString:@"200"]){
                
                //Notification을 통한 구현
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS
                                                                    object:nil];

                
            }
        }
    }];
    
    
    [dataTask resume];
    
    
    
}

//페이스북 로그인후 처리
// @param : email , tokenString
// 1. 서버에 전송
// 2. 로그인 로직
-(void) loginID:(NSString *)email token:(NSString *)tokenString{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //AFNSerializer를 통한 파라미터 전달법
    NSString *urlString = [NSString stringWithFormat:@"%@",SERVER_HOST];
    NSDictionary *parameters = @{@"email":email, @"token":tokenString};
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    

    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            
            if([[responseObject objectForKey:@"CODE"]isEqualToString:@"200"]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS
                                                                    object:nil];

            }
        }
    }];
    
    
    [dataTask resume];
}

-(void) sendProfilePhoto:(UIImage *)image email:(NSString *) email_ID session:(NSString *)token{
    //AFNetworking 으로 멀티파트 구현
    
    NSString *imageUploadURLString = @"http://ios.yevgnenll.me/api/images/";
    NSString *fileName = @"image.jpeg";
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    
    NSMutableDictionary *bodyParams = [[NSMutableDictionary alloc] init];
    [bodyParams setObject:email_ID forKey:@"email"];
    [bodyParams setObject:token forKey:@"session"];
    
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                               URLString:imageUploadURLString
                                                                                              parameters:bodyParams
                                                                               constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                   [formData appendPartWithFileData:imageData
                                                                                                               name:@"image_data"
                                                                                                           fileName:fileName
                                                                                                           mimeType:@"image/jpeg"];
                                                                               } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                   uploadTaskWithStreamedRequest:request
                   progress:^(NSProgress * _Nonnull uploadProgress) {
                       // This is not called back on the main queue.
                       // You are responsible for dispatching to the main queue for UI updates
                       //                      dispatch_async(dispatch_get_main_queue(), ^{
                       //                          //Update the progress view
                       //                          [progressView setProgress:uploadProgress.fractionCompleted];
                       //                      });
                   }
                   completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                       if (error) {
                           NSLog(@"Error: %@", error);
                       } else {
                           NSLog(@"%@ %@", response, responseObject);
                       }
                       
                       
//                       if ([[responseObject objectForKey:@"code"] isEqualToNumber:@201]) {
//                           [[NSNotificationCenter defaultCenter] postNotificationName:ImageUploadDidSuccessNotification
//                                                                               object:nil];
//                       } else {
//                           [[NSNotificationCenter defaultCenter] postNotificationName:ImageUploadDidFailNotification
//                                                                               object:nil];
//                       }
//                       
                       
                   }];
    
    [uploadTask resume];
    
}



@end
