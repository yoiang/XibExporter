//
//  XcodeProjectHelper.m
//  XibExporter
//
//  Created by Eli Delventhal on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XcodeProjectHelper.h"

#import "AppSettings.h"

#import "NSArray+NSString.h"
#import "NSMutableString+Parsing.h"

#import "NSString+Path.h"

const int HEX_LENGTH = 24;

@implementation XcodeProjectHelper

+( NSString* )getXcodeProjectFileContents
{
    NSString *projectFileLocation = [ AppSettings getAddExportsToProjectFile ];
    NSError *error = nil;
    NSString *projectFile = [NSString stringWithContentsOfFile:projectFileLocation encoding:NSUTF8StringEncoding error:&error];
    
    if ( error )
    {
        NSLog( @"Unable to open project file located at %@ because of error %@", projectFileLocation, error );
        return nil;
    }
    return projectFile;
}

+( void )setXcodeProjectFileContents:( NSString* )contents
{
    NSString *projectFileLocation = [ AppSettings getAddExportsToProjectFile ];
    NSError *error = nil;
    [ contents writeToFile:projectFileLocation atomically:NO encoding:NSUTF8StringEncoding error:&error ];
    if ( error )
    {
        NSLog( @"Unable to write new Xcode project to %@ because of %@", projectFileLocation, error );
    }
}

+( NSString* )createLastKnownFileType:( NSString* )formatString
{
    return [ NSString stringWithFormat:@" lastKnownFileType = %@;", formatString ];
}

+( NSString* )createLastKnownFileTypeForFileName:( NSString* )fileName
{
    NSString* lastKnownFileType = nil;
    if ( [ [ fileName pathExtension ] isEqualToString:@"h" ] )
    {
        lastKnownFileType = [ XcodeProjectHelper createLastKnownFileType:@"sourcecode.c.h" ];
    }
    return lastKnownFileType;
}

+( NSString* )createXcodeProjectPBXBuildFileString:( NSString* )fileName id:( NSString* )hexId atPath:(NSString*)path
{
    NSString* lastKnownFileType = [ XcodeProjectHelper createLastKnownFileTypeForFileName:fileName ];
    
    NSString* relativePath = [NSString stringWithPath:path relativeTo:[AppSettings getPathToAddExportsToProjectFile] ];
    NSString* relativeFileNamePath = [NSString stringWithFormat:@"%@/%@", relativePath, fileName];
    
    return [ NSString stringWithFormat:@"\t\t%@ /* %@ */ = {isa = PBXFileReference;%@ name = %@; path = %@; sourceTree = \"<group>\"; };", hexId, fileName, lastKnownFileType, fileName, relativeFileNamePath ];
}

+( NSString* )createXcodeProjectGroupFileString:( NSString* )fileName id:( NSString* )hexId
{
    return [ NSString stringWithFormat:@"\t\t\t\t%@ /* %@ */,", hexId, fileName ];
}

// TODO: findGroupLocation and findPBXBuildFileInsertLocation return conceptually different information, one points to beginning and one points to insert location, fix
// TODO: more knowing parsing of project file format
+( NSRange )findGroupLocation:( NSString* )groupName file:( NSString* )fileString
{
    NSRange generatedViewsLocation = [ fileString rangeOfString:[ NSString stringWithFormat:@"/* %@ */ = {", groupName ] ];
    
    if ( generatedViewsLocation.location == NSNotFound )
    {
        NSLog( @"Unable to locate GeneratedViews group in the project file, cannot automatically add source file to project." );
        return generatedViewsLocation;
    }
    
    //locate a search range for inserting generated views
    NSRange searchRange = [ fileString rangeOfString:@"children = (" options:NSLiteralSearch range:NSMakeRange(generatedViewsLocation.location, 1000) ];
    searchRange.location = searchRange.location + searchRange.length;
    
    NSRange remainingRange = NSMakeRange(searchRange.location, [fileString length] - searchRange.location );
    searchRange.length = [fileString rangeOfString:@");" options:NSLiteralSearch range:remainingRange].location - searchRange.location;
    return searchRange;
}

