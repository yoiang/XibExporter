//
//  CXMLElement+Xib.h
//  XibExporter
//
//  Created by Ian Grossberg on 3/20/13.
//
//

#import "TouchXML.h"

@interface CXMLElement (Xib)

-( NSString* )attributeStringValueForName:( NSString* )name;
-( NSString* )attributeKeyStringValue;
-( NSString* )attributeClassStringValue;
-( NSString* )attributeIdStringValue;
-( NSString* )attributeRefStringValue;

-( CXMLElement* )childElementAtIndex:( NSUInteger )index;

-( CXMLElement* )childWithAttributeValue:( NSString* )attribute attributeValue:( NSString* )value;

-( BOOL )doesViewClassMatch:( UIView* )view;

@end
