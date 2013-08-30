//
//  UITextField+Exports.h
//  XibExporter
//
//  Created by Ian Grossberg on 4/17/12.
//

#pragma once

#import <Foundation/Foundation.h>
#import "TouchXML.h"

@interface UIActivityIndicatorView (Exported)

-( NSMutableDictionary* )exportToDictionary:( CXMLElement* )xibElement;

@end