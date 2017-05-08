//
//  XMNKeychain.m
//  Pods
//
//  Created by XMFraker on 2017/5/8.
//
//

#import "XMNKeychain.h"
#import <Security/Security.h>


static NSString * const kXMNKeychainErrorDomain = @"com.xmfraker.XMNKeychain.kXMNKeychainErrorDomain";
@implementation XMNKeychain

+ (NSData *)getPasswordDataForUserName:(NSString *)username
                           serviceName:(NSString *)serviceName
                                 error:(NSError * _Nullable * _Nullable)error {
    
    /** 1. 判断username, servicename 是否存在 */
    if (!username || !serviceName) {
        if (error) {
            *error = [NSError errorWithDomain:kXMNKeychainErrorDomain code:-2000 userInfo:nil];
        }
        return nil;
    }
    
    /** 2. 设置查询条件 */
    NSDictionary *query = @{
                            (__bridge NSString *)kSecClass : (__bridge NSString *)kSecClassGenericPassword,
                            (__bridge NSString *)kSecAttrAccount : username,
                            (__bridge NSString *)kSecAttrService : serviceName
                            };
    
    /** 3. 先进行attributes查询, 判断是否存在已经存储的password */
    CFDataRef attributeResult = nil;
    NSMutableDictionary *attributeQuery = [query mutableCopy];
    [attributeQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)attributeQuery, (CFTypeRef *)&attributeResult);
    
    if (status != noErr) {
        if (error) {
            /** password 不存在, 或者查询出错, 返回密码未查询到 */
            *error = [NSError errorWithDomain:kXMNKeychainErrorDomain code:status userInfo:nil];
        }
        return nil;
    }
    
    /** 4. 如果password 已经存储, 开始进行密码查询, 更新返回值类型 */
    CFDataRef resultData = nil;
    NSMutableDictionary *passwordQuery = [query mutableCopy];
    [passwordQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)passwordQuery, (CFTypeRef *)&resultData);
    
    /** 5. 如果获取password出错, 返回对应的error */
    if (status != noErr) {
        if (error) {
            *error = [NSError errorWithDomain:kXMNKeychainErrorDomain code:status userInfo:nil];
        }
        return nil;
    }
    
    NSData *passwordData = nil;
    
    if (resultData) {
        passwordData = (__bridge NSData *)(resultData);
    } else if (error) {
        /** 6. 如果password 查询得到, 但是对应的值=nil, 设置返回错误错误码为-1999
         *  用于用户保存password时, 得到对应code, 帮助用户 自定删除存储的password
         */
        *error = [NSError errorWithDomain:kXMNKeychainErrorDomain code:-1999 userInfo:nil];
    }
    
    return passwordData;
}

+ (NSString *)getPasswordStringForUserName:(NSString *)username
                               serviceName:(NSString *)serivceName
                                     error:(NSError * _Nullable * _Nullable)error {
    
    NSData *data = [self getPasswordDataForUserName:username serviceName:serivceName error:error];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

+ (BOOL)storeUserName:(NSString *)username
             password:(NSString *)password
       forServiceName:(NSString *)serviceName
       updateExisting:(BOOL)updateExisting
                error:(NSError * _Nullable * _Nullable)error {
    
    return [self storeUserName:username
                  passwordData:[password dataUsingEncoding:NSUTF8StringEncoding]
                forServiceName:serviceName
                updateExisting:updateExisting
                         error:error];
}

+ (BOOL)storeUserName:(NSString *)username
         passwordData:(NSData *)passwordData
       forServiceName:(NSString *)serviceName
       updateExisting:(BOOL)updateExisting
                error:(NSError * _Nullable * _Nullable)error {
    
    /** 1. 判断username, password servicename 是否为空 */
    if (!username || !passwordData || !serviceName) {
        if (error) {
            *error = [NSError errorWithDomain:kXMNKeychainErrorDomain code:-2000 userInfo:nil];
        }
        
        return NO;
    }
    
    /** 2. 判断当前是否有已经存在的password storedItem */
    NSError *getError = nil;
    NSData *existingPassword = [XMNKeychain getPasswordDataForUserName:username serviceName:serviceName error:&getError];
    
    if ([getError code] == -1999) {

        /** 3. 如果已经存在account,但是password对应值为空, 则删除已经存在的password存储 */
        getError = nil;
        [self deleteStoredItemForUserName:username serviceName:serviceName error:&getError];
        if ([getError code] != noErr) {
            if (error) {
                *error = getError;
            }
            return NO;
        }
    } else if (getError.code == errSecItemNotFound) {
        /** 未查询到对应的secItem */
    } else if ([getError code] != noErr) {
        /** 4. 判断是否应存在失败, 直接返回错误 */
        if (error) {
            *error = getError;
        }
        return NO;
    }
    
    OSStatus status = noErr;
    
    if (existingPassword) {

        /** 5. 如果已存在的passwordData == existingPasswordData 则直接返回success */
        if ([existingPassword isEqualToData:passwordData]) {
            status = noErr;
        }else if (updateExisting) {

            NSArray *keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass,
                             kSecAttrService,
                             kSecAttrLabel,
                             kSecAttrAccount,
                             nil];
            
            NSArray *objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword,
                                serviceName,
                                serviceName,
                                username,
                                nil];
            
            NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
            
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObject:passwordData forKey:(__bridge NSString *)kSecValueData]);
        }else {
            status = errSecDuplicateItem;
        }
    } else {
        /** 6. 如果不需要强制更新, 则只有existingPassword 不存在时, 执行存储操作 */
        NSArray *keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass,
                         kSecAttrService,
                         kSecAttrLabel,
                         kSecAttrAccount,
                         kSecValueData,
                         nil];
        
        NSArray *objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword,
                            serviceName,
                            serviceName,
                            username,
                            passwordData,
                            nil];
        
        NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        
        status = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
    }
    
    if (status != noErr) {
        /** 7. 判断存储操作是否成功 */
        if (error) {
            *error = [NSError errorWithDomain:kXMNKeychainErrorDomain code:status userInfo:nil];
        }
        return NO;
    }
    
    return YES;
}

+ (BOOL)deleteStoredItemForUserName:(NSString *)username
                        serviceName:(NSString *)serviceName
                              error:(NSError * _Nullable * _Nullable)error {
    
    if (!username || !serviceName) {
        if (error) {
            *error = [NSError errorWithDomain:kXMNKeychainErrorDomain code:-2000 userInfo:nil];
        }
        return NO;
    }
    
    NSArray *keys = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClass, kSecAttrAccount, kSecAttrService, kSecReturnAttributes, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:(__bridge NSString *)kSecClassGenericPassword, username, serviceName, kCFBooleanTrue, nil];
    NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef) query);
    
    if (status != noErr) {
        if (error) {
            *error = [NSError errorWithDomain:kXMNKeychainErrorDomain code:status userInfo:nil];
        }
        return NO;
    }
    return YES;
}
@end
