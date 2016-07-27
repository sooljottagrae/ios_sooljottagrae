//
//  UserObject.h
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 20..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject

@property (strong, nonatomic) NSString *userName;               //사용자이름
@property (strong, nonatomic) NSString *userEmail;              //사용자 이메일(ID)
@property (strong, nonatomic) NSString *profileUrl;             //사용자 프로파일 URL
@property (strong, nonatomic) NSString *profileThumnailUrl;     //사용자 프로파일 섬네일 URL

@property BOOL autoLoginYesNo;                                  //autoLogin 여부

@property (strong, nonatomic) NSMutableArray *userTagList;      //태그 리스트 목록

@property NSInteger tagCount;                                   //태그 리스트 갯수

@property (strong, nonatomic) NSString *pk;                     //서버자체id
@property (strong, nonatomic) NSString *token;                  //토큰값
@property (strong, nonatomic) NSString *passWord;               //비밀번호

+(instancetype) sharedInstance;

-(void)setPassWord:(NSString *)passWord;
-(void)setUserEmail:(NSString *)userEmail;
-(void)setToken:(NSString *)token;


-(NSMutableDictionary *) loadAccountInfoToDictionary;
-(void) updateEmail:(NSString *)email passWord:(NSString *)passWord token:(NSString *)token pk:(NSString *)pk;
@end
