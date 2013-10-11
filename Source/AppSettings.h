//
//  AppSettings.h
//  XibExporter
//
//  Created by Ian on 9/17/13.
//
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject

// returns a string path to the folder where we can find our valid nib files
+(NSString*)getFolderContainingNibsToProcess;

// returns a string path to the generated folder, defined relative in plist // TODO: move to configuration
+(NSString*)getFolderForExports;

// returns a string path to the folder the Xcode project file is located in
+ (NSString *)getPathToAddExportsToProjectFile;

// returns a string path to the Xcode project file, defined relative in plist // TODO: move to configuration
+(NSString*)getAddExportsToProjectFile;

// returns a string path to the XIB root folder, defined relative in plist // TODO: move to configuration
+(NSString*)getFolderContainingXibsToProcess;

// returns an array of Xib filenames to skip, defined in plist // TODO: move to configuration
+(NSArray*)getSkipXibs;

// returns an array of the only Xib filenames to process, defined in plist // TODO: move to configuration
+(NSArray*)getProcessOnlyXibs;

// returns whether to force exporting all Xibs processed rather than only those that have changed, defined in plist // TODO: move to configuration
+(BOOL)ForceProcessUnchangedXibs;

// returns a list of View Exporter classes that should be registered for use
+(NSArray*)getRegisterExporterClasses;

// toggle whether we should add the exported files to the target project
+(BOOL)addExportsToProject;

// returns a list of exports that are enabled, correlates with ViewExporterFactory's exporter name dictionary
+(NSArray*)getEnabledExports;

@end
