//
//  NSString+CString.m
//  XibExporter
//
//  Created by Ian on 9/26/13.
//
//

#import "NSString+CString.h"

@implementation NSString (CString)

-(const char*)cString
{
    return [self cStringUsingEncoding:NSUTF8StringEncoding];
}

@end
