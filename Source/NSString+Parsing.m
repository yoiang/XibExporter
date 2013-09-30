//
//  NSString+Parsing.m
//  XibExporter
//
//  Created by Eli Delventhal on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Parsing.h"

@implementation NSString (Parsing)

- (NSString *) stringByParsingSandwiches:(NSString *)sandwichString parseObject:(id)object parseSelector:(SEL)selector userData:(id)userData
{
    NSString *output = [NSString stringWithString:self];
    
    if ( !object )
    {
        return output;
    }
    
    NSRange r = NSMakeRange(0, [output length]);
    while (r.location != NSNotFound && r.location < [output length])
    {
        r = [output rangeOfString:sandwichString options:NSLiteralSearch range:NSMakeRange(r.location, [output length] - r.location)];
        if (r.location != NSNotFound)
        {
            NSRange r2 = [output rangeOfString:sandwichString options:NSLiteralSearch range:NSMakeRange(r.location + r.length, [output length] - r.location - r.length)];
            if (r2.location != NSNotFound)
            {
                NSString *oldValue = [output substringWithRange:NSMakeRange(r.location + r.length, r2.location - r.location - r.length)];
                NSString *newValue = [object performSelector:selector withObject:oldValue withObject:userData];
                
                if ( newValue && [ newValue length ] > 0 )
                {
                    int oldOutputLength = [output length];
                    int replaceStart = r.location;
                    int replaceLength = r2.location - r.location + 1;
                    output = [output stringByReplacingCharactersInRange:NSMakeRange(replaceStart, replaceLength) withString:newValue];
                    r2 = NSMakeRange(r2.location + ([output length] - oldOutputLength), 1);
                }
            }
            
            r = NSMakeRange(r2.location+r2.length, r.length);
        }
    }
    
    return output;
}

-(NSString*)substringBetweenOccurancesOf:(NSString*)find
{
    NSString* result = nil;
    
    NSRange firstOccurance = [self rangeOfString:find options:NSLiteralSearch];
    if (firstOccurance.location != NSNotFound)
    {
        NSUInteger startSecondSearch = firstOccurance.location + firstOccurance.length;
        NSRange secondOccurance = [self rangeOfString:find options:NSLiteralSearch range:NSMakeRange(startSecondSearch, [self length] - startSecondSearch) ];
        
        if (secondOccurance.location != NSNotFound)
        {
            result = [self substringWithRange:NSMakeRange(startSecondSearch, secondOccurance.location - startSecondSearch) ];
        }
    }
    
    return result;
}

@end
