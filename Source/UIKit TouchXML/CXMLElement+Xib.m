//
//  CXMLElement+Xib.m
//  XibExporter
//
//  Created by Ian Grossberg on 3/20/13.
//
//

#import "CXMLElement+Xib.h"

@implementation CXMLElement (Xib)

-( NSString* )attributeStringValueForName:( NSString* )name
{
    NSString* result = nil;
    
    CXMLNode* attribute = [ self attributeForName:name ];
    if ( attribute )
    {
        result = [ attribute stringValue ];
    }
    return result;
}

-( NSString* )attributeKeyStringValue
{
    return [ self attributeStringValueForName:@"key" ];
}

-( Class )classTypeForXibVersionXcode4
{
    NSString* className = [ self attributeStringValueForName:@"class" ];
    
    if ( [ [ className substringToIndex:2 ] isEqualToString:@"IB" ] )
    {
        className = [ className substringFromIndex:2 ];
    }
    
    return NSClassFromString( className );
}

-( Class )classTypeForXibVersionXcode5
{
    Class result = nil;
    
    NSString* name = [self name];
    if ( [name isEqualToString:@"view"] )
    {
        result = [UIView class];
    } else if ( [name isEqualToString:@"label"] )
    {
        result = [UILabel class];
    } else if ( [name isEqualToString:@"button"] )
    {
        result = [UIButton class];
    } else if ( [name isEqualToString:@"imageView"] )
    {
        result = [UIImageView class];
    } else
    {
        NSLog(@"Unsupported class type for name %@", name);
    }
    return result;
}

-( Class )classType
{
    Class result = nil;

    XibVersionSelector( XibVersionXcode4, result = [self classTypeForXibVersionXcode4] );
    XibVersionSelector( XibVersionXcode5, result = [self classTypeForXibVersionXcode5] );
    
    return result;
}

-( NSString* )attributeIdStringValue
{
    return [ self attributeStringValueForName:@"id" ];
}

-( NSString* )attributeRefStringValue
{
    return [ self attributeStringValueForName:@"ref" ];
}

-( CXMLElement* )childElementAtIndex:( NSUInteger )index
{
    CXMLElement* result = nil;
    
    NSUInteger childElementCount = 0;
    for ( CXMLNode* childNode in [ self children ] )
    {
        if ( [ childNode kind ] == CXMLElementKind )
        {
            CXMLElement* childElement = ( CXMLElement* )childNode;
            if ( childElementCount == index )
            {
                result = childElement;
                break;
            }
            childElementCount ++;
        }
    }
    
    return result;
}

-( CXMLElement* )childWithAttributeValue:( NSString* )attribute attributeValue:( NSString* )value
{
    CXMLElement* result = nil;
    
    for ( CXMLNode* childNode in [ self children ] )
    {
        if ( [ childNode kind ] == CXMLElementKind )
        {
            CXMLElement* childElement = ( CXMLElement* )childNode;
            CXMLNode* attributeNode = [ childElement attributeForName:attribute ];
            if ( attributeNode && [ [ attributeNode stringValue ] isEqualToString:value ] )
            {
                result = childElement;
                break;
            }
        }
    }
    
    return result;
}

-(XibVersion)xibVersion
{
    return [ [self rootDocument] xibVersion];
}

@end
