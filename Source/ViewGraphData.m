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
#import "CXMLElement+UIView.h"
#import "ViewExporter.h"


@interface ViewGraphData()
{
    NSString *_xibName;
    NSMutableDictionary *_data;
}

@end

@implementation ViewGraphData

@synthesize xibName = _xibName, data = _data;

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
    UIViewController *vc = [ [UIViewController alloc] initWithNibName:xibName bundle:[NSBundle mainBundle] ];
    if (vc)
    {
        CXMLElement* xibRoot = [ViewGraphData getXibUIViewRoot:xibName];
        
        _xibName = xibName;
        _data = [vc exportToDictionary:xibRoot xibName:xibName];
    }
}

+( CXMLElement* )getXibUIViewRootForDocument:( CXMLDocument* )document
{
    CXMLElement* result = nil;
    
    NSError* error = nil;
    
    NSArray* dataArrayObjects = [ document nodesForXPath:@"/archive/data/array" error:&error ];
    if ( error )
    {
        NSLog( @"Error trying to find root node: %@", error );
    } else
    {
        for ( CXMLNode* dataArrayNode in dataArrayObjects )
        {
            if ( [ dataArrayNode kind ] == CXMLElementKind )
            {
                CXMLElement* dataArrayElement = ( CXMLElement* )dataArrayNode;
                if ( [ [ dataArrayElement attributeKeyStringValue ] isEqualToString:@"IBDocument.RootObjects" ] )
                {
                    NSArray* rootArrayObjects = [ dataArrayElement children ];
                    for ( CXMLNode* rootArrayNode in rootArrayObjects )
                    {
                        if ( [ rootArrayNode kind ] == CXMLElementKind )
                        {
                            CXMLElement* rootArrayElement = ( CXMLElement* )rootArrayNode;
                            if ( [ [ rootArrayElement attributeClassStringValue ] isEqualToString:@"IBUIView" ] )
                            {
                                result = rootArrayElement;
                                break;
                            }
                        }
                    }
                    if ( result )
                    {
                        break;
                    }
                }
            }
        }
    }
    return result;
}

+( CXMLElement* )getXibUIViewRoot:( NSString* )xibName
{
    CXMLElement* result = nil;
    
    NSString* xibPath = [ ViewGraphData getPathOfFile:[ NSString stringWithFormat:@"%@.xib", xibName ] start:[AppSettings getXIBRoot] ];
    if ( xibPath )
    {
        NSData* xmlData = [ NSData dataWithContentsOfFile:xibPath ];
        result = [ ViewGraphData getXibUIViewRootForDocument:[ [ [ CXMLDocument alloc ] initWithData:xmlData options:0 error:nil ] autorelease ] ];
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
