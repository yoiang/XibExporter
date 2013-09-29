//
//  CXMLDocument+Xib.m
//  XibExporter
//
//  Created by Ian on 9/29/13.
//
//

#import "CXMLDocument+Xib.h"

#import "CXMLElement.h"
#import "CXMLElement+UIView.h"

@implementation CXMLDocument (Xib)

-(BOOL)isXibVersionXcode4:(NSError**)error
{
    BOOL result = NO;
    
    NSArray* dataArrayObjects = [self nodesForXPath:@"/archive" error:error];
    
    if ( [dataArrayObjects count] != 0)
    {
        CXMLElement* archive = [dataArrayObjects objectAtIndex:0];
        
        CXMLNode* versionAttribute = [archive attributeForName:@"version"];
        if ( [ [versionAttribute stringValue] isEqualToString:@"8.00"] )
        {
            result = YES;
        }
    }
    
    return result;
}

-(BOOL)isXibVersionXcode5:(NSError**)error
{
    BOOL result = NO;
    
    NSArray* dataArrayObjects = [self nodesForXPath:@"/document" error:error];
    
    if ( [dataArrayObjects count] != 0)
    {
        CXMLElement* document = [dataArrayObjects objectAtIndex:0];
        
        CXMLNode* versionAttribute = [document attributeForName:@"version"];
        if ( [ [versionAttribute stringValue] isEqualToString:@"3.0"] )
        {
            result = YES;
        }
    }
    
    return result;
}

-(XibVersion)xibVersion
{
    XibVersion result = XibVersionUnsupported;
    NSError* error;

    // TODO: log errors
    if ( [self isXibVersionXcode4:&error] )
    {
        result = XibVersionXcode4;
    } else if ( [self isXibVersionXcode5:&error] )
    {
        result = XibVersionXcode5;
    }
    
    return result;
}

-(CXMLElement*)uiViewRootForXibVersionXcode4
{
    CXMLElement* result = nil;
    
    NSError* error = nil;
    
    NSArray* dataArrayObjects = [self nodesForXPath:@"/archive/data/array" error:&error];
    if ( error )
    {
        NSLog(@"Error trying to find UIView root node for Xib Xcode 4: %@", error);
    }
    
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
                        if ( [ [ rootArrayElement classType ] isSubclassOfClass:[UIView class] ] )
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
    return result;
}

-(CXMLElement*)uiViewRootForXibVersionXcode5
{
    CXMLElement* result = nil;
    
    NSError* error = nil;
    
    NSArray* dataArrayObjects = [self nodesForXPath:@"/document/objects/view" error:&error];
    if ( error )
    {
        NSLog(@"Error trying to find UIView root node for Xib Xcode 5: %@", error);
    }
    
    if ( [dataArrayObjects count] > 0)
    {
        result = [dataArrayObjects objectAtIndex:0];
    }

    return result;
}

-(CXMLElement*)uiViewRoot
{
    CXMLElement* root = nil;
    
    XibVersionSelector(XibVersionXcode4, root = [self uiViewRootForXibVersionXcode4] );
    XibVersionSelector(XibVersionXcode5, root = [self uiViewRootForXibVersionXcode5] );
    
    return root;
}

@end
