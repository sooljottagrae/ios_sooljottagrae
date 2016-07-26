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
#import "UserObject.h"

//서버정보
static NSString *const ServerHost = @"https://sooljotta.com";           //서버 주소
static NSString *const CertificationFileName = @"sooljotta.com";        //인증서파일이름
static NSString *const VerifiedAuthorization = @"/api/users/login/";    //토큰재발급 경로

static NSString *const ExpriedMessage = @"Signature has expired.";      //토큰만료시 메세지

//HTTP 상태코드
typedef NS_ENUM(NSInteger, ServerResponseCode) {
    ServerResponseCodeSuccess = 2,
    ServerResponseCodeRedirection,
    ServerResponseCodeFail,
    ServerResponseCodeError
};


@interface RequestObject() <NSURLConnectionDelegate>

@property (strong, nonatomic) KeychainItemWrapper *keychainItem;    //키체인

@end


@implementation RequestObject

//싱글톤 객체 만들기
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
 *            : option    (GET, POST)
 *            : parameter (서버에 전송될 파라미터)
 *            : success   (성공시 처리할 block)
 *            : fail      (실패시 처리할 block)
 *            : useAuth   (유저 인증 필요 여부)
 *************************************************************************************/

-(void) sendToServer:(NSString *)apiPath
              option:(NSString *)option
          parameters:(NSDictionary *)parameters
             success:(nullable void (^)(NSURLResponse *response, id responseObject, NSError *error))success
                fail:(nullable void (^)(NSURLResponse *response, id responseObject, NSError *error))fail
            useAuth:(BOOL) useAuth
{
    
    //기초설정
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //SSL설정
   [self setSSLSetting:manager cerFileName:CertificationFileName];
    
    //호출될 서버 URL 정보 설정
    NSString *urlString = [NSString stringWithFormat:@"%@%@", ServerHost, apiPath];
    
    NSLog(@"url : %@",urlString);
    
    //토큰정보
    NSString *token = nil;
    
    
    //인증 실패시 넘겨줄 파라미터를 생성한다.
    NSMutableDictionary *temp2 = [[NSMutableDictionary alloc]init];
    [temp2 setObject:apiPath forKey:@"apiUrl"];         //apiUrl
    [temp2 setObject:option forKey:@"option"];          //option
    [temp2 setObject:@"normal" forKey:@"sendType"];     //전송구분
    [temp2 setObject:@(0) forKey:@"authCount"];         //인증 시도 횟수
    [temp2 setObject:success forKey:@"success"];        //성공시 블록처리
    [temp2 setObject:fail forKey:@"fail"];              //실패시 블록처리
    if(parameters.count > 0){
        [temp2 setObject:parameters forKey:@"contents"];    //넘겨받은 파라미터
    }


    //토큰값
    token = [[[RequestObject sharedInstance]loadKeyChainAccount] objectForKey:@"token"];
    
    //JSON형태의 파라미터를 전송한다.
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:option URLString:urlString parameters:parameters error:nil];
   
    //토큰값이 있다면 HTTP Header에 포함시켜 전송한다.
    if([token length] > 0) {
        if(useAuth == YES){
            [request setValue:[NSString stringWithFormat:@"JWT %@",token] forHTTPHeaderField:@"Authorization"];
        }
    }
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        //NSLog(@"%@ %@", response, responseObject);
        
        //httpStatusCode를 가져온다
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger returnCode = httpResponse.statusCode;
        
        //2xx - 성공
        if((returnCode/100) >= ServerResponseCodeSuccess){
            success(response, responseObject, error);
        }
        
        //3xx - 리다이렉션
        if((returnCode/100) >= ServerResponseCodeRedirection){
            success(response, responseObject, error);
        }
        
        //4xx - 실패
        if((returnCode/100) >= ServerResponseCodeFail){
            //인증실패시
            if([[responseObject objectForKey:@"detail"] isEqualToString:ExpriedMessage] && useAuth){
                [self verifiedAuthToken:VerifiedAuthorization
                             parameters:temp2
                                   fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                                       //인증실패시 처리
                                       
                                   }];
                
                
            }else{
                fail(response, responseObject, error);
            }
        }
        
        //5xx - 서버오류
        if((returnCode/100) > ServerResponseCodeError){
            fail(response, responseObject, error);
        }
        
    }];
    
    
    [dataTask resume];
}

/*************************************************************************************
 * 데이터 전송시 사용(공통화) - 멀티파트
 *************************************************************************************
 * @parameter : apiPath   (api경로)
 *            : option    (GET, POST)
 *            : parameter (서버에 전송될 파라미터)
 *            : success   (성공시 처리할 block)
 *            : progress  (업로드시 처리되는 block)
 // This is not called back on the main queue.
 // You are responsible for dispatching to the main queue for UI updates
 //                      dispatch_async(dispatch_get_main_queue(), ^{
 //                          //Update the progress view
 //                          [progressView setProgress:uploadProgress.fractionCompleted];
 //                      });

 *            : fail      (실패시 처리할 block)
 *************************************************************************************/
