//
//  XMNKeychain.h
//  Pods
//
//  Created by XMFraker on 2017/5/8.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMNKeychain : NSObject


/**
 获取对应username,service 保存的通用passwordData

 @param username            保存用户名
 @param serivceName         保存的服务名
 @param error               返回的错误
 @return   NSData or nil
 */
+ (nullable NSData *)getPasswordDataForUserName:(NSString *)username
                                    serviceName:(NSString *)serivceName
                                          error:(inout NSError * _Nullable * _Nullable)error;


/**
 获取对应username,service 保存的通用password 字符串
 
 @param username            保存用户名
 @param serivceName         保存的服务名
 @param error               返回的错误
 @return   NSString or nil
 */
+ (nullable NSString *)getPasswordStringForUserName:(NSString *)username
                                        serviceName:(NSString *)serivceName
                                              error:(inout NSError * _Nullable * _Nullable)error;

/**
 保存对应的 username,servicename,password

 @param username          需要保存的username
 @param password          需要保存的password
 @param serviceName       需要保存的servicename
 @param updateExisting    是否更新已经存在的
 @param error             错误error
 @return    YES or NO
 */
+ (BOOL)storeUserName:(NSString *)username
             password:(NSString *)password
       forServiceName:(NSString *)serviceName
       updateExisting:(BOOL)updateExisting
                error:(inout NSError * _Nullable * _Nullable)error;

/**
 保存对应的 username,servicename,passwordData
 
 @param username          需要保存的username
 @param passwordData      需要保存的passwordData
 @param serviceName       需要保存的servicename
 @param updateExisting    是否更新已经存在的
 @param error             错误error
 @return    YES or NO
 */
+ (BOOL)storeUserName:(NSString *)username
         passwordData:(NSData *)passwordData
       forServiceName:(NSString *)serviceName
       updateExisting:(BOOL)updateExisting
                error:(inout NSError * _Nullable * _Nullable)error;


/**
 删除已经存在的username,password

 @param username            需要删除的username
 @param serviceName         需要删除的servicename
 @param error               抛出的错误error
 @return    YES or NO
 */
+ (BOOL)deleteStoredItemForUserName:(NSString *)username
                        serviceName:(NSString *)serviceName
                              error:(inout NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
