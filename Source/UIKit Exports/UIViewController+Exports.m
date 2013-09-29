//
//  UIViewController+SavedPath.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Exports.h"

#import "UIView+Exports.h"

@implementation UIViewController (Exports)

#pragma mark Public Functions

- (NSMutableDictionary *)exportToDictionary:( CXMLElement* )xibNode xibName:( NSString* )xibName
{
    @try
    {
        return [self.view exportToDictionary:xibNode];
    }
    @catch (NSException *exception)
    {
        NSString* message = [NSString stringWithFormat:@"Exception processing %@, potentially need to set File Owner as a UIViewController and then link the view outlet!\n\n%@",xibName, exception];
        NSLog( @"%@", message );
        [[[UIAlertView alloc] initWithTitle:@"You fail!" message:message  delegate:nil cancelButtonTitle:@"Darn" otherButtonTitles:nil] show];
    }
    return nil;
}

@end
