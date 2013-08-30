//
//  MethodSwizzler.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MethodSwizzler : NSObject

+ (BOOL) swizzleClass   :(Class) aClass methodA:(SEL)os methodB:(SEL)as;
+ (BOOL) swizzleInstance:(Class) aClass methodA:(SEL)os methodB:(SEL)as;

@end
