//
//  ViewGraphs.h
//  XibExporter
//
//  Created by Ian on 9/13/13.
//
//

#import <Foundation/Foundation.h>

@class ViewGraphData;

@interface ViewGraphs : NSObject

@property (readonly,getter = xibNames) NSArray* xibNames;
-(void)processXib:(NSString*)xibName;
-(ViewGraphData*)dataForXib:(NSString*)xibName;

@end
