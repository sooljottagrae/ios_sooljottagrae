//
//  UserObject.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 20..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "UserObject.h"
#import "KeychainItemWrapper.h"
#import "RequestObject.h"

static NSString *const AppLoginKeyId = @"AppLoginAccount";



@interface UserObject()

@end


@implementation UserObject

@synthesize userName = _userName;

+(instancetype) sharedInstance{
    static UserObject *userObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userObject = [[UserObject alloc]init];
    });
    return userObject;
}

- (instancetype)init
{
    KeychainItemWrapper *keychainItem = nil;
    
    
    self = [super init];
    if (self) {
        keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
        NSString *email = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
        
        NSData *pwdData = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
        
        NSMutableDictionary *dict;
        dict = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:pwdData
                                                                      options:NSJSONReadingMutableContainers error:nil];
        
        
        NSString *passWord = [dict objectForKey:@"password"];
        NSString *tokenString = [dict objectForKey:@"token"];
        NSString *pk = [dict objectForKey:@"pk"];
        
        
        
        _userEmail = email;
        _passWord = passWord;
        _token = tokenString;
        _pk = pk;
        
        
        
    }
    return self;
}

-(void)setUserName:(NSString *)userName{
    
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userName"];
    
    _userName = userName;
}



-(NSString *)userName{
    if(_userName == nil){
        _userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    }
    return _userName;
}

-(void) updateEmail:(NSString *)email passWord:(NSString *)passWord token:(NSString *)token pk:(NSString *)pk{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"LoginAccount" accessGroup:nil];
    [keychainItem setObject:@"Myappstring" forKey: (id)kSecAttrService];
  
    
    NSDictionary *dict = @{@"password":passWord, @"token":token, @"pk":pk};
    
    NSData *pwdData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    //Save item
    [keychainItem setObject:email forKey:(__bridge id)(kSecAttrAccount)];   //email
    [keychainItem setObject:pwdData forKey:(__bridge id)(kSecValueData)];   //비밀번호
    
    _userEmail = email;
    _passWord = passWord;
    _token = token;
    _pk = pk;

}

-(void) updateProfileUrl:(NSString *)profileUrl thumnailUrl:(NSString *)thumnailUrl{
    self.profileUrl = profileUrl;
    self.profileThumnailUrl= thumnailUrl;
}

-(void) updateTagList:(NSMutableArray *)list listCount:(NSInteger)count{
    self.userTagList = list;
    self.tagCount = count;
}

-(void)setUserEmail:(NSString *)userEmail{
    
    
    _userEmail = userEmail;

    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
    [keychainItem setObject:@"Myappstring" forKey: (id)kSecAttrService];
    //Save item
    [keychainItem setObject:userEmail forKey:(__bridge id)(kSecAttrAccount)];
    
    
}
-(void)setPassWord:(NSString *)passWord{
    
    _passWord = passWord;
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
    [keychainItem setObject:@"Myappstring" forKey: (id)kSecAttrService];
    
    NSDictionary *dict = @{@"password":passWord, @"token":self.token, @"pk":self.pk};
    
    NSData *pwdData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    [keychainItem setObject:pwdData forKey:(__bridge id)kSecValueData];
    
    
};

-(void)setToken:(NSString *)token{
    
    _token = token;
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
    [keychainItem setObject:@"Myappstring" forKey: (id)kSecAttrService];
    
    NSDictionary *dict = @{@"password":self.passWord, @"token":token, @"pk":self.pk};
    
    NSData *pwdData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    [keychainItem setObject:pwdData forKey:(__bridge id)kSecValueData];

}

//-(void) setServerId:(NSString *)serverId{
//    _serverId = serverId;
//    
//    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
//    
//    NSDictionary *dict = @{@"password":self.passWord, @"token":self.token, @"serverId":serverId};
//    
//    NSData *pwdData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
//    [keychainItem setObject:pwdData forKey:(__bridge id)kSecValueData];
//}

-(void) setPk:(NSString *)pk{
    _pk  = pk;
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
    [keychainItem setObject:@"Myappstring" forKey: (id)kSecAttrService];
    
    NSDictionary *dict = @{@"password":self.passWord, @"token":self.token, @"pk":pk};
    
    NSData *pwdData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    [keychainItem setObject:pwdData forKey:(__bridge id)kSecValueData];

}


//서버로부터 오는 정보를 UserObject에 셋팅한다.
-(void) setttingUserInfoFromServer:(NSString *) serverId{
    
    NSString *apiUrl = [NSString stringWithFormat:@"%@%@",@"api/users/",serverId];
    
    
    [[RequestObject sharedInstance] sendToServer:apiUrl option:@"POST" parameters:nil success:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if(responseObject != nil){
            
            //객체 초기화
            NSString *profileUrl = nil;
            NSString *thumnail = nil;
            
            NSInteger tagCount = 0;
            NSMutableArray *tagList = nil;
            
            //서버로부터의 정보값에 nil값에 따른 처리
            //프로파일 원본 URL
            if([responseObject objectForKey:@"profile"] != nil){
                profileUrl = [responseObject objectForKey:@"profile"];
            }
            //섬네일 프로파일 원본 URL
            if([responseObject objectForKey:@"thumnail"] != nil){
                thumnail = [responseObject objectForKey:@"thumnail"];
            }
            //태그리스트 정보
            if([responseObject objectForKey:@"taglist"] != nil){
                tagList = [responseObject objectForKey:@"taglist"];
            }
            //태그리스트 맥시멈 갯수 (서버설정에 따라서 변경 될수 있도록)
            if([responseObject objectForKey:@"tagCount"] != nil){
                NSNumber *count = [responseObject objectForKey:@"tagCount"];
                tagCount = count.integerValue;
            }
            
            //섬네일 정보를 셋팅한다.
            [self updateProfileUrl:profileUrl thumnailUrl:thumnail];
            
            //태그리스트 정보를 셋팅한다.
            [self updateTagList:tagList listCount:tagCount];
            
        }
        
        
    } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
        
    } useAuth:NO];
    
}

//유저정보를 내보낸다.
-(NSMutableDictionary *) loadAccountInfoToDictionary{
    NSMutableDictionary *userInfos = nil;
    
    if(self.userEmail != nil){
        [userInfos setObject:self.userEmail forKey:@"email"];
        [userInfos setObject:@(self.autoLoginYesNo) forKey:@"autoLogin"];
    }
    
    if(self.userName != nil){
        [userInfos setObject:self.userName forKey:@"userName"];
    }
    
    if(self.token != nil){
        [userInfos setObject:self.token forKey:@"token"];
    }
    
    if(self.passWord != nil){
        [userInfos setObject:self.passWord forKey:@"password"];
    }
    
    if(self.profileUrl != nil){
        [userInfos setObject:self.profileUrl forKey:@"profile"];
    }
    
    if(self.profileThumnailUrl != nil){
        [userInfos setObject:self.profileThumnailUrl forKey:@"thumnail"];
    }
    
    if(self.pk != nil){
        [userInfos setObject:self.pk forKey:@"pk"];
    }
    
    return userInfos;
}

@end
