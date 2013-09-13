//
//  XibResources.h
//  XibExporter
//
//  Created by Ian on 9/13/13.
//
//

#import <Foundation/Foundation.h>

@class CXMLElement;

@interface XibResources : NSObject

-(void)clearXibResources;
-(void)addXibResource:(CXMLElement*)element;
-(CXMLElement*)getXibResource:(NSString*)referenceId;

@end
