//
//  Aspects.h
//  Aspects - A delightful, simple library for aspect oriented programming.
//
//  Copyright (c) 2014 Peter Steinberger. Licensed under the MIT license.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, AspectOptions) {
    AspectPositionAfter   = 0,            /// Called after the original implementation (default)
    AspectPositionInstead = 1,            /// Will replace the original implementation.
    AspectPositionBefore  = 2,            /// Called before the original implementation.
    
    AspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

/// Opaque Aspect Token that allows to deregister the hook.
//定义了一个AspectToken的协议，这里的AspectToken是隐式的，允许我们调用remove去撤销一个hook。remove方法返回YES代表撤销成功，返回NO就撤销失败。
@protocol AspectToken <NSObject>

/// Deregisters an aspect.
/// @return YES if deregistration is successful, otherwise NO.
- (BOOL)remove;

@end

/// The AspectInfo protocol is the first parameter of our block syntax.
//AspectInfo protocol是我们block语法里面的第一个参数。
@protocol AspectInfo <NSObject>
//instance方法返回当前被hook的实例
/// The instance that is currently hooked.
- (id)instance;
//originalInvocation方法返回被hooked方法的原始的invocation
/// The original invocation of the hooked method.
- (NSInvocation *)originalInvocation;
//arguments方法返回所有方法的参数。它的实现是懒加载。
/// All method arguments, boxed. This is lazily evaluated.
- (NSArray *)arguments;

@end
/*
 Aspects利用的OC的消息转发机制，hook消息。这样会有一些性能开销。不要把Aspects加到经常被使用的方法里面。Aspects是用来设计给view/controller 代码使用的，而不是用来hook每秒调用1000次的方法的。
 
 添加Aspects之后，会返回一个隐式的token，这个token会被用来注销hook方法的。所有的调用都是线程安全的
 */
/**
 Aspects uses Objective-C message forwarding to hook into messages. This will create some overhead. Don't add aspects to methods that are called a lot. Aspects is meant for view/controller code that is not called a 1000 times per second.

 Adding aspects returns an opaque token which can be used to deregister again. All calls are thread safe.
 */

/*
 Aspects整个库里面就只有这两个方法。这里可以看到，Aspects是NSobject的一个extension，只要是NSObject，都可以使用这两个方法。这两个方法名字都是同一个，入参和返回值也一样，唯一不同的是一个是加号方法一个是减号方法。一个是用来hook类方法，一个是用来hook实例方法。
 方法里面有4个入参。第一个selector是要给它增加切面的原方法。第二个参数是AspectOptions类型，是代表这个切片增加在原方法的before / instead / after。第4个参数是返回的错误。
 
 重点的就是第三个入参block。这个block复制了正在被hook的方法的签名signature类型。block遵循AspectInfo协议。我们甚至可以使用一个空的block。AspectInfo协议里面的参数是可选的，主要是用来匹配block签名的。
 
 返回值是一个token，可以被用来注销这个Aspects
 */
@interface NSObject (Aspects)
// hook 类方法
/// Adds a block of code before/instead/after the current `selector` for a specific class.
///
/// @param block Aspects replicates the type signature of the method being hooked.
/// The first parameter will be `id<AspectInfo>`, followed by all parameters of the method.
/// These parameters are optional and will be filled to match the block signature.
/// You can even use an empty block, or one that simple gets `id<AspectInfo>`.
///
/// @note Hooking static methods is not supported.
/// @return A token which allows to later deregister the aspect.
+ (id<AspectToken>)aspect_hookSelector:(SEL)selector
                           withOptions:(AspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;
// hook 实例方法
/// Adds a block of code before/instead/after the current `selector` for a specific instance.
- (id<AspectToken>)aspect_hookSelector:(SEL)selector
                           withOptions:(AspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

@end


typedef NS_ENUM(NSUInteger, AspectErrorCode) {
    AspectErrorSelectorBlacklisted,                   /// Selectors like release, retain, autorelease are blacklisted.
    AspectErrorDoesNotRespondToSelector,              /// Selector could not be found.
    AspectErrorSelectorDeallocPosition,               /// When hooking dealloc, only AspectPositionBefore is allowed.
    AspectErrorSelectorAlreadyHookedInClassHierarchy, /// Statically hooking the same method in subclasses is not allowed.
    AspectErrorFailedToAllocateClassPair,             /// The runtime failed creating a class pair.
    AspectErrorMissingBlockSignature,                 /// The block misses compile time signature info and can't be called.
    AspectErrorIncompatibleBlockSignature,            /// The block signature does not match the method or is too large.

    AspectErrorRemoveObjectAlreadyDeallocated = 100   /// (for removing) The object hooked is already deallocated.
};

extern NSString *const AspectErrorDomain;
