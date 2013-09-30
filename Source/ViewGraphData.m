//
//  ViewGraphData.m
//  XibExporter
//
//  Created by Ian on 9/13/13.
//
//

#import "ViewGraphData.h"

#import "AppSettings.h"

#import "UIViewController+Exports.h"
#import "AppDelegate.h"
#import "XibResources.h"
#import "ViewExporter.h"

#import "CXMLDocument+Xib.h"

@interface ViewGraphData()
{
    NSString *_xibName;
    NSMutableDictionary *_instanceDefinitions;
}

@end

@implementation ViewGraphData

@synthesize xibName = _xibName, rootViewInstanceDefinition = _instanceDefinitions;

-(id)initWithXib:(NSString*)xibName
{
    self = [super init];
    if (self)
    {
        [self processXib:xibName];
    }
    
    return self;
}

-(void)processXib:(NSString*)xibName
{
    _uiViewCustomMemberDictionary = [ [NSMutableDictionary alloc] init ];
    [ [ [AppDelegate sharedInstance] xibResources] clearXibResources];
    
    //NSLog( @"Processing xib %@", xibName );
    xibName = [xibName stringByDeletingPathExtension];
    
    UIViewController *vc = [ [UIViewController alloc] initWithNibName:xibName bundle:[NSBundle mainBundle] ];
    if (vc)
    {
        CXMLElement* xibRoot = [ViewGraphData getXibUIViewRoot:xibName];
        
        _xibName = xibName;
        _instanceDefinitions = [vc exportToDictionary:xibRoot xibName:xibName];
    }
}

+( CXMLElement* )getXibUIViewRoot:( NSString* )xibName
{
    CXMLElement* result = nil;
    
    NSString* xibPath = [ ViewGraphData getPathOfFile:[ NSString stringWithFormat:@"%@.xib", xibName ] start:[AppSettings getFolderContainingXibsToProcess] ];
    if ( xibPath )
    {
        NSData* xmlData = [ NSData dataWithContentsOfFile:xibPath ];
        CXMLDocument* xibDocument = [ [ [ CXMLDocument alloc ] initWithData:xmlData options:0 error:nil ] autorelease ];
        result = [xibDocument uiViewRoot];
    }
    return result;
}

+( NSString* )getPathOfFile:( NSString* )findFileName start:( NSString* )start
{
    NSFileManager* fileManager = [ NSFileManager defaultManager ];
    
    NSError* error = nil;
    
    NSArray* filesAndDirectoriesKeys = [ NSArray arrayWithObjects:NSURLIsRegularFileKey, NSURLIsDirectoryKey, nil ];
    //    NSArray* onlyFilesKeys = [ NSArray arrayWithObject:NSURLIsRegularFileKey ];
    //    NSArray* files = [ fileManager contentsOfDirectoryAtURL:[ NSURL URLWithString:start ] includingPropertiesForKeys:onlyFilesKeys options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error ];
    
    if ( error )
    {
        NSLog( @"Error in ViewExporter::getPathOfFile, could not get contents of URL at %@", start );
        return nil;
    }
    
    //    NSArray* onlyDirectoriesKeys = [ NSArray arrayWithObject:NSURLIsDirectoryKey ];
    
    NSDirectoryEnumerator* enumerator = [ fileManager
                                         enumeratorAtURL:[ NSURL URLWithString:start ]
                                         includingPropertiesForKeys:filesAndDirectoriesKeys
                                         options:0
                                         errorHandler:^( NSURL *url, NSError *error ) {
                                             NSLog( @"Error in directory enumerator: %@", error );
                                             return YES;
                                         }];
    
    for ( NSURL* url in enumerator )
    {
        error = nil;
        NSDictionary* attributes = [ fileManager attributesOfItemAtPath:[ url path ] error:&error ];
        if ( error )
        {
            NSLog( @"Error in ViewExporter::getPathOfFile, could not get attributes of URL at %@", url );
            continue;
        }
        
        if ( [ [ attributes fileType ] isEqualToString:NSFileTypeRegular ] )
        {
            NSArray* pathComponents = [ url pathComponents ];
            if ( [ pathComponents count ] >= 1 )
            {
                NSString* enumeratedFileName = [ NSString stringWithFormat:@"%@", [ pathComponents objectAtIndex:[ pathComponents count ] - 1 ] ];
                if ( [ enumeratedFileName isEqualToString:findFileName ] )
                {
                    return [ url path ];
                }
            }
        }
    }
    
    NSLog( @"Unable to find %@ within %@, file was either incorrectly removed, a reference to it remains in viewChanges.txt when it was removed, or your .app needs to be cleaned", findFileName, start );
    return nil;
}

@end
