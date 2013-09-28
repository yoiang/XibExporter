//
//  NSDictionary+TypeForKey.m
//  XibExporter
//
//  Created by Ian on 9/28/13.
//
//

#import "NSDictionary+TypeForKey.h"

@implementation NSDictionary (TypeForKey)

-(NSString*)stringForKey:(NSString*)key
{
    NSString* result = nil;
    
    id object = [self objectForKey:key];
    if ( [object isKindOfClass:[NSString class] ] )
    {
        result = (NSString*)object;
    }
    
    return result;
}

-(NSArray*)arrayForKey:(NSString *)key
{
    NSArray* result = nil;
    
    id object = [self objectForKey:key];
    if ( [object isKindOfClass:[NSArray class] ] )
    {
        result = (NSArray*)object;
    }
    
    return result;
}

-(NSDictionary*)dictionaryForKey:(NSString *)key
{
    NSDictionary* result = nil;
    
    id object = [self objectForKey:key];
    if ( [object isKindOfClass:[NSDictionary class] ] )
    {
        result = (NSDictionary*)object;
    }
    
    return result;
}

-(BOOL)boolForKey:(NSString *)key withDefaultValue:(BOOL)defaultValue
{
    BOOL result = defaultValue;
    
    id object = [self objectForKey:key];
    if ( [object respondsToSelector:@selector(boolValue) ] )
    {
        result = [object boolValue];
    }
    
    return result;
}

@end
