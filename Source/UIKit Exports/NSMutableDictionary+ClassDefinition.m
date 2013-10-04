//
//  NSMutableDictionary+ClassDefinition.m
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import "NSMutableDictionary+ClassDefinition.h"

@implementation NSMutableDictionary (ClassDefinition)

-(void)setClassName:(NSString *)className
{
    [self setObject:className forKey:NSDictionary_ClassDefinition_ClassNameKey];
}

-(void)replaceSuperClassWithProperties:(NSDictionary*)superClassDefinition
{
    [self removeObjectForKey:NSDictionary_ClassDefinition_SuperClassKey];
    for (NSString* superMemberName in [superClassDefinition allKeys] )
    {
        if ( ![self objectForKey:superMemberName] )
        {
            [self setObject:[superClassDefinition objectForKey:superMemberName] forKey:superMemberName];
        }
    }
}

@end
