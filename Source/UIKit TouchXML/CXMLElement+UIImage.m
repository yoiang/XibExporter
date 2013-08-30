//
//  CXMLElement+UIImage.m
//  XibExporter
//
//  Created by Ian Grossberg on 3/21/13.
//
//

#import "CXMLElement+UIImage.h"
#import "CXMLElement+Xib.h"
#import "ViewExporter.h"

@implementation CXMLElement (UIImage)

-( NSString* )resourceName
{
    NSString* result = nil;
    
    CXMLElement* root = nil;
    if ( [ [ self name ] isEqualToString:@"object" ] )
    {
        root = self;
        [ [ ViewExporter sharedInstance ] addXibResource:self ];
    } else if ( [ [ self name ] isEqualToString:@"reference" ] )
    {
        NSString* referenceId = [ self attributeRefStringValue ];
        root = [ [ ViewExporter sharedInstance ] getXibResource:referenceId ];
    }
    
    CXMLElement* nsResourceName = [ root childWithAttributeValue:@"key" attributeValue:@"NSResourceName" ];
    if ( nsResourceName )
    {
        result = [ nsResourceName stringValue ];
    }

    
    return result;
}

@end