-(void) sendToServer:(NSString *)apiPath
              option:(NSString *)option
          parameters:(NSDictionary *)parameters
               image:(UIImage *)image
            fileName:(NSString *)fileName
             success:(nullable void (^)(NSURLResponse *response, id responseObject, NSError *error))success
            progress:(nullable void (^)(NSProgress *  uploadProgress))progress
                fail:(nullable void (^)(NSURLResponse *response, id responseObject, NSError *error))fail
             useAuth:(BOOL) useAuth
{
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    //SSL 설정
    [self setSSLSetting:manager cerFileName:CertificationFileName];

    
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
    
    
    //토큰정보
    NSString *token = nil;
    
    
    //인증 실패시 넘겨줄 파라미터를 생성한다.
    NSMutableDictionary *temp2 = [[NSMutableDictionary alloc]init];
    [temp2 setObject:apiPath forKey:@"apiUrl"];         //apiUrl
    [temp2 setObject:option forKey:@"option"];          //option
    [temp2 setObject:@"multipart" forKey:@"sendType"];  //전송구분
    [temp2 setObject:@(0) forKey:@"authCount"];         //인증 시도 횟수
    [temp2 setObject:image forKey:@"image"];            //파일이미지
    [temp2 setObject:fileName forKey:@"fileName"];      //파일이름
    [temp2 setObject:parameters forKey:@"contents"];    //넘겨받은 파라미터
    [temp2 setObject:success forKey:@"successBlock"];   //성공시 블록처리
    [temp2 setObject:fail forKey:@"failBlock"];         //실패시 블록처리
    [temp2 setObject:progress forKey:@"progressBlock"]; //프로세스 블록처리

    //토큰
    token = [[[RequestObject sharedInstance]loadKeyChainAccount] objectForKey:@"token"];
    
    //멀티파트 설정
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] multipartFormRequestWithMethod:option
                                                                                              URLString:imageUploadURLString
                                                                                             parameters:parameters
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                  [formData appendPartWithFileData:imageData
                                                                                                              name:@"image"
                                                                                                          fileName:fileName
                                                                                                          mimeType:@"image/jpeg"];
                                                                              } error:nil];
    
    //토큰값이 있다면 HTTP Header에 포함시켜 전송한다.
    if([token length] > 0) {
        if(useAuth == YES){
            [request setValue:[NSString stringWithFormat:@"JWT %@",token] forHTTPHeaderField:@"Authorization"];
            NSLog(@"set Header token : %@",request.allHTTPHeaderFields);
        }
    }

    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      progress(uploadProgress);
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      NSLog(@"!!!!!%@ %@", response, responseObject);
                      
                      //httpStatusCode를 가져온다
                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                      NSInteger returnCode = httpResponse.statusCode;
                      
                      //2xx - 성공
                      if((returnCode/100) == ServerResponseCodeSuccess){
                          success(response, responseObject, error);
                      }
                      
                      //3xx - 리다이렉션
                      if((returnCode/100) == ServerResponseCodeRedirection){
                          success(response, responseObject, error);
                      }
                      
                      //4xx - 실패
                      if((returnCode/100) == ServerResponseCodeFail){
                          //인증실패시
                          if([[responseObject objectForKey:@"detail"] isEqualToString:ExpriedMessage] && useAuth){
                              [self verifiedAuthToken:VerifiedAuthorization
                                           parameters:temp2
                                                 fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                     //인증실패시 처리
                                                     
                                                 }];
                              
                              
                          }else{
                              fail(response, responseObject, error);
                          }
                      }
                      
                      //5xx - 서버오류
                      if((returnCode/100) == ServerResponseCodeError){
                          fail(response, responseObject, error);
                      }
        }];
    
    [uploadTask resume];

}

/*************************************************************************************
 * 데이터 전송시 사용(공통화) - 토큰재인증을 위한 시스템
 *************************************************************************************
 * @function  : verifiedAuthToken
 * @parameter : apiPath   (api경로)
 *            : parameter (인증을 뒤 다시 호출될 API 정보들)
 
 *            : fail      (실패시 처리할 block)
 *************************************************************************************/
