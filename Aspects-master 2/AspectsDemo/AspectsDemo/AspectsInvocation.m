//
//  AspectsInvocation.m
//  AspectsDemo
//
//  Created by Start on 2018/8/22.
//  Copyright © 2018年 PSPDFKit GmbH. All rights reserved.
//

#import "AspectsInvocation.h"
#import <objc/message.h>
@implementation AspectsInvocation
-(void)test
{
    //获取方法签名
    NSMethodSignature *sigOfPrintStr = [self methodSignatureForSelector:@selector(printStr:)];
    //获取方法签名对应的invocation
    NSInvocation *invocationPrint = [NSInvocation invocationWithMethodSignature:sigOfPrintStr];
    //设置消息的接收者
    [invocationPrint setTarget:self];
    [invocationPrint setSelector:@selector(printStr:)];
    //设置参数
    //对NSInvocation对象设置的参数个数及类型和获取的返回值的类型要与创建对象时使用的NSMethodSignature对象代表的参数及返回值类型向一致，否则
    NSString *str = @"helloWord" ;
    [invocationPrint setArgument:&str atIndex:2];
    [invocationPrint invoke];
    
    
    //Block调用方式
    void(^block1)(int) = ^(int a)
    {
        NSLog(@"block1 %d",a);
    };
    
    NSMethodSignature *signature = aspect_blockMethodSignature(block1,nil);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:block1];
    int a=2;
    //由block生成的NSInvocation对象的第一个参数是block本身，剩下的为 block自身的参数。
    [invocation setArgument:&a atIndex:1];
    [invocation invoke];
    

}

-(void)test1
{
    /*
     1.为class pair 分配空间。使用objc_allocateClassPair
     2.为创建的类添加方法和成员
     3.注册你创建的类使其可用。
     */
//    Class person = objc_getClass("Person");
//    NSLog(@"%@",person);
    
    Class newClass = objc_allocateClassPair([NSError class], "RunTimeErrorSubClass", 0);
    class_addMethod(newClass, @selector(report), (IMP)reportFunction, "v@:");
    objc_registerClassPair(newClass);
    [[newClass new]report];
}
-(void)report
{
   /*
    OC中一个对象所属于哪个类，是由它的isa指针指向的。这个isa指针指向这个对象所属的class。
    消息响应: 运行时库会根据对象的isa指针找到这个对象所属的类，这个类包含一个所有实例方法的列表及一个指向
    superClass的指针以便可以找到父类的实例方法。运行时库会在类的方法列表以及父类们的方法列表中查找。
    */
    /*
     struct objc_class {
     Class isa; // 指向metaclass
     
     Class super_class ; // 指向其父类
     const char *name ; // 类名
     long version ; // 类的版本信息，初始化默认为0，可以通过runtime函数class_setVersion和class_getVersion进行修改、读取
     long info; // 一些标识信息,如CLS_CLASS (0x1L) 表示该类为普通 class ，其中包含对象方法和成员变量;CLS_META (0x2L) 表示该类为 metaclass，其中包含类方法;
     long instance_size ; // 该类的实例变量大小(包括从父类继承下来的实例变量);
     struct objc_ivar_list *ivars; // 用于存储每个成员变量的地址
     struct objc_method_list **methodLists ; // 与 info 的一些标志位有关,如CLS_CLASS (0x1L),则存储对象方法，如CLS_META (0x2L)，则存储类方法;
     struct objc_cache *cache; // 指向最近使用的方法的指针，用于提升效率；
     struct objc_protocol_list *protocols; // 存储该类遵守的协议
     }
     meta-Class 元类 一个类对象的类。
     当你向一个对象发送消息时，runtime会在这个对象所属的那个类的方法列表中查找。
     当你向一个类发送消息时,runtime会在这个类的meta-Class方法列表中查找。元类之所以重要是因为它存储
     这一个类的所有类方法。每个类都会有有一个单独的meta-Class，因为每个类的类方法基本不可能完全相同。
     一个类使用super_class 指针指向自己的父类一样。
     meta-Class的super_class会指向类的super_class的meta-class.
     
     用object_getClass来获取isa指针指向的类
     meta-class 是类对象的类，每个类都有自己单独的meta-class
     */
}
void reportFunction(id self,SEL _cmd)
{
    NSLog(@"this is Object is %p",self);
}


-(void)printStr:(NSString *)str
{
    NSLog(@"打印%@",str);
}
//代码来自 Aspect
// Block internals.
typedef NS_OPTIONS(int, AspectBlockFlags) {
    AspectBlockFlagsHasCopyDisposeHelpers = (1 << 25),
    AspectBlockFlagsHasSignature          = (1 << 30)
};
typedef struct _AspectBlock {
    __unused Class isa;
    AspectBlockFlags flags;
    __unused int reserved;
    void (__unused *invoke)(struct _AspectBlock *block, ...);
    struct {
        unsigned long int reserved;
        unsigned long int size;
        // requires AspectBlockFlagsHasCopyDisposeHelpers
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
        // requires AspectBlockFlagsHasSignature
        const char *signature;
        const char *layout;
    } *descriptor;
    // imported variables
} *AspectBlockRef;


static NSMethodSignature *aspect_blockMethodSignature(id block, NSError **error) {
    AspectBlockRef layout = (__bridge void *)block;
    if (!(layout->flags & AspectBlockFlagsHasSignature)) {
        //NSString *description = [NSString stringWithFormat:@"The block %@ doesn't contain a type signature.", block];
        //AspectError(AspectErrorMissingBlockSignature, description);
        return nil;
    }
    void *desc = layout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (layout->flags & AspectBlockFlagsHasCopyDisposeHelpers) {
        desc += 2 * sizeof(void *);
    }
    if (!desc) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't has a type signature.", block];
        //AspectError(AspectErrorMissingBlockSignature, description);
        return nil;
    }
    const char *signature = (*(const char **)desc);
    return [NSMethodSignature signatureWithObjCTypes:signature];
}




@end
