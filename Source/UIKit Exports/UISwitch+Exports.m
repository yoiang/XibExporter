//
//  UISwitch+Exports.m
//  XibExporter
//

#import "UISwitch+Exports.h"
#import "UIColor+Exports.h"
#import "UIView+Exports.h"

@implementation UISwitch( Exported )

-( NSMutableDictionary* )exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary *dict = [ super exportToDictionary:xibElement ];
    
    [ dict setObject:[ NSNumber numberWithBool:self.on ] forKey:@"on" ];
    if ( [ self onTintColor ] )
    {
        [ dict setObject:[ [ self onTintColor ] exportToDictionary ] forKey:@"onTintColor" ];
    }

    return dict;
}

/*
 thumbTintColor  property
 onImage  property
 offImage  property
 */

@end
