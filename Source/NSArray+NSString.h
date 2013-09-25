//
//  NSArray+NSString.h
//  XibExporter
//
//  Created by Ian Grossberg on 3/21/13.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (NSString)

-( BOOL )containsString:( NSString* )value;
-( NSUInteger )containsStringAtIndex:( NSString* )value; // returns NSUIntegerMax if string not found

@end
