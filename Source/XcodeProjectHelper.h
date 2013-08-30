//
//  XcodeProjectHelper.h
//  XibExporter
//
//  Created by Eli Delventhal on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XcodeProjectHelper : NSObject

//returns a string path to the Xcode project, defined in plist // TODO: move to configuration
+ (NSString *) getXcodeProjectFolder;
//returns a string path to the generated folder, defined relative in plist // TODO: move to configuration
+ (NSString *) getGeneratedSourceFolder;
//returns a string path to the Xcode project file, defined relative in plist // TODO: move to configuration
+ (NSString *) getXcodeProjectFile;
//returns a string path to the XIB root folder, defined relative in plist // TODO: move to configuration
+ (NSString *) getXIBRoot;

//returns an array of Xib filenames to skip, defined in plist // TODO: move to configuration
+ (NSArray *) getSkipXibs;
//returns an array of the only Xib filenames to process, defined in plist // TODO: move to configuration
+ (NSArray *) getProcessOnlyXibs;

//returns whether to force exporting all Xibs processed rather than only those that have changed, defined in plist // TODO: move to configuration
+ (BOOL) forceExportAllXibs;

//adds the passed files to the Xcode project - files is an array of file names including extension
+ (void) addToXcodeProject:(NSArray *)files;

//creates a random hex string that can be used as an ID for a file in the XcodeProj file
+ (NSString *) generateRandomHexID;

//takes an array of files and removes all ones that have not been modified
+ (NSArray *) trimToOnlyModifiedFiles:(NSArray *)files;

@end
