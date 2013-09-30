//
//  NSDictionary+ClassDefinition.m
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import "NSDictionary+ClassDefinition.h"

@implementation NSDictionary (ClassDefinition)

-(NSString*)className
{
    return [self objectForKey:NSDictionary_ClassDefinition_ClassNameKey];
}

-(BOOL)isValidClassMember:(NSString*)memberName
{
    BOOL result = NO;

    id member = [self objectForKey:memberName];
    if ( [member isKindOfClass:[NSString class] ] )
    {
        NSString* memberStringValue = (NSString*)member;
        if ( [memberStringValue length] > 0 && [memberStringValue characterAtIndex:0] != '_')
        {
            result = YES;
        }
    }
    
    return result;
}

@end
