//
//  RequestObject.h
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 4..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;



//Notification을 위한 플래그
static NSString *const LoginSuccess = @"LoginSuccess"; //로그인성공시
static NSString *const MostCommentdListLoadSuccess = @"MostCommentdListLoadSuccess";



@interface RequestObject : NSObject

@property (strong, nonatomic) NSArray *mostCommentedList;


+ (instancetype) sharedInstance;

-(void) keyChainAccount:(NSString *)email passWord:(NSString *)password token:(NSString *)token;
-(NSDictionary *)loadKeyChainAccount;


-(void) mostCommentedList:(NSInteger)pageCount listCount:(NSInteger)listCount;


-(void) sendToServer:(NSString *)apiPath
              option:(NSString *)option
          parameters:(NSDictionary *)parameters
             success:(void (^)(NSURLResponse *response, id responseObject, NSError *error))success
                fail:(void (^)(NSURLResponse *response, id responseObject, NSError *error))fail
             useAuth:(BOOL) useAuth;

-(void) sendToServer:(NSString *)apiPath
              option:(NSString *)option
          parameters:(NSDictionary *)parameters
               image:(UIImage *)image
            fileName:(NSString *)fileName
             success:(void (^)(NSURLResponse *response, id responseObject, NSError *error))success
            progress:(void (^)(NSProgress *uploadProgress))progress
                fail:(void (^)(NSURLResponse *response, id responseObject, NSError *error))fail
             useAuth:(BOOL) useAuth;

@end
