//
//  NSDictionary+Path.h
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Path)

-(id)objectAtPath:(NSString*)path withPathSeparator:(NSString*)pathSeparator;

@end
