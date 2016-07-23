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
        
        //because label uses NSString and password is NSData object I convert
        NSData *pwdData = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
        NSString *password = [[NSString alloc] initWithData:pwdData encoding:NSUTF8StringEncoding];
        
        NSString *token = [keychainItem objectForKey:(__bridge id)kSecAttrTokenID];
        
        _userEmail = email;
        _passWord = password;
        _token = token;
        
        
        
    }
    return self;
}

-(void)setUserEmail:(NSString *)userEmail{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
    
    //Save item
    [keychainItem setObject:userEmail forKey:(__bridge id)(kSecAttrAccount)];
    _userEmail = userEmail;
    
}
-(void)setPassWord:(NSString *)passWord{
    
    _passWord = passWord;
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
    
    NSDictionary *myDictionary = @{@"password":self.passWord, @"session":self.token};
    [keychainItem setObject:myDictionary forKey:(__bridge id)kSecValueData];
    
    
};

-(void)setToken:(NSString *)token{
    
    _token = token;
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"AppLoginAccount" accessGroup:nil];
    
    NSDictionary *myDictionary = @{@"password":self.passWord, @"session":self.token};
    [keychainItem setObject:myDictionary forKey:(__bridge id)kSecValueData];
}


-(NSArray *)refreshTagList{
    NSArray *returnList = nil;
    
    
    
    [[RequestObject sharedInstance] sendToServer:@"/api/user/profile/"
                                       parameters:@{@"email":self.userEmail, @"token":self.token}
                                          success:^(NSURLResponse *response, id responseObject, NSError *error) {
                                              if([responseObject objectForKey:@""]){
                                                  
                                              }
                                       } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                                           //
                                       } useAuth:YES];
    
    return returnList;
}

@end
