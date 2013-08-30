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
    BOOL result = NO;
    
    for ( NSObject* object in self )
    {
        if (
            [ object isKindOfClass:[ NSString class ] ] &&
            [ ( ( NSString* )object ) isEqualToString:value ]
            )
        {
            result = YES;
            break;
        }
    }
    
    return result;
}

@end
