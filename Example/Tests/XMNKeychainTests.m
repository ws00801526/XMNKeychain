//
//  XMNKeychainTests.m
//  XMNKeychain
//
//  Created by XMFraker on 2017/5/8.
//  Copyright © 2017年 ws00801526. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <XMNKeychain/XMNKeychain.h>


static NSString * const kXMNKeychainServiceName = @"com.xmfraker.WelfareMall";
@interface XMNKeychainTests : XCTestCase

@end

@implementation XMNKeychainTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testKeychain {
    
    /** 1. 删除已经存在的password */
    [XMNKeychain deleteStoredItemForUserName:@"13761155558" serviceName:kXMNKeychainServiceName error:nil];

    NSError *error;
    NSString *password = [XMNKeychain getPasswordStringForUserName:@"13761155558" serviceName:kXMNKeychainServiceName error:&error];
    /** 2. 当前password 并未存储, 取出应该为nil */
    XCTAssertNil(password);
    XCTAssertNotNil(error);
    
    error = nil;
    /** 3. 首次保存 不强制更新
     *  如果已经存在对应password, 则saveSuccess = NO;
     *
     **/
    BOOL saveSuccess = [XMNKeychain storeUserName:@"13761155558"
                                         password:@"123456l"
                                   forServiceName:kXMNKeychainServiceName
                                   updateExisting:NO
                                            error:&error];
    XCTAssertTrue(saveSuccess);
    
    /** 4. 再次获取 */
    password = [XMNKeychain getPasswordStringForUserName:@"13761155558"
                                             serviceName:kXMNKeychainServiceName
                                                   error:&error];
    XCTAssertTrue(password && password.length && [password isEqualToString:@"123456l"]);
    
    
    /** 5. 重新保存, 强制更新已经存在的*/
    saveSuccess = [XMNKeychain storeUserName:@"13761155558"
                                    password:@"12345678l"
                              forServiceName:kXMNKeychainServiceName
                              updateExisting:YES
                                       error:&error];
    XCTAssertTrue(saveSuccess);

    /** 6. 再次获取 */
    password = [XMNKeychain getPasswordStringForUserName:@"13761155558"
                                             serviceName:kXMNKeychainServiceName
                                                   error:&error];
    XCTAssertTrue(password && password.length && [password isEqualToString:@"12345678l"]);

    
    /** 7. 重新保存, 不强制更新已经存在的*/
    saveSuccess = [XMNKeychain storeUserName:@"13761155558"
                                    password:@"123456l"
                              forServiceName:kXMNKeychainServiceName
                              updateExisting:NO
                                       error:&error];
    XCTAssertFalse(saveSuccess);

    
    /** 8. 测试删除 */
    BOOL deleteSuccess = [XMNKeychain deleteStoredItemForUserName:@"13761155558"
                                                      serviceName:kXMNKeychainServiceName
                                                            error:&error];
    XCTAssertTrue(deleteSuccess);
}

@end
