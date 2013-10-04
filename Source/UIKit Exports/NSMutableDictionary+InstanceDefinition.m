//
//  NSMutableDictionary+InstanceDefinition.m
//  XibExporter
//
//  Created by Ian on 10/4/13.
//
//

#import "NSMutableDictionary+InstanceDefinition.h"

@implementation NSMutableDictionary (InstanceDefinition)

-(void)setInstanceName:(NSString*)instanceName
{
    [self setObject:instanceName forKey:NSDictionary_InstanceDefinition_InstanceNameKey];
}

@end
