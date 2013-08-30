//
//  UISwitch+Exports.h
//  XibExporter
//

#import <Foundation/Foundation.h>

#import "TouchXML.h"

@interface UISwitch( Exported )

-( NSMutableDictionary* )exportToDictionary:( CXMLElement* )xibElement;

@end
