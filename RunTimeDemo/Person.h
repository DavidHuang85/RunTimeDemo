//
//  Person.h
//  RunTimeDemo
//
//  Created by xietao on 16/4/20.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RuntimeBaseProtocol <NSObject>
@property (nonatomic, strong) NSString *protocolString;
@optional

- (void)doBaseAction;

@end

@protocol RuntimeProtocol <NSObject,RuntimeBaseProtocol>

@optional

- (void)doOptionalAction;

@end

@interface Person : NSObject<RuntimeProtocol>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *city;


- (void)runtimeTestAction1;

- (void)runtimeTestAction2;

- (void)runtimeTestAction3;

@end
