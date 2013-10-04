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