//
//  ViewController.m
//  RunTimeDemo
//
//  Created by xietao on 16/4/20.
//  Copyright © 2016年 xietao3. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>

#define SelfClass [self class]

@interface ViewController ()
@property (nonatomic, strong) Person *person;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initial];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialize
- (void)initial{
    _person = [[Person alloc] init];
    _person.name = @"xietao";
    _person.age = @"18";
    _person.gender = @"male";
    _person.city = @"shanghai";
    
    [self logRunTimeAction:nil];
}

#pragma mark - IBAction
- (IBAction)logRunTimeAction:(id)sender {
    

    [self class_getClassName:SelfClass];
    [self class_getSuperClass:SelfClass];
    [self class_getInstanceSize:SelfClass];
    [self class_getInstanceVariable:SelfClass name:"_person"];
    [self class_getClassVariable:SelfClass name:"Person"];
    [self class_getInstanceMethod:SelfClass selector:@selector(class_getInstanceMethod:selector:)];
    [self.class class_getClassMethod:SelfClass selector:@selector(class_getClassMethod:selector:)];
    [self class_getProperty:SelfClass name:"person"];
    [self class_getMethodImplementation:SelfClass selector:@selector(class_getMethodImplementation:selector:)];
    [self class_getMethodImplementation_stret:SelfClass selector:@selector(class_getMethodImplementation_stret:selector:)];
    [self class_copyIvarList:[_person class]];
    [self class_copyPropertyList:[_person class]];
    [self class_copyMethodList:[_person class]];
    [self class_copyProtocolList:[_person class]];
//    [self class_addIvar:nil name:nil size:nil alignment:nil types:nil];
    [self class_addProperty:[_person class] name:"country" attributes:nil attributeCount:3];
    [self class_addMethod:SelfClass selector:NSSelectorFromString(@"runtimeTestMethod:") imp:nil types:"v@:@"];
    [self class_addProtocol:[_person class] protocol:@protocol(RuntimeBaseProtocol)];
    [self class_replaceProperty:[_person class] name:"country" attributes:nil attributeCount:3];
    [self class_replaceMethod:[_person class] selector:@selector(runtimeTestAction1) imp:class_getMethodImplementation([_person class], @selector(runtimeTestAction2)) types:"v@:"];
    [self class_respondsToSelector:[_person class] selector:@selector(runtimeTestAction1)];
    [self class_isMetaClass:object_getClass(self.superclass)];
    [self class_conformsToProtocol:[_person class] protocol:NSProtocolFromString(@"RuntimeBaseProtocol")];
    [self class_createInstance:[_person class] extraBytes:class_getInstanceSize([_person class])];
    
    [self object_getInstanceVariable:_person name:"_name" outValue:nil];
    [self object_getClassName:_person];
    [self object_getClass:_person];
    [self objc_getClass:"Person"];
    [self objc_getMetaClass:"Person"];
    [self object_copy:_person size:class_getInstanceSize([_person class])];

}


#pragma mark - Class 创建
- (void)class_createInstance:(Class)class extraBytes:(size_t)extraBytes {
    Person *tempPerson = class_createInstance(class, extraBytes);
    tempPerson.name = @"instance creat Success";
    NSLog(@"%s%@",__func__,tempPerson.name);
}

#pragma mark - Class 类名，父类，元类；实例变量，成员变量；属性；实例方法，类方法，方法实现；
/**
 *  获取类的类名
 *
 *  @param class 类
 */
- (void)class_getClassName:(Class)class {
    NSLog(@"%s:%s",__func__,class_getName(class));
}

/**
 *  获取类的父类
 *
 *  @param class 类
 */
- (void)class_getSuperClass:(Class)class {
    NSLog(@"%s%@",__func__,NSStringFromClass(class_getSuperclass(class)));
}

/**
 *  获取实例大小
 *
 *  @param class 类
 */
- (void)class_getInstanceSize:(Class)class {
    NSLog(@"%s%zu",__func__,class_getInstanceSize(class));
}

/**
 *  获取类中指定名称实例成员变量的信息
 *
 *  @param class 类
 *  @param name  成员变量名
 */
- (void)class_getInstanceVariable:(Class)class name:(const char *)name {
    Ivar ivar = class_getInstanceVariable(class,name);
    NSLog(@"%s%s%s",__func__,ivar_getTypeEncoding(ivar),ivar_getName(ivar));
}

/**
 *  获取类成员变量的信息（该函数没有作用，官方解释:http://lists.apple.com/archives/objc-language/2008/Feb/msg00021.html
 *
 *  @param class 类
 *  @param name  成员变量名
 */
- (void)class_getClassVariable:(Class)class name:(const char *)name {
    Ivar ivar = class_getClassVariable(class,name);
    NSLog(@"%s%s%s",__func__,ivar_getTypeEncoding(ivar),ivar_getName(ivar));
}

/**
 *  获取属性的信息(与获取成员变量信息类似，不同的是不用打_)
 *
 *  @param class 类
 *  @param name  属性名
 */
