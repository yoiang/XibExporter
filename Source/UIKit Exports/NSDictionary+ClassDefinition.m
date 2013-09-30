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

@end
