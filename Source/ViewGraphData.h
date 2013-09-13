//
//  ViewGraphData.h
//  XibExporter
//
//  Created by Ian on 9/13/13.
//
//

#import <Foundation/Foundation.h>

@interface ViewGraphData : NSObject

-(id)initWithXib:(NSString*)xibName;
@property (nonatomic, readonly) NSString *xibName;
@property (nonatomic, readonly) NSMutableDictionary *data;

@end
