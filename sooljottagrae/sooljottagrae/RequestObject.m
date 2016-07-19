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
#import "KeychainItemWrapper.h"

//서버정보
static NSString *const ServerHost = @"https://sooljotta.com";  //서버 주소
static NSString *const CertificationFileName = @"sooljotta.com"; //인증서파일이름

//HTTP 상태코드
typedef NS_ENUM(NSInteger, ServerResponseCode) {
    ServerResponseCodeSuccess = 2,
    ServerResponseCodeRedirection,
    ServerResponseCodeFail,
    ServerResponseCodeError
};


@interface RequestObject() <NSURLConnectionDelegate>

@property (strong, nonatomic) KeychainItemWrapper *keychainItem;

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

//SSL 설정을 위한 함수
-(void) setSSLSetting:(AFURLSessionManager *)manager cerFileName:(NSString *)fileName{
    //SSL을 위한 설정
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    //SSL인증서를 찾아서 적용하는 로직
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:fileName ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    manager.securityPolicy.pinnedCertificates = [NSSet setWithObject:localCertificate];

}

/*************************************************************************************
 * 데이터 전송시 사용(공통화)
 *************************************************************************************
 * @parameter : apiPath   (api경로)
 *            : parameter (서버에 전송될 파라미터)
 *            : success   (성공시 처리할 block)
 *            : fail      (실패시 처리할 block)
 *************************************************************************************/
-(void) sendToServer:(NSString *)apiPath
          parameters:(NSDictionary *)parameters
             success:(nullable void (^)(NSURLResponse *response, id responseObject, NSError *error))success
                fail:(nullable void (^)(NSURLResponse *response, id responseObject, NSError *error))fail{
    
    //기초설정
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //SSL설정
   [self setSSLSetting:manager cerFileName:CertificationFileName];
    
    //호출될 서버 URL 정보 설정
    NSString *urlString = [NSString stringWithFormat:@"%@%@", ServerHost, apiPath];
    
    //JSON형태의 파라미터를 전송한다.
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    
    NSLog(@"%@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            fail(response, responseObject, error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            
            //httpStatusCode를 가져온다
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSInteger returnCode = httpResponse.statusCode / 100;
            
            //Success(2xx), Redirection(3xx)
            if(returnCode >= ServerResponseCodeSuccess){
                success(response, responseObject, error);
                
            }
            
            //Fail(4xx), ServerError(5xx);
            if(returnCode >= ServerResponseCodeFail){
                fail(response, responseObject, error);
            }
        }
    }];
    
    
    [dataTask resume];
}

/*************************************************************************************
 * 데이터 전송시 사용(공통화) - 멀티파트
 *************************************************************************************
 * @parameter : apiPath   (api경로)
 *            : parameter (서버에 전송될 파라미터)
 *            : success   (성공시 처리할 block)
 *            : progress  (업로드시 처리되는 block)
 // This is not called back on the main queue.
 // You are responsible for dispatching to the main queue for UI updates
 //                      dispatch_async(dispatch_get_main_queue(), ^{
 //                          //Update the progress view
 //                          [progressView setProgress:uploadProgress.fractionCompleted];
 //                      });

 *            : faile     (실패시 처리할 block)
 *************************************************************************************/
-(void) sendToServer:(NSString *)apiPath
          parameters:(NSDictionary *)parameters
               image:(UIImage *)image
            fileName:(NSString *)fileName
             success:(nullable void (^)(NSURLResponse *response, id responseObject, NSError *error))success
            progress:(nullable void (^)(NSProgress *  uploadProgress))progress
                fail:(nullable void (^)(NSURLResponse *response, id responseObject, NSError *error))fail{
    
    //URL설정
    NSString *imageUploadURLString = [NSString stringWithFormat:@"%@%@", ServerHost, apiPath];
    
    //이미지 데이타
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    //이미지 스케일 줄이기( 1MBytes  이하 ) 
    if((imageData.length) >= 1024000){
        UIImage *image = [UIImage imageWithData:imageData];
        while( (imageData.length) >= 1024000 ){
            
            float resizeWidth = image.size.width - (image.size.width/10);
            float resizeHeight = image.size.height - (image.size.height/10);
            
            UIGraphicsBeginImageContext(CGSizeMake(resizeWidth, resizeHeight));
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, 0.0, resizeHeight);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            CGContextDrawImage(context, CGRectMake(0.0, 0.0, resizeWidth, resizeHeight), [image CGImage]);
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
            imageData = UIImageJPEGRepresentation(scaledImage, 1.0);
            
            image = nil;
            image = [UIImage imageWithData:imageData];
        }
    }
       
    //멀티파트 설정
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:imageUploadURLString
                                                                                             parameters:parameters
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                  [formData appendPartWithFileData:imageData
                                                                                                              name:@"image_data"
                                                                                                          fileName:fileName
                                                                                                          mimeType:@"image/jpeg"];
                                                                              } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //SSL 설정
    [self setSSLSetting:manager cerFileName:CertificationFileName];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      progress(uploadProgress);
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          //NSLog(@"Error: %@", error);
                          fail(response, responseObject, error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                          
                          //httpStatusCode를 가져온다
                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                          NSInteger returnCode = httpResponse.statusCode/100; //HTTP STATUS CODE의 가장 앞자리를 가져온다
                          
                          //Success(2xx), Redirection(3xx)
                          if(returnCode >= ServerResponseCodeSuccess){
                              success(response, responseObject, error);
                        
                          }
                          
                          //Fail(4xx), ServerError(5xx);
                          if(returnCode >= ServerResponseCodeFail){
                              fail(response, responseObject, error);
                          }
                      }
                      
                  }];
    
    [uploadTask resume];

}

/****************************************************************************
 * 키체인 유저정보 저장
 ****************************************************************************/
-(void) keyChainAccount:(NSString *)email passWord:(NSString *)password{
    
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
    
    
    //because keychain saves password as NSData object
    NSData *pwdData = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    //Save item
    [keychainItem setObject:email forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItem setObject:pwdData forKey:(__bridge id)(kSecValueData)];
    
}

/****************************************************************************
 * 키체인 유저정보 불러오기
 ****************************************************************************/
-(NSDictionary *)loadKeyChainAccount{
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
    
    
    NSString *email = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    
    //because label uses NSString and password is NSData object I convert
    NSData *pwdData = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
    NSString *password = [[NSString alloc] initWithData:pwdData encoding:NSUTF8StringEncoding];
  
    if([email length] > 0 && [password length] > 0) {
        return @{@"email":email, @"password":password};
    }
    
    return nil;
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
 * 메인 view
 *********************************************************************************/

//가장 많이 본 view 가져오기
// @param - pageCount : 현재 페이지
//        - listCount : 페이지당 갯수 (MAX : 50)

-(void) mostCommentedList:(NSInteger)pageCount listCount:(NSInteger)listCount{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //AFNSerializer를 통한 파라미터 전달법
    NSString *urlString = [NSString stringWithFormat:@"%@%@",ServerHost,@""];
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
