//
//  UITextView+Exports.m
//  XibExporter
//
//  Created by Ian Grossberg on 4/17/12.
//

#import "UITextView+Exports.h"
#import "UIView+Exports.h"
#import "UIColor+Exports.h"
#import "ExportUtility.h"

#include "FontExchange.h"

#import "NSDictionary+ClassDefinition.h"

@implementation UITextView (Exported)

-( NSMutableDictionary* )exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary* dict = [ super exportToDictionary:xibElement ];
    
    NSMutableArray* subviewsArray = ( NSMutableArray* )[ dict objectForKey:@"subviews" ];
    int index = 0;  
    while ( index < [ subviewsArray count ] )
    {
        NSDictionary* subclassDict = ( NSDictionary* )[ subviewsArray objectAtIndex:index ];
        if ( [ subclassDict.className isEqualToString:@"UITextFieldRoundedRectBackgroundView" ] )
        {
            [ subviewsArray removeObjectAtIndex:index ];
        } else 
        {
            index ++;
        }
    }
    
    if ( self.text )
    {
        [ dict setObject:self.text forKey:@"text" ];
    }
    if (self.font.fontName)
    {
        NSString* exchangedFontName = [ [ FontExchange sharedInstance ] exchangeFont:self.font.fontName ];
        [dict setObject:exchangedFontName forKey:@"fontName"];
    }
    [dict setObject:[NSNumber numberWithFloat:self.font.pointSize] forKey:@"fontSize"];
    [dict setObject:@"use fontName and fontSize" forKey:@"font"];
    if ( self.textColor )
    {
        [ dict setObject:[ self.textColor exportToDictionary ] forKey:@"textColor" ];
    }
//    if ( self.font )
    [dict setObject:[ExportUtility exportNSTextAlignment:self.textAlignment] forKey:@"textAlignment"];
    
    [ dict setObject:[ ExportUtility exportUITextAutocapitalizationType:self.autocapitalizationType ] forKey:@"autocapitalizationType" ];
    if ( self.autocorrectionType == UITextAutocorrectionTypeYes )
    {
        [ dict setObject:[ NSNumber numberWithBool:YES ] forKey:@"autocorrection" ];
    } else if ( self.autocorrectionType == UITextAutocorrectionTypeNo )
    {
        [ dict setObject:[ NSNumber numberWithBool:NO ] forKey:@"autocorrection" ];        
    }
    
    [ dict setObject:[ ExportUtility exportUIKeyboardType:self.keyboardType ] forKey:@"keyboardType" ];
    [ dict setObject:[ NSNumber numberWithInt:self.keyboardAppearance ] forKey:@"keyboardAppearance" ];
    [ dict setObject:[ ExportUtility exportUIReturnKeyType:self.returnKeyType ] forKey:@"returnKeyType" ];
    [ dict setObject:[ NSNumber numberWithBool:self.enablesReturnKeyAutomatically ] forKey:@"enablesReturnKeyAutomatically" ];
    [ dict setObject:[ NSNumber numberWithBool:self.secureTextEntry ] forKey:@"secureText" ];
    
    return dict;
}

@end
