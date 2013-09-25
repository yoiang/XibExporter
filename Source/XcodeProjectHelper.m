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

const int HEX_LENGTH = 24;

@implementation XcodeProjectHelper

+( NSString* )getXcodeProjectFileContents
{
    NSString *projectFileLocation = [ AppSettings getXcodeProjectFile ];
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
    NSString *projectFileLocation = [ AppSettings getXcodeProjectFile ];
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

+( NSString* )createXcodeProjectPBXBuildFileString:( NSString* )fileName id:( NSString* )hexId
{
    NSString* lastKnownFileType = [ XcodeProjectHelper createLastKnownFileTypeForFileName:fileName ];
    
    return [ NSString stringWithFormat:@"\t\t%@ /* %@ */ = {isa = PBXFileReference;%@ path = %@; sourceTree = \"<group>\"; };\n", hexId, fileName, lastKnownFileType, fileName ];
}

+( NSString* )createXcodeProjectGroupFileString:( NSString* )fileName id:( NSString* )hexId
{
    return [ NSString stringWithFormat:@"\t\t\t\t%@ /* %@ */,\n", hexId, fileName ];
}

// TODO: more intimite parsing of project file format
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
    
    NSRange searchRange = [ XcodeProjectHelper findGroupLocation:@"GeneratedViews" file:projectFile ];
    int groupInsertLoc = searchRange.location;
    if( searchRange.location == NSNotFound )
    {
        return;
    }
    
    //locate an insert location for the views for the PBXBuildFile section
    NSRange pbxBuildLoc = [ XcodeProjectHelper findPBXBuildFileInsertLocation:projectFile ];
    
    //create a new mutable string that represents the output
    NSMutableString *newProjectFile = [NSMutableString stringWithString:projectFile];
    
    //store whether or not we needed to make any change. If not, don't write
    BOOL madeChange = NO;
    
    for (int i = 0; i < [files count]; i++)
    {
        NSString *fileName = [files objectAtIndex:i];
        
        //if this is not already in the XcodeProj, add it in
        if ([projectFile rangeOfString:fileName options:NSLiteralSearch range:searchRange].location == NSNotFound)
        {
            //generate a hex key for this file
            NSString *hex = [XcodeProjectHelper generateRandomHexID];
            
            //now put it into the PBXBuildFile section
            NSString *pbxLine = [NSString stringWithFormat:@"\n%@", [XcodeProjectHelper createXcodeProjectPBXBuildFileString:fileName id:hex ] ];
            [ newProjectFile insertString:pbxLine atIndex:pbxBuildLoc.location + pbxBuildLoc.length ];
            
            groupInsertLoc += [pbxLine length]; //increase group insert location, as this occurs after the pbx
            
            NSString *line = [NSString stringWithFormat:@"\n%@", [ XcodeProjectHelper createXcodeProjectGroupFileString:fileName id:hex ] ];
            [newProjectFile insertString:line atIndex:groupInsertLoc];
            
            madeChange = YES;
        }
    }
    
    //now write the changes
    if (madeChange)
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
