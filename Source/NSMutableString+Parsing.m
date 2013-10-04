//
//  NSMutableString+Parsing.m
//  XibExporter
//
//  Created by Ian on 10/4/13.
//
//

#import "NSMutableString+Parsing.h"

@implementation NSMutableString (Parsing)

- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options
{
    return [self replaceOccurrencesOfString:target withString:replacement options:options range:NSMakeRange(0, [self length] ) ];
}

- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
{
    return [self replaceOccurrencesOfString:target withString:replacement options:NSLiteralSearch];
}

-(void)appendString:(NSString *)aString withNonEmptySeparator:(NSString*)nonEmptySeparater
{
    if ( [self length] > 0 )
    {
        [self appendString:nonEmptySeparater];
    }
    
    [self appendString:aString];
}


@end
