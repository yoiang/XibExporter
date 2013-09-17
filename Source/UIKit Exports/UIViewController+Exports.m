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
    /*NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    
    
    return dict;*/
    
    //TODO add outlets and shit for the vc
    @try
    {
        UIView *v = self.view;
        NSMutableDictionary *d = [v exportToDictionary:xibNode ];
        //this must be set manually in the XIB so I'm currently not actually using it for anything
        //right now there is a hack where a 460 high view is automatically positioned at 20 Y, this would be the route to replace that if necessary
        [d setObject:[NSNumber numberWithBool:self.wantsFullScreenLayout] forKey:@"wantsFullScreenLayout"];
        return d;
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
