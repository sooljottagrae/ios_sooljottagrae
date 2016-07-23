//
//  UserObject.h
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 20..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSString *profileUrl;
@property (strong, nonatomic) NSString *profileThumnailUrl;
@property BOOL autoLoginYesNo;

@property (strong, nonatomic) NSMutableArray *userTagList;

@property NSInteger tagCount;


@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *passWord;

+(instancetype) sharedInstance;

-(void)setPassWord:(NSString *)passWord;
-(void)setUserEmail:(NSString *)userEmail;
-(void)setToken:(NSString *)token;


@end
