//
//  NSString+Path.h
//  XibExporter
//
//  Created by Ian on 10/10/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Path)

+(NSString*)stringWithPath:(NSString*)path relativeTo:(NSString*)anchorPath;

@end
