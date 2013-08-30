//
//  UITableView+Exports.h
//  XibExporter
//
//  Created by Ian Grossberg on 4/16/12.
//

#pragma once

#import <Foundation/Foundation.h>
#import "TouchXML.h"

@interface UITableView (Exported)

-( NSMutableDictionary* )exportToDictionary:( CXMLElement* )xibElement;

@end