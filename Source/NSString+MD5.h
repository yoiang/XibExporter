//
//  NSString+MD5.h
//  XibExporter
//
//  Created by Ian on 9/25/13.
//
//  http://stackoverflow.com/questions/1524604/md5-algorithm-in-objective-c
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

+(NSString *)stringMD5OfContentsOfFile:(NSString *)fileName encoding:(NSStringEncoding)encoding error:(NSError **)error;
-(NSString *)md5;

@end
