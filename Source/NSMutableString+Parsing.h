//
//  NSMutableString+Parsing.h
//  XibExporter
//
//  Created by Ian on 10/4/13.
//
//

#import <Foundation/Foundation.h>

#import "NSString+Parsing.h"

@interface NSMutableString (Parsing)

-(NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options;
-(NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement;

-(void)appendString:(NSString *)aString withNonEmptySeparator:(NSString*)nonEmptySeparater;

@end
