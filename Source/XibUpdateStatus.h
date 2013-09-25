//
//  XibUpdateStatus.h
//  XibExporter
//
//  Created by Ian on 9/26/13.
//
//

#import <Foundation/Foundation.h>

@interface XibUpdateStatus : NSObject

-(void)updateXib:(NSString*)xibName withMD5:(NSString*)md5;
-(BOOL)hasXibChanged:(NSString*)xibName;
-(void)saveCurrentStatus;

@end
