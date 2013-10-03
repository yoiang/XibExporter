//
//  NSDictionary+InstanceDefinition.h
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (InstanceDefinition)

-(NSString*)instanceName;
-(BOOL)isOutlet;
-(BOOL)hasValueForMember:(NSString*)memberName;

@end
