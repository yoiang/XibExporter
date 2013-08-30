//
//  UIButton+Exports.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExportUtility.h"

@interface UIButton (Exports)

- (NSMutableDictionary *)exportToDictionary:( CXMLElement* )xibElement;

#pragma Custom Members
CustomMemberHeader( TextKey, NSString* );
CustomMemberHeader( Image, NSString* );
CustomMemberHeader( ImageUp, NSString* );
CustomMemberHeader( ImageFile, NSString* );
CustomMemberHeader( ActiveImage, NSString* );
CustomMemberHeader( ImageDown, NSString* );

@end