// TODO: more intimite parsing of project file format
+(NSRange)findPBXBuildFileInsertLocation:( NSString* )fileString
{
    //locate an insert location for the views for the PBXBuildFile section
    return [ fileString rangeOfString:@"/* Begin PBXBuildFile section */" options:NSLiteralSearch range:NSMakeRange(0, [ fileString length ] ) ];
}

+ (void) addToXcodeProject:(NSArray *)files
{
    NSString* projectFile = [ XcodeProjectHelper getXcodeProjectFileContents ];
    if ( projectFile == nil )
    {
        return;
    }
    
    // TODO: add if it isn't already there
    NSRange searchRange = [ XcodeProjectHelper findGroupLocation:@"GeneratedViews" file:projectFile ];
    if( searchRange.location == NSNotFound )
    {
        NSLog(@"Error: unable to find GeneratedViews group in project file, cannot add generated files");
        return;
    }
    
    NSMutableString* insertIntoPBXBuildFileSection = [NSMutableString string];
    NSMutableString* insertIntoGroupFileSection = [NSMutableString string];
    NSMutableArray* addedIds = [NSMutableArray array];
    
    for (NSString* fileName in files)
    {
        //if this is not already in the XcodeProj, add it in
        if ( [projectFile rangeOfString:fileName options:NSLiteralSearch].location == NSNotFound ) // TODO: only search group range
        {
            //generate a hex key for this file
            NSString* hex = [XcodeProjectHelper generateRandomHexID];
            while ( [projectFile rangeOfString:hex options:NSLiteralSearch].location != NSNotFound &&
                   [addedIds containsString:hex] == YES ) // make sure we have a unique identifier
            {
                hex = [XcodeProjectHelper generateRandomHexID];
            }
            
            [insertIntoPBXBuildFileSection appendString:[XcodeProjectHelper createXcodeProjectPBXBuildFileString:fileName id:hex atPath:[AppSettings getFolderForExports] ] withNonEmptySeparator:@"\n"];
            [insertIntoGroupFileSection appendString:[XcodeProjectHelper createXcodeProjectGroupFileString:fileName id:hex] withNonEmptySeparator:@"\n"];
            [addedIds addObject:hex];
        }
    }

    BOOL updatedProjectFile = NO;
    NSMutableString* newProjectFile = [NSMutableString stringWithString:projectFile];
    if ( [insertIntoPBXBuildFileSection length] > 0 )
    {
        //locate an insert location for the views for the PBXBuildFile section
        NSRange pbxBuildLoc = [ XcodeProjectHelper findPBXBuildFileInsertLocation:newProjectFile ];
        [newProjectFile insertString:[NSString stringWithFormat:@"\n%@", insertIntoPBXBuildFileSection] atIndex:pbxBuildLoc.location + pbxBuildLoc.length];
        
        updatedProjectFile = YES;
    }
    if ( [insertIntoGroupFileSection length] > 0 )
    {
        NSRange groupLoc = [ XcodeProjectHelper findGroupLocation:@"GeneratedViews" file:newProjectFile ];
        [newProjectFile insertString:[NSString stringWithFormat:@"\n%@", insertIntoGroupFileSection] atIndex:groupLoc.location];
        updatedProjectFile = YES;
    }
    
    if (updatedProjectFile)
    {
        [ XcodeProjectHelper setXcodeProjectFileContents:newProjectFile ];
    }
}

+ (NSString *) generateRandomHexID
{
    NSMutableString *hex = [NSMutableString stringWithCapacity:HEX_LENGTH];
    //TODO parse through every single hex in the project and ensure uniqueness
    for (int i = 0; i < HEX_LENGTH; i++)
    {
        int r = arc4random() % 16;
        if (r < 10)
        {
            [hex appendFormat:@"%d",r];
        }
        else
        {
            char c = (r - 10) + 'A';
            [hex appendFormat:@"%c",c];
        }
    }
    return hex;
}

@end
