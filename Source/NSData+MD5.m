//
//  NSData+MD5.m
//  XibExporter
//
//  Created by Ian on 9/25/13.
//
//

#import "NSData+MD5.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSData (MD5)

+(NSString *)stringMD5OfContentsOfFile:(NSString *)fileName
{
    NSData *dataWithContentsOfFile = [NSData dataWithContentsOfFile:fileName];
    return [dataWithContentsOfFile md5];
}

-(NSString *)md5
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( self.bytes, self.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end