-(void) verifiedAuthToken:(NSString *) apiPath
               parameters:(NSDictionary *)parameters
                     fail:(nullable void (^)(NSURLResponse *response, id responseObject, NSError *error))fail{
    
    //기초설정
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //SSL설정
    [self setSSLSetting:manager cerFileName:CertificationFileName];
    
    //호출될 서버 URL 정보 설정
    NSString *urlString = [NSString stringWithFormat:@"%@%@", ServerHost, apiPath];
    
    
    //인증시도 횟수
    NSNumber *authCount = [parameters objectForKey:@"authCount"];
    
    
    //인증시도 횟수가 3회 이상일 경우 중단을 한다.
    if(authCount.integerValue > 2){
        fail(nil,(id)@{@"detail":@"인증에 실패하였습니다. 다시시도 하시거나 관리자에게 문의 하세요."}, nil);
        return;
    }
    
    //파라미터 변경을 위해서 다시 선언을 한다.
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [temp setObject:@(authCount.integerValue+1) forKey:@"authCount"];
    
    //재인증 후 다시 보내는 구분값
    BOOL sendFlag;
    if([[temp objectForKey:@"sendType"] isEqualToString:@"multipart"]){
        sendFlag = NO;
    }else if([[temp objectForKey:@"sendType"] isEqualToString:@"normal"]){
        sendFlag = YES;
    }
    
    //성공시 block처리문을 다시 실행 시켜주기 위한 파라미터를 선언한다
    void (^reUseSuccess)(NSURLResponse *response, id responseObject, NSError *error) = [temp objectForKey:@"successBlock"];
    void (^reUseFail)(NSURLResponse *response, id responseObject, NSError *error) = [temp objectForKey:@"failBlock"];
    void (^reUseProgress)(NSProgress *uploadProgress) = [temp objectForKey:@"progressBlock"];
    
    //재인증을 값을 셋팅한다.
    NSMutableDictionary *authParameter = [[RequestObject sharedInstance]loadKeyChainAccount].mutableCopy;
    [authParameter removeObjectForKey:@"token"];
    
    //JSON형태의 파라미터를 전송한다.
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:authParameter error:nil];
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
            
            //httpStatusCode를 가져온다
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSInteger returnCode = httpResponse.statusCode;
            
            //2xx - 성공
            if((returnCode/100) == ServerResponseCodeSuccess){
//                NSLog(@"%@ %@", response, responseObject);
                
                if([responseObject objectForKey:@"token"] != nil){
                    [[RequestObject sharedInstance]keyChainAccount:[authParameter objectForKey:@"email"]
                                                          passWord:[authParameter objectForKey:@"password"]
                                                             token:[responseObject objectForKey:@"token"]];
                }
                
                if(sendFlag){
                    [self sendToServer:[temp objectForKey:@"apiUrl"]
                                option:[temp objectForKey:@"option"]
                            parameters:[temp objectForKey:@"contents"]
                               success:^(NSURLResponse *response, id responseObject, NSError *error) {
                                   reUseSuccess(response, responseObject, error);
                               }
                                  fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                                      reUseFail(response, responseObject, error);
                                  } useAuth:YES];
                
                }else{
                    [self sendToServer:[temp objectForKey:@"apiUrl"]
                                option:[temp objectForKey:@"option"]
                            parameters:[temp objectForKey:@"contents"]
                                 image:[temp objectForKey:@"image"]
                              fileName:[temp objectForKey:@"fileName"]
                               success:^(NSURLResponse *response, id responseObject, NSError *error) {
                                   //성공시 처리
                                   reUseSuccess(response, responseObject, error);
                               } progress:^(NSProgress *uploadProgress) {
                                   //진행처리
                                   reUseProgress(uploadProgress);
                               } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                                   //실패시처리
                                   reUseFail(response, responseObject, error);
                               } useAuth:YES];
                }
            }
            
            //4xx - 실패
            if((returnCode/100) == ServerResponseCodeFail){
                //토큰이 Expired  되었을경우
//                NSLog(@">> %@ %@", response, responseObject);
                NSArray *test = responseObject[@"non_field_errors"];
                if([test[0] isEqualToString:ExpriedMessage]){
                    
                    [self verifiedAuthToken:VerifiedAuthorization
                                 parameters:temp
                                       fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                                           //재인증 다시 시도
                                           [self verifiedAuthToken:apiPath parameters:temp fail:nil];
                                       }];
                
                }
            }
        }];
    
    
    [dataTask resume];
    
    
    
    
}


/****************************************************************************
 * 키체인 유저정보 저장
 ****************************************************************************/
-(void) keyChainAccount:(NSString *)email passWord:(NSString *)password token:(NSString *)token{
//    NSLog(@"%@, %@, %@", email, password, token);
    
    self.keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"LoginAccount" accessGroup:nil];
    
    NSDictionary *dict = @{@"password":password, @"token":token};
    
    NSData *pwdData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    //Save item
    [self.keychainItem setObject:email forKey:(__bridge id)(kSecAttrAccount)];   //email
    [self.keychainItem setObject:pwdData forKey:(__bridge id)(kSecValueData)];   //비밀번호
    
}

/****************************************************************************
 * 키체인 유저정보 불러오기
 ****************************************************************************/
-(NSDictionary *)loadKeyChainAccount{
    
    self.keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"LoginAccount" accessGroup:nil];
    
    NSString *email = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    NSData *pwdData = [self.keychainItem objectForKey:(__bridge id)(kSecValueData)];
    
    NSMutableDictionary *dict = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:pwdData options:NSJSONReadingMutableContainers error:nil];
    
    
    NSString *passWord = [dict objectForKey:@"password"];
    NSString *tokenString = [dict objectForKey:@"token"];
    
    [dict setObject:email forKey:@"email"];
    
    //값이 없으면 출력 못하게 한다.
    if([email length] > 0 && [passWord length] > 0 && [tokenString length] > 0) {
        return [NSDictionary dictionaryWithDictionary:dict];
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
