//
//  NSMutableDictionary+ClassDefinition.h
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import <Foundation/Foundation.h>

#import "NSDictionary+ClassDefinition.h"

@interface NSMutableDictionary (ClassDefinition)

-(void)setClassName:(NSString *)className;

// TODO: hacky way of compiling all members together for export, fix export to traverse super at export time
-(void)replaceSuperClassWithProperties:(NSDictionary*)superClassDefinition;

@end
