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

-( NSString* )attributeClassStringValue
{
    return [ self attributeStringValueForName:@"class" ];
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

-( BOOL )doesViewClassMatch:( UIView* )view
{
    BOOL result = NO;
    
    NSString* className = [ self attributeClassStringValue ];
    
    if ( [ [ className substringToIndex:2 ] isEqualToString:@"IB" ] )
    {
        className = [ className substringFromIndex:2 ];
    }
    
    Class xibNodeClass = NSClassFromString( className );
    if ( [ view isKindOfClass:xibNodeClass ] )
    {
        result = YES;
    } else
    {
        NSLog( @"Error: xib node (%@) does not match view (%@)", xibNodeClass, [ view class ] );
    }
    
    return result;
}

@end
