//
//  UIScrollView+Exports.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchXML.h"

@interface UIScrollView (Exports)

- (NSMutableDictionary *) exportToDictionary:( CXMLElement* )xibElement;

@end
