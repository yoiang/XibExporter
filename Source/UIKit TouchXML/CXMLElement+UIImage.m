//
//  CXMLElement+UIImage.m
//  XibExporter
//
//  Created by Ian Grossberg on 3/21/13.
//
//

#import "CXMLElement+UIImage.h"
#import "CXMLElement+Xib.h"

#import "AppDelegate.h"
#import "XibResources.h"

@implementation CXMLElement (UIImage)

-( NSString* )resourceName
{
    NSString* result = nil;
    
    CXMLElement* root = nil;
    if ( [ [ self name ] isEqualToString:@"object" ] )
    {
        root = self;
        [ [ [AppDelegate sharedInstance] xibResources] addXibResource:self];
    } else if ( [ [ self name ] isEqualToString:@"reference" ] )
    {
        NSString* referenceId = [ self attributeRefStringValue ];
        root = [ [ [AppDelegate sharedInstance] xibResources] getXibResource:referenceId ];
    }
    
    CXMLElement* nsResourceName = [ root childWithAttributeValue:@"key" attributeValue:@"NSResourceName" ];
    if ( nsResourceName )
    {
        result = [ nsResourceName stringValue ];
    }

    
    return result;
}

@end
