//
//  MethodSwizzler.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MethodSwizzler.h"
//#import </usr/include/objc/objc-class.h>
#import <objc/runtime.h>

@implementation MethodSwizzler

+ (BOOL) swizzleClass   :(Class) aClass methodA:(SEL)os methodB:(SEL)as
{
    Method om = class_getClassMethod(aClass, os);
    Method am = class_getClassMethod(aClass, as);
    if (om && am)
    {
        method_exchangeImplementations(om, am);
    }
    else
    {
        NSLog(@"Couldn't swizzle! %@ %@",om,am);
        return NO;
    }
    
    return YES;
}

+ (BOOL) swizzleInstance:(Class) aClass methodA:(SEL)os methodB:(SEL)as
{
    Method om = class_getInstanceMethod(aClass, os);
    Method am = class_getInstanceMethod(aClass, as);
    if (om && am)
    {
        method_exchangeImplementations(om, am);
    }
    else
    {
        NSLog(@"Couldn't swizzle! %@ %@",om,am);
        return NO;
    }
    return YES;
}

@end
