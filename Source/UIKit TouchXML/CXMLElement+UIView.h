//
//  CXMLElement+UIView.h
//  XibExporter
//
//  Created by Ian Grossberg on 3/21/13.
//
//

#import "CXMLElement+Xib.h"

@interface CXMLElement (UIView)

-( CXMLElement* )subviews;
-( CXMLElement* )subviewAtIndex:( NSUInteger )index;

@end
