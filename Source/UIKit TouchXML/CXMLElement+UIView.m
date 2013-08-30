//
//  CXMLElement+UIView.m
//  XibExporter
//
//  Created by Ian Grossberg on 3/21/13.
//
//

#import "CXMLElement+UIView.h"

@implementation CXMLElement (UIView)

-( CXMLElement* )subviews
{
    CXMLElement* result = nil;
    
    for ( CXMLNode* childNode in [ self children ] )
    {
        if ( [ childNode kind ] == CXMLElementKind )
        {
            CXMLElement* childElement = ( CXMLElement* )childNode;
            if ( [ [ childElement attributeKeyStringValue ] isEqualToString:@"NSSubviews" ] )
            {
                result = childElement;
                break;
            }
        }
    }
    
    return result;
}

-( CXMLElement* )subviewAtIndex:( NSUInteger )index
{
    CXMLElement* result = nil;
    
    CXMLElement* subviews = [ self subviews ];
    if ( subviews )
    {
        result = [ subviews childElementAtIndex:index ];
    }
    
    return result;
}

@end
