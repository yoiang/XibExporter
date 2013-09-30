//
//  NSDictionary+InstanceDefinition.m
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import "NSDictionary+InstanceDefinition.h"

@implementation NSDictionary (InstanceDefinition)

-(NSString*)instanceName
{
    NSString* result = nil;
    
    if ( [self objectForKey:@"instanceName"] )
    {
        result = [self objectForKey:@"instanceName"];
    } else
    {
        //the root view is treated special
        if ( ![self objectForKey:@"superview"] )
        {
            result = @"rootView";
        }
        //if it is normal and has no name, autogenerate the name
        else
        {
            result = nil;
        }
    }
    
    return result;
}

-(BOOL)isOutlet
{
    BOOL result = NO;
    
    if ( [self objectForKey:@"instanceName"] )
    {
        result = YES;
    }
    
    return result;
}

@end
