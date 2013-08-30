//
//  UIView+Exports.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExportUtility.h"

#import "TouchXML.h"

@interface UIView (Exported)

- (NSMutableDictionary *)exportToDictionary:( CXMLElement* )element;

+( void )addToComments:( NSString* )string members:( NSMutableDictionary* )members;
+( NSString* )getComments:( NSDictionary* )members;

-( NSString* )getKeyForSelf;
+( NSString* )getKeyForView:( UIView* )view;

-( void )addCustomMember:( NSString* )member value:( NSObject* )value;
-( NSObject* )getCustomMemberValue:( NSString* )member;

CustomMemberHeader( Outlet, NSString* );

@end
