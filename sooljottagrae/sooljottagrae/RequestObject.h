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

////로그인
//-(void) loginID:(NSString *)email passwd:(NSString *)passWord;
//-(void) loginID:(NSString *)email token:(NSString *)tokenString;
//
//

-(void) mostCommentedList:(NSInteger)pageCount listCount:(NSInteger)listCount;


-(void) sendToServer:(NSString *)apiPath
          parameters:(NSDictionary *)parameters
             success:(void (^)(NSURLResponse *response, id responseObject, NSError *error))success
                fail:(void (^)(NSURLResponse *response, id responseObject, NSError *error))fail;

-(void) sendToServer:(NSString *)apiPath
          parameters:(NSDictionary *)parameters
               image:(UIImage *)image
            fileName:(NSString *)fileName
             success:(void (^)(NSURLResponse *response, id responseObject, NSError *error))success
            progress:(void (^)(NSProgress *uploadProgress))progress
                fail:(void (^)(NSURLResponse *response, id responseObject, NSError *error))fail;

@end
