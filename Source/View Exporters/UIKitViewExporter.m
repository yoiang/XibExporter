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

-(NSString*)multipleExportedFileNameFormat
{
    return @"%@.UIKit.h";
}

-(NSString*)stringValueForEnum:(NSString*)valueKey valueObject:(NSObject*)valueObject
{
    NSString* result = nil;
    if ( [valueObject isKindOfClass:[NSDictionary class] ] )
    {
        NSDictionary* valueDict = (NSDictionary*)valueObject;
        
        NSString* enumValueKey = nil;
        NSRange prefix = [valueKey rangeOfString:@"." options:NSLiteralSearch];
        if (prefix.length == 0)
        {
            enumValueKey = valueKey;
        } else
        {
            enumValueKey = [valueKey substringFromIndex:prefix.location + prefix.length]; // TODO: think about subvalues, shouldn't these be processed in full like anything else?
        }

        result = [self stringValueForEnum:enumValueKey valueObject:[valueDict objectForKey:enumValueKey] ];
    } else if ( [valueObject isKindOfClass:[NSString class] ] )
    {
        result = (NSString*)valueObject;
    }
    
    return result;
}

-(NSString*)stringValueForBoolean:(BOOL)value
{
    NSString* result = nil;
    
    if (value)
    {
        result = @"YES";
    } else
    {
        result = @"NO";
    }
    
    return result;
}

@end
