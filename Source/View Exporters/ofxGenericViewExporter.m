//
//  ofxGenericViewExporter.m
//  XibExporter
//
//  Created by Ian on 9/17/13.
//
//

#import "ofxGenericViewExporter.h"

@implementation ofxGenericViewExporter

-(NSString*)factoryKey
{
    return @"ofxGeneric";
}

-(NSString*)codeMapJSONDefinitionFileName
{
    return @"ofxGenericDefinition";
}

-(NSString*)multipleExportedFileNameFormat
{
    return @"%@.ofxGeneric.h";
}

-(NSString*)stringValueForFloat:(float)value
{
    NSString* result = nil;
    
    int intValue = floor(value);
    if (value - intValue == 0)
    {
        result = [NSString stringWithFormat:@"%d.0f",intValue];
    }
    else
    {
        result = [NSString stringWithFormat:@"%ff",value];
    }
    
    return result;
}

-(NSString*)stringValueForBoolean:(BOOL)value
{
    NSString* result = nil;
    
    if (value)
    {
        result = @"true";
    } else
    {
        result = @"false";
    }
    
    return result;
}

@end