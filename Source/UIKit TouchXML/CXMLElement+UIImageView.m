//
//  CXMLElement+UIImageView.m
//  XibExporter
//
//  Created by Ian on 9/29/13.
//
//

#import "CXMLElement+UIImageView.h"

#import "CXMLDocument+Xib.h"
#import "CXMLElement+UIImage.h"

@implementation CXMLElement (UIImageView)

-(NSString*)imageFileNameForXibVersionXcode4
{
    NSString* result = nil;
    
    CXMLElement* xibUIImage = [ self childWithAttributeValue:@"key" attributeValue:@"IBUIImage" ];
    if ( xibUIImage )
    {
        result = [ xibUIImage resourceName ];
    }
    return result;
}

-(NSString*)imageFileNameForXibVersionXcode5
{
    return [self attributeStringValueForName:@"image"];
}

-(NSString*)imageFileName
{
    NSString* result = nil;
    
    XibVersionSelector(XibVersionXcode4, result = [self imageFileNameForXibVersionXcode4] );
    XibVersionSelector(XibVersionXcode5, result = [self imageFileNameForXibVersionXcode5] );
    
    return result;
}

@end
