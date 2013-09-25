//
//  UIKitViewExporter.m
//  XibExporter
//
//  Created by Ian on 9/24/13.
//
//

#import "UIKitViewExporter.h"

@implementation UIKitViewExporter

-(NSString*)factoryKey
{
    return @"UIKit";
}

-(NSString*)codeMapJSONDefinitionFileName
{
    return @"UIKitDefinition";
}

-(NSString*)valueForEnum:(NSString*)valueKey valueObject:(NSObject*)valueObject
{
    NSString* result = nil;
    if ( [valueObject isKindOfClass:[NSDictionary class] ] )
    {
        NSDictionary* valueDict = (NSDictionary*)valueObject;
        result = [self valueForEnum:valueKey valueObject:[valueDict objectForKey:valueKey] ];
    } else if ( [valueObject isKindOfClass:[NSString class] ] )
    {
        result = (NSString*)valueObject;
    }
    
    return result;
}

@end
