//
//  UIPageControl+Exports.h
//  XibExporter
//
//  Created by Eli Delventhal on 9/4/12.
//
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"

@interface UIPageControl (Exported)

-( NSMutableDictionary* )exportToDictionary:( CXMLElement* )xibElement;

@end
