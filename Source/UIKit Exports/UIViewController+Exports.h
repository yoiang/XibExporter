//
//  UIViewController+SavedPath.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TouchXML.h"

NSMutableDictionary* _uiViewCustomMemberDictionary;

@interface UIViewController (Exports)

+ (void) initializeStorage;
+ (NSString *) dequeueImageLocation;

- (id) initWithNibNameStored:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (NSMutableDictionary *)exportToDictionary:( CXMLElement* )xibNode xibName:( NSString* )xibName;

@end