- (void)class_getProperty:(Class)class name:(const char *)name {
    objc_property_t property = class_getProperty(class,name);
    NSLog(@"%s%s%s",__func__,property_getName(property) ,property_getAttributes(property));
}

/**
 *  获取类制定方法的信息
 *
 *  @param class    类
 *  @param selector 方法
 */
- (void)class_getInstanceMethod:(Class)class selector:(SEL)selector {
    Method method = class_getInstanceMethod(class, selector);
    // 估计参数数量多出来的2个是调用的对象和selector
    NSLog(@"%s%s%u",__func__,sel_getName(method_getName(method)) ,method_getNumberOfArguments(method));
}

/**
 *  获取类方法的信息
 *
 *  @param class    类
 *  @param selector 方法
 */
+ (void)class_getClassMethod:(Class)class selector:(SEL)selector {
    Method method = class_getClassMethod(class, selector);
    NSLog(@"%s%s%u",__func__,sel_getName(method_getName(method)) ,method_getNumberOfArguments(method));
}

/**
 *  获取方法具体实现
 *
 *  @param class    类
 *  @param selector 方法
 *
 *  @return IMP
 */
- (IMP)class_getMethodImplementation:(Class)class selector:(SEL)selector {
    IMP imp = class_getMethodImplementation(class, selector);
    return imp;
}

/**
 *  获取类中的方法的实现,该方法的返回值类型为struct
 *
 *  @param class    类
 *  @param selector 方法
 *
 *  @return IMP
 */
- (IMP)class_getMethodImplementation_stret:(Class)class selector:(SEL)selector {
    IMP imp = class_getMethodImplementation_stret(class, selector);
    return imp;
}

#pragma mark - Class 成员变量列表；属性列表；方法列表；协议列表；
/**
 *  获取成员变量列表
 *
 *  @param class 类
 */
- (void)class_copyIvarList:(Class)class {
    unsigned int count;
    Ivar *ivarList = class_copyIvarList(class, &count);
    NSLog(@"%s",__func__);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        // 获取成员属性名
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        NSLog(@"%@%@",type,name);
    }
}

- (void)class_copyPropertyList:(Class)class {
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList(class,&count);
    NSLog(@"%s",__func__);
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        // 获取成员属性名
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        NSString *type = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSLog(@"%@%@",type,name);
    }
}

/**
 *  获取方法列表
 *
 *  @param class 类
 */
- (void)class_copyMethodList:(Class)class {
    unsigned int count;
    Method *methodList = class_copyMethodList(class,&count);
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSLog(@"%s%s",__func__,sel_getName(method_getName(method)));
    }
}

/**
 *  获取协议列表
 *
 *  @param class 类
 */
- (void)class_copyProtocolList:(Class)class {
    unsigned int count;
    Protocol **protocolList = class_copyProtocolList(class,&count);
    for (int i = 0; i < count; i++) {
        Protocol *protocol = protocolList[i];
        NSLog(@"%s%s",__func__,protocol_getName(protocol));
    }
}

#pragma mark - Class add: 成员变量；属性；方法；协议
/**
 *  添加成员变量(添加成员变量只能在运行时创建的类，且不能为元类)
 *
 *  @param class     类
 *  @param name      成员变量名字
 *  @param size      大小
 *  @param alignment 对其方式
 *  @param types     参数类型
 */
- (void)class_addIvar:(Class)class name:(const char *)name size:(size_t)size alignment:(uint8_t)alignment types:(const char *)types {

//    if (class_addIvar([_person class], "country", sizeof(NSString *), 0, "@")) {
    if (class_addIvar(class, name, size, alignment, types)) {

        NSLog(@"%sadd ivar success",__func__);
    }else{
        NSLog(@"%sadd ivar fail",__func__);
    }
}

/**
 *  添加属性
 *
 *  @param class          类
 *  @param name           属性名
 *  @param attributes     参数
 *  @param attributeCount 参数数量
 */
- (void)class_addProperty:(Class)class name:(const char *)name attributes:(const objc_property_attribute_t *)attributes attributeCount:(unsigned int)attributeCount {
    objc_property_attribute_t type = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "&", "N" }; // C = copy
    objc_property_attribute_t backingivar  = { "V", "" };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };

    if (class_addProperty(class, name, attrs, attributeCount)) {
        NSLog(@"%sadd Property success",__func__);
    }else{
        NSLog(@"%sadd Property fail",__func__);
    }
//    [self class_copyPropertyList:class];
}

/**
 *  添加方法
 *
 *  @param class    类
 *  @param selector 方法
 *  @param imp      方法实现
 *  @param types    类型
 */
- (void)class_addMethod:(Class)class selector:(SEL)selector imp:(IMP)imp types:(const char *)types {
    if (class_addMethod(class,selector,class_getMethodImplementation(class, selector),types)) {
        NSLog(@"%sadd method success",__func__);
    }else{
        NSLog(@"%sadd method fail",__func__);
    }
//    [self class_copyMethodList:class];

}

/**
 *  添加协议
 *
 *  @param class    类
 *  @param protocol 协议
 */
