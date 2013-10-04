//
//  NSDictionary+ClassDefinition.m
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import "NSDictionary+ClassDefinition.h"

#import "NSDictionary+TypeForKey.h"
#import "NSDictionary+InstanceDefinition.h"
#import "NSMutableString+Parsing.h"

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

-(NSString*)asParameterToParse
{
    return [self stringForKey:@"_parameter"];
}

-(NSString*)asParameterWithInstance:(NSDictionary*)instanceDefinition
{
    return [self asParameterWithInstanceName:[instanceDefinition instanceName] ];
}

-(NSString*)asParameterWithInstanceName:(NSString*)instanceName
{
    return [ [self asParameterToParse] stringByReplacingOccurrencesOfString:@"$instanceName$" withString:instanceName];
}

@end
