//
//  FontExchange.h
//  XibExporter
//
//  Created by Ian on 9/13/13.
//
//

#import <Foundation/Foundation.h>

@interface FontExchange : NSObject

+( FontExchange* )sharedInstance;
-( NSString* )exchangeFont:( NSString* )fontName;

@end
