//
//  NSArray+NSString.m
//  XibExporter
//
//  Created by Ian Grossberg on 3/21/13.
//
//

#import "NSArray+NSString.h"

@implementation NSArray (NSString)

-( BOOL )containsString:( NSString* )value
{
    return [self containsStringAtIndex:value] != NSUIntegerMax;
}

-( NSUInteger )containsStringAtIndex:( NSString* )value
{
    NSUInteger result = NSUIntegerMax;
    
    for (NSUInteger index = 0; index < [self count]; index++)
    {
        id object = [self objectAtIndex:index];
        if (
            [ object isKindOfClass:[ NSString class ] ] &&
            [ ( ( NSString* )object ) isEqualToString:value ]
            )
        {
            result = index;
            break;
        }
    }
    
    return result;
}


@end
