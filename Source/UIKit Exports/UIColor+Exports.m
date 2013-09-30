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
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict.className = @"UIColor";
    
    const float* colors = CGColorGetComponents( self.CGColor );
    float r = 0.0f;
    float g = 0.0f;
    float b = 0.0f;
    float a = CGColorGetAlpha(self.CGColor);
    
    //WTF BS black and gray cause this crapola
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
    
    //NSLog(@"R %f G %f B %f A %f",r,g,b,a);
    
    [dict setObject:[NSNumber numberWithInt:(int)(r*255)] forKey:@"red"];
    [dict setObject:[NSNumber numberWithInt:(int)(g*255)] forKey:@"green"];
    [dict setObject:[NSNumber numberWithInt:(int)(b*255)] forKey:@"blue"];
    [dict setObject:[NSNumber numberWithInt:(int)(a*255)] forKey:@"alpha"];
    return dict;
}

@end
