//
//  UILabel+Exports.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/3/12.
//

#import "UILabel+Exports.h"
#import "UIView+Exports.h"
#import "UIColor+Exports.h"
#import "ExportUtility.h"

#import "FontExchange.h"

@implementation UILabel (Exports)

- (NSMutableDictionary *)exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary *dict = [super exportToDictionary:xibElement];
    
    //the accessibility label automatically gets filled for labels, so check for that and remove if it happened
    if ([dict objectForKey:@"instanceName"] && ([dict objectForKey:@"instanceName"] == self.text))
    {
        [dict removeObjectForKey:@"instanceName"];
    }
    
    NSString* localizedTextKey = nil;
    if ( self.TextKey )
    {
        localizedTextKey = self.TextKey;
    }
    
    if ( localizedTextKey )
    {
        NSString* defaultText = self.text;
        if ( !defaultText )
        {
            defaultText = localizedTextKey;
        }
        [ dict setObject:defaultText forKey:@"localizedDefaultTextKey" ];
        [ dict setObject:localizedTextKey forKey:@"localizedTextKey" ];
    } else
    {
        if ( self.text )
        {
            [ dict setObject:self.text forKey:@"text" ];
        }
    }
    
    if (self.font.fontName)
    {
        NSString* exchangedFontName = [ [ FontExchange sharedInstance ] exchangeFont:self.font.fontName ];
        [dict setObject:exchangedFontName forKey:@"fontName"];
    }
    [dict setObject:[NSNumber numberWithFloat:self.font.pointSize] forKey:@"fontSize"];
    [dict setObject:@"use fontName and fontSize" forKey:@"font"];
    if (self.textColor)
    {
        [dict setObject:[self.textColor exportToDictionary] forKey:@"textColor"];
    }
    [dict setObject:[ExportUtility exportNSTextAlignment:self.textAlignment] forKey:@"textAlignment"];
    
    [dict setObject:[ExportUtility exportNSLineBreakMode:self.lineBreakMode] forKey:@"lineBreakMode"];
    [dict setObject:[NSNumber numberWithBool:self.enabled] forKey:@"enabled"];
    [dict setObject:[NSNumber numberWithBool:self.adjustsFontSizeToFitWidth] forKey:@"adjustsFontSizeToFitWidth"];
    [dict setObject:[NSNumber numberWithInt:self.baselineAdjustment] forKey:@"baselineAdjustment"];
#if __IPHONE_6_0 <= __IPHONE_OS_VERSION_MIN_ALLOWED
    [dict setObject:[NSNumber numberWithFloat:self.minimumFontSize] forKey:@"minimumFontSize"];
#endif
    [dict setObject:[NSNumber numberWithInt:self.numberOfLines] forKey:@"numberOfLines"];
    if (self.highlightedTextColor)
    {
        [dict setObject:[self.highlightedTextColor exportToDictionary] forKey:@"highlightedTextColor"];
    }
    [dict setObject:[NSNumber numberWithBool:self.highlighted] forKey:@"highlighted"];
    [dict setObject:[ExportUtility exportCGSize:self.shadowOffset] forKey:@"shadowOffset"];
    if (self.shadowColor)
    {
        [dict setObject:[self.shadowColor exportToDictionary] forKey:@"shadowColor"];
    }
    [dict setObject:[NSNumber numberWithBool:self.userInteractionEnabled] forKey:@"userInteractionEnabled"];
    
    return dict;
}

CustomMemberSynthesize( TextKey, NSString* );

@end
