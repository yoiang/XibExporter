//
//  XcodeProjectHelper.h
//  XibExporter
//
//  Created by Eli Delventhal on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XcodeProjectHelper : NSObject

//adds the passed files to the Xcode project - files is an array of file names including extension
+ (void) addToXcodeProject:(NSArray *)files;

//creates a random hex string that can be used as an ID for a file in the XcodeProj file
+ (NSString *) generateRandomHexID;

@end
