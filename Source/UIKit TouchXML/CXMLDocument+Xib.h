//
//  CXMLDocument+Xib.h
//  XibExporter
//
//  Created by Ian on 9/29/13.
//
//

#import "CXMLDocument.h"

typedef NS_ENUM(NSInteger, XibVersion)
{
    XibVersionUnsupported = 0,
    XibVersionXcode4,
    XibVersionXcode5
};

#define XibVersionSelector( Version, statement ) \
    if ( [self xibVersion] == Version ) \
    { \
        statement; \
    }

@interface CXMLDocument (Xib)

-(XibVersion)xibVersion;

-(CXMLElement*)uiViewRoot;

@end
