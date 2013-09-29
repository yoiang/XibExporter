//
//  NSError+NSLog.m
//  XibExporter
//
//  Created by Ian on 9/29/13.
//
//

#import "NSError+NSLog.h"

@implementation NSError (NSLog)

-(void)log:(NSString *)message
{
    if (self)
    {
        if (message && [message length] > 0)
        {
            NSLog(@"%@: %@", message, self);
        } else
        {
            NSLog(@"%@", self);
        }
            
    }
}

@end
