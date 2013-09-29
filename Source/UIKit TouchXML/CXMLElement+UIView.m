//
//  CXMLElement+UIView.m
//  XibExporter
//
//  Created by Ian Grossberg on 3/21/13.
//
//

#import "CXMLElement+UIView.h"

#import "CXMLDocument+Xib.h"
#import "NSError+NSLog.h"

@implementation CXMLElement (UIView)

-(CXMLElement*)subViewsForXibVersionXcode4
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

-(CXMLElement*)subViewsForXibVersionXcode5
{
    NSError* error = nil;
    CXMLElement* result = (CXMLElement*)[self nodeForXPath:@"subviews" error:&error];
    [error log:[ NSString stringWithFormat:@"Error retrieving subview for CXMLElement %@", self] ];

    return result;
}

-( CXMLElement* )subviews
{
    CXMLElement* result = nil;    
    XibVersionSelector(XibVersionXcode4, result = [self subViewsForXibVersionXcode4] );
    XibVersionSelector(XibVersionXcode5, result = [self subViewsForXibVersionXcode5] );
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
