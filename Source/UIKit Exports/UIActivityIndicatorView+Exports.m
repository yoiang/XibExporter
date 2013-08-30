//
//  UITextField+Exports.m
//  XibExporter
//
//  Created by Ian Grossberg on 4/17/12.
//

#import "UIActivityIndicatorView+Exports.h"
#import "UIView+Exports.h"
#import "UIColor+Exports.h"
#import "ExportUtility.h"

@implementation UIActivityIndicatorView (Exported)

-( NSMutableDictionary* )exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary *dict = [super exportToDictionary:xibElement];

    [ dict setObject:[ ExportUtility exportUIActivityIndicatorViewStyle:self.activityIndicatorViewStyle ] forKey:@"activityIndicatorViewStyle" ];

    [ dict setObject:[ NSNumber numberWithBool:self.hidesWhenStopped ] forKey:@"hidesWhenStopped" ];
    
    if ( self.color )
    {
        [ dict setObject:[ self.color exportToDictionary ] forKey:@"color" ];
    }
    
    [ dict setObject:[ NSNumber numberWithBool:self.userInteractionEnabled ] forKey:@"userInteractionEnabled" ];
    
    return dict;
}

@end
