//
//  CXMLElement+Xib.h
//  XibExporter
//
//  Created by Ian Grossberg on 3/20/13.
//
//

#import "TouchXML.h"

#import "CXMLDocument+Xib.h"

@interface CXMLElement (Xib)

-( NSString* )attributeStringValueForName:( NSString* )name;
-( NSString* )attributeKeyStringValue;

-( Class )classType;

-( NSString* )attributeIdStringValue;
-( NSString* )attributeRefStringValue;

-( CXMLElement* )childElementAtIndex:( NSUInteger )index;

-( CXMLElement* )childWithAttributeValue:( NSString* )attribute attributeValue:( NSString* )value;

-( XibVersion )xibVersion;

@end
