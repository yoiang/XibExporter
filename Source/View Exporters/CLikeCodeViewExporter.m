//
//  CLikeCodeViewExporter.m
//  XibExporter
//
//  Created by Ian on 10/4/13.
//
//

#import "CLikeCodeViewExporter.h"

#import "CodeMap.h"
#import "NSDictionary+ClassDefinition.h"
#import "NSDictionary+InstanceDefinition.h"

@implementation CLikeCodeViewExporter

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

@end