- (void)class_addProtocol:(Class)class protocol:(Protocol *)protocol {
    if (class_addProtocol(class, protocol)) {
        NSLog(@"%sadd protocol success",__func__);
    }else{
        NSLog(@"%sadd protocol fail",__func__);
    }
//    [self class_copyProtocolList:class];
}


#pragma marl - Class replace：属性；方法
/**
 *  替换属性的信息(如果没有原属性会新建一个属性)
 *
 *  @param class          类
 *  @param name           属性名
 *  @param attributes     类型
 *  @param attributeCount 类型数量
 */
- (void)class_replaceProperty:(Class)class name:(const char *)name attributes:(const objc_property_attribute_t *)attributes attributeCount:(unsigned int)attributeCount {
    objc_property_attribute_t type = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backingivar  = { "V", "" };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };

    class_replaceProperty(class, name, attrs, 3);
//    [self class_copyPropertyList:class];

}

/**
 *  替代方法的实现
 *
 *  @param class    类
 *  @param selector 被替代的方法
 *  @param imp      替代方法
 *  @param types    类型
 */
- (void)class_replaceMethod:(Class)class selector:(SEL)selector imp:(IMP)imp types:(const char *)types {
    class_replaceMethod(class, selector, imp, types);
    NSLog(@"%s",__func__);
    [_person runtimeTestAction1];
}

#pragma mark - Class 判断
/**
 *  查看类是否相应指定方法
 *
 *  @param class    类
 *  @param selector 方法
 */
- (void)class_respondsToSelector:(Class)class selector:(SEL)selector {
    if (class_respondsToSelector(class,selector)) {
        NSLog(@"%s %@ exist",__func__,NSStringFromClass(class));
    }else{
        NSLog(@"%s %@ non-exist",__func__,NSStringFromClass(class));
    }
}

/**
 *  查看类是否为元类
 *
 *  @param class 类
 */
- (void)class_isMetaClass:(Class)class {
    if (class_isMetaClass(class)) {
        NSLog(@"%s %@ isMetaClass",__func__,NSStringFromClass(class));
    }else{
        NSLog(@"%s %@ non-isMetaClass",__func__,NSStringFromClass(class));
    }
}

/**
 *  查看类是否遵循指定协议
 *
 *  @param class    类
 *  @param protocol 协议
 */
- (void)class_conformsToProtocol:(Class)class protocol:(Protocol *)protocol {
    if (class_conformsToProtocol(class, protocol)) {
        NSLog(@"%s %@ conformsToProtocol %@",__func__,NSStringFromClass(class),NSStringFromProtocol(protocol));
    }else{
        NSLog(@"%s %@ non-conformsToProtocol %@",__func__,NSStringFromClass(class),NSStringFromProtocol(protocol));
    }
}


#pragma mark - Objc get: 实例变量；成员变量；类名；类；元类；关联对象
/**
 *  获取实例的成员变量
 *
 *  @param obj      对象
 *  @param name     成员变量名
 *  @param outValue 输出值
 */
- (void)object_getInstanceVariable:(id)obj name:(const char*)name outValue:(void **)outValue{
    Ivar ivar = object_getInstanceVariable(obj, name, nil);
    NSLog(@"%s personName %@",__func__,[self object_getIvar:obj ivar:ivar]);
}

/**
 *  获取成员变量的值
 *
 *  @param obj  对象
 *  @param ivar 成员变量
 *
 *  @return 值
 */
- (id)object_getIvar:(id)obj ivar:(Ivar)ivar {
    return object_getIvar(obj, ivar);
}

/**
 *  获取指定对象的类名
 *
 *  @param obj 对象
 */
- (void)object_getClassName:(id)obj {
    NSLog(@"%s%s",__func__,object_getClassName(obj));
}

/**
 *  获取指定对象的类
 *
 *  @param obj 对象
 */
- (void)object_getClass:(id)obj {
    NSLog(@"%s%@",__func__,NSStringFromClass(object_getClass(obj)));
}

/**
 *  获取指定类名的类
 *
 *  @param name 类名
 */
- (void)objc_getClass:(const char *)name {
    NSLog(@"%s%@",__func__,NSStringFromClass(objc_getClass(name)));
}

/**
 *  <#Description#>
 *
 *  @param name <#name description#>
 */
- (void)objc_getMetaClass:(const char *)name {
    NSLog(@"%s%@",__func__,NSStringFromClass(objc_getMetaClass(name)));

}

/**
 *  拷贝指定对象
 *
 *  @param obj  对象
 *  @param size 实例大小
 */
- (void)object_copy:(id)obj size:(size_t)size {
    Person *tempObj = object_copy(obj, size);
    tempObj.name = @"tempxietao";
    NSLog(@"%s tempPersonName:%@ personName:%@",__func__,tempObj.name,_person.name);
}


- (void)objc_getAssociatedObject:(id)obj key:(const void *)key {
    id object = objc_getAssociatedObject(obj,key);
    NSLog(@"%s%s%@",__func__,object_getClassName(obj),object);
}








@end
