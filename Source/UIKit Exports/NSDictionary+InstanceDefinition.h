//
//  NSDictionary+InstanceDefinition.h
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import <Foundation/Foundation.h>

#define NSDictionary_InstanceDefinition_InstanceNameKey @"instanceName"

#define NSDictionary_InstanceDefinition_SubviewsKey @"subviews"

@interface NSDictionary (InstanceDefinition)

-(NSString*)instanceName;
-(BOOL)isOutlet;
-(BOOL)hasValueForMember:(NSString*)memberName;

-(BOOL)isRootView;

-(NSArray*)subviews;

@end
