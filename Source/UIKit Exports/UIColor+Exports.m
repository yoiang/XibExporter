//
//  UIColor+Exports.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+Exports.h"

#import "NSMutableDictionary+ClassDefinition.h"

@implementation UIColor (Exports)

- (NSMutableDictionary *)exportToDictionary
{
/*
    // in testing it returned negative results
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
 */
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict.className = @"UIColor";
    
    const float* colors = CGColorGetComponents( self.CGColor );
    float r = 0.0f;
    float g = 0.0f;
    float b = 0.0f;
    float a = CGColorGetAlpha(self.CGColor);
    
    if (CGColorGetNumberOfComponents( self.CGColor ) == 2)
    {
        r = g = b = colors[0];
    }
    else if (CGColorGetNumberOfComponents( self.CGColor ) >= 3)
    {
        r = colors[0];
        g = colors[1];
        b = colors[2];
    }
    
    [dict setObject:[NSNumber numberWithFloat:r] forKey:@"red"];
    [dict setObject:[NSNumber numberWithFloat:g] forKey:@"green"];
    [dict setObject:[NSNumber numberWithFloat:b] forKey:@"blue"];
    [dict setObject:[NSNumber numberWithFloat:a] forKey:@"alpha"];
    return dict;
}

@end
