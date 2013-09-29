//
//  CXMLElement+UIButton.m
//  XibExporter
//
//  Created by Ian on 9/29/13.
//
//

#import "CXMLElement+UIButton.h"

#import "CXMLDocument+Xib.h"
#import "CXMLElement+UIView.h"
#import "CXMLElement+UIImage.h"

@implementation CXMLElement (UIButton)

-(NSString*)normalBackgroundImageFileNameForXibVersionXcode4
{
    NSString* result = nil;
    
    CXMLElement* xibUIImage = [ self childWithAttributeValue:@"key" attributeValue:@"IBUINormalBackgroundImage" ];
    if ( xibUIImage )
    {
        result = [ xibUIImage resourceName ];
    }
    
    return result;
}

-(NSString*)normalBackgroundImageFileNameForXibVersionXcode5
{
    NSString* result = nil;
    
    CXMLElement* normalState = [self normalState];
    
    result = [normalState attributeStringValueForName:@"backgroundImage"];
    
    return result;
}

-(NSString*)normalBackgroundImageFileName
{
    NSString* result = nil;
    
    XibVersionSelector(XibVersionXcode4, result = [self normalBackgroundImageFileNameForXibVersionXcode4] );
    XibVersionSelector(XibVersionXcode5, result = [self normalBackgroundImageFileNameForXibVersionXcode5] );
    
    return result;
}

-(CXMLElement*)stateWithKey:(NSString*)key
{
    CXMLElement* result = nil;
    
    NSArray* states = [self elementsForName:@"state"];
    for (CXMLElement* state in states)
    {
        if ( [state attributeStringValueForName:@"key"] )
        {
            result = state;
            break;
        }
    }
    
    return result;
}

-(CXMLElement*)normalState
{
    return [self stateWithKey:@"normal"];
}

@end
