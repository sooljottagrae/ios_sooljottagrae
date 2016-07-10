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
static NSString *const ServerHost = @"";  //서버 주소
static NSString *const LoginAPIFacebook = @""; //페이스북 로그인 API
static NSString *const LoginAPINormal = @""; //일반 로그인 API

@interface RequestObject() <NSURLConnectionDelegate>

@end


@implementation RequestObject

+ (instancetype) sharedInstance{
    static RequestObject *object = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[RequestObject alloc]init];
    });
    
    return object;
}
/********************************************************************************
 * 로그인
 *********************************************************************************/


//로그인(일반)
-(void) loginID:(NSString *)email passwd:(NSString *)passWord{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    //SSL을 위한 설정
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    //SSL인증서를 찾아서 적용하는 로직
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"sooljota.com" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    manager.securityPolicy.pinnedCertificates = [NSSet setWithObject:localCertificate];
    
    
    
    //AFNSerializer를 통한 파라미터 전달법
    NSString *urlString = [NSString stringWithFormat:@"%@%@",ServerHost,LoginAPINormal];
    NSDictionary *parameters = @{@"email":email, @"password":passWord};
    
    //JSON형태의 파라미터를 전송한다.
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            
            if([[responseObject objectForKey:@"CODE"] isEqualToString:@"200"]){
                
                
                
                //자동로그인설정
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LOGIN"];
                
                //유저정보설정
                NSString *sessindId = [[responseObject objectForKey:@"contents"] objectForKey:@"session"];
                NSDictionary *userInfo = @{@"email":email, @"authKey":sessindId};
                [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"USER_INFO"];
                
                
                //Notification을 통한 구현
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccess
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@",ServerHost,LoginAPIFacebook];
    NSDictionary *parameters = @{@"email":email, @"token":tokenString};
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    

    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            
            if([[responseObject objectForKey:@"CODE"]isEqualToString:@"200"]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccess
                                                                    object:nil];
                
                //자동로그인여부설정
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LOGIN"];
                
                //유저정보설정
                NSString *sessindId = [[responseObject objectForKey:@"contents"] objectForKey:@"session"];
                NSDictionary *userInfo = @{@"email":email, @"authKey":sessindId};
                [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"USER_INFO"];


            }
        }
    }];
    
    
    [dataTask resume];
}
/********************************************************************************
 * 프로파일
 *********************************************************************************/

//이미지 보내는 것을 임시로 셋팅한다.
-(void) sendProfilePhoto:(UIImage *)image email:(NSString *) email_ID session:(NSString *)token{
    //AFNetworking 으로 멀티파트 구현
    
    NSString *imageUploadURLString = @"http://ios.yevgnenll.me/api/images/";
    NSString *fileName = @"image.jpeg";
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    
    NSMutableDictionary *bodyParams = [[NSMutableDictionary alloc] init];
    [bodyParams setObject:email_ID forKey:@"email"];
    [bodyParams setObject:token forKey:@"session"];
    
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
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
                       
        
                       
                   }];
    
    [uploadTask resume];
    
}

/********************************************************************************
 * 메인
 *********************************************************************************/

//가장 많이 본 view 가져오기
// @param - pageCount : 현재 페이지
//        - listCount : 페이지당 갯수 (MAX : 50)

-(void) mostCommentedList:(NSInteger)pageCount listCount:(NSInteger)listCount{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //AFNSerializer를 통한 파라미터 전달법
    NSString *urlString = [NSString stringWithFormat:@"%@%@",ServerHost,LoginAPIFacebook];
    NSDictionary *parameters = @{@"PAGE":@(pageCount), @"list_count":@(listCount)};
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    
    
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            
            if([[responseObject objectForKey:@"CODE"]isEqualToString:@"200"]){
                
                self.mostCommentedList = [responseObject objectForKey:@"contents"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:MostCommentdListLoadSuccess
                                                                    object:nil];
                
                
            }
        }
    }];
    
    
    [dataTask resume];
    
}



@end
