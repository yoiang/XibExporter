//
//  XcodeProjectHelper.m
//  XibExporter
//
//  Created by Eli Delventhal on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XcodeProjectHelper.h"

const int HEX_LENGTH = 24;

@implementation XcodeProjectHelper

+ (NSString *) getXcodeProjectFolder
{
    return [ [ NSBundle mainBundle ] objectForInfoDictionaryKey:@"XcodeProjectFolder" ];
}

+ (NSString *) getGeneratedSourceFolder
{
    return [ [ XcodeProjectHelper getXcodeProjectFolder ] stringByAppendingString:[ [ NSBundle mainBundle ] objectForInfoDictionaryKey:@"GeneratedSourceRelativeFolder" ] ];
}

+ (NSString *) getXcodeProjectFile
{
    return [ [ XcodeProjectHelper getXcodeProjectFolder ] stringByAppendingString:[ [ NSBundle mainBundle ] objectForInfoDictionaryKey:@"XcodeProjectRelativeFile" ] ];
}

+ (NSString *) getXIBRoot
{
    return [ [ XcodeProjectHelper getXcodeProjectFolder ] stringByAppendingString:[ [ NSBundle mainBundle ] objectForInfoDictionaryKey:@"XIBRootRelativeFolder" ] ];
}

+ (NSArray *) getSkipXibs
{
    return [ [ NSBundle mainBundle ] objectForInfoDictionaryKey:@"SkipXibs" ];
}

+ (NSArray *) getProcessOnlyXibs
{
    return [ [ NSBundle mainBundle ] objectForInfoDictionaryKey:@"ProcessOnlyXibs" ];
}

+ (BOOL) forceExportAllXibs
{
    return [ [ [ NSBundle mainBundle ] objectForInfoDictionaryKey:@"ForceExportAllXibs" ] boolValue ];
}

+( NSString* )getXcodeProjectFileContents
{
    NSString *projectFileLocation = [ XcodeProjectHelper getXcodeProjectFile ];
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
    NSString *projectFileLocation = [ XcodeProjectHelper getXcodeProjectFile ];
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
    NSRange searchRange = [ fileString rangeOfString:@"children = (\n" options:NSLiteralSearch range:NSMakeRange(generatedViewsLocation.location, 1000) ];
    searchRange.location = searchRange.location + searchRange.length;
    searchRange.length = [ fileString rangeOfString:@");" options:NSLiteralSearch range:NSMakeRange(searchRange.location, 100000)].location - searchRange.location;
    return searchRange;
}

// TODO: more intimite parsing of project file format
+( int )findPBXBuildFileInsertLocation:( NSString* )fileString
{
    //locate an insert location for the views for the PBXBuildFile section
    return [ fileString rangeOfString:@"\t\t5326AEA810A23A0500278DE6 /* CoreLocation.framework in Frameworks */" options:NSLiteralSearch range:NSMakeRange(0, [ fileString length ] ) ].location;
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
    int pbxBuildLoc = [ XcodeProjectHelper findPBXBuildFileInsertLocation:projectFile ];
    
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
            NSString *pbxLine = [ XcodeProjectHelper createXcodeProjectPBXBuildFileString:fileName id:hex ];
            [ newProjectFile insertString:pbxLine atIndex:pbxBuildLoc ];
            
            groupInsertLoc += [pbxLine length]; //increase group insert location, as this occurs after the pbx
            
            NSString *line = [ XcodeProjectHelper createXcodeProjectGroupFileString:fileName id:hex ];
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

//takes an array of files and removes all ones that have not been modified
+ (NSArray *) trimToOnlyModifiedFiles:(NSArray *)files
{
    //amazingly, even though usedViews.txt gets updated with a preproc script, it gets put into the build directory before thism making it the old
    //file. so just adding it to the xcode project doesn't work. instead, we need to do the same BS file system access...
    NSString *usedViews = [NSString stringWithFormat:@"%@/tools/Xib-Exporter/XibExporter/usedViews.txt",[XcodeProjectHelper getXcodeProjectFolder]];
    NSError *error = nil;
    NSString *contents = [NSString stringWithContentsOfFile:usedViews encoding:NSUTF8StringEncoding error:&error];
    
    if (!error)
    {
        NSMutableArray *results = [NSMutableArray array];
        NSArray *views = [contents componentsSeparatedByString:@" "];
        
        for (int i = 0; i < [files count]; i++)
        {
            NSString *n = [NSString stringWithFormat:@"%@.xib",[files objectAtIndex:i]];
            for (int j = 0; j < [views count]; j++)
            {
                NSString *v = [[views objectAtIndex:j] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([v isEqualToString:n])
                {
                    [results addObject:[files objectAtIndex:i]];
                    break;
                }
            }
        }
        
    return results;
    }
    else
    {
        NSLog(@"Couldn't read usedViews.txt file.");
    }
    
    return files;
}

+ (BOOL)addExportsToProject
{
    BOOL result = YES;
    
    NSNumber* shouldAdd = [ [ NSBundle mainBundle ] objectForInfoDictionaryKey:@"Add Exports to Project" ];
    if (shouldAdd)
    {
        result = [shouldAdd boolValue];
    }
    
    return result;
}

@end
