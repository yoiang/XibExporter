//
//  NSDictionary+InstanceDefinition.m
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import "NSDictionary+InstanceDefinition.h"

#import "NSDictionary+Path.h"
#import "NSDictionary+TypeForKey.h"

@implementation NSDictionary (InstanceDefinition)

-(NSString*)instanceName
{
    NSString* result = nil;
    
    if ( [self objectForKey:NSDictionary_InstanceDefinition_InstanceNameKey] )
    {
        result = [self stringForKey:NSDictionary_InstanceDefinition_InstanceNameKey];
    } else
    {
        //the root view is treated special
        if ( [self isRootView] )
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
    
    if ( [self stringForKey:NSDictionary_InstanceDefinition_InstanceNameKey] )
    {
        result = YES;
    }
    
    return result;
}

-(BOOL)hasValueForMember:(NSString*)memberName
{
    return [self objectAtPath:memberName withPathSeparator:@"."] != nil;
}

-(NSArray*)comments
{
    return [self arrayForKey:NSDictionary_InstanceDefinition_CommentsKey];
}

// TODO: why not ref the superview directly
-(NSNumber*)superViewId
{
    return [self numberForKey:@"superview"];
}

-(BOOL)isRootView
{
    return [self superViewId] == nil;
}

-(NSArray*)subviews
{
    return [self arrayForKey:NSDictionary_InstanceDefinition_SubviewsKey];
}

@end
