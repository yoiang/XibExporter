//
//  UILabel+Exports.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExportUtility.h"
#import "TouchXML.h"

@interface UILabel (Exports)

- (NSMutableDictionary *)exportToDictionary:( CXMLElement* )xibElement;

CustomMemberHeader( TextKey, NSString* );

@end
