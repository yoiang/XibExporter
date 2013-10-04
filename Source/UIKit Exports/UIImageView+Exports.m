//
//  UIImageView+Exports.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+Exports.h"
#import "UIViewController+Exports.h"

#import "UIView+Exports.h"
#import "CXMLElement+Xib.h"
#import "CXMLElement+UIImage.h"
#import "CXMLElement+UIImageView.h"

#import "NSMutableDictionary+InstanceDefinition.h"

@implementation UIImageView (Exports)

- (NSMutableDictionary *)exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary *dict = [super exportToDictionary: xibElement ];
    
    [dict setObject:[NSNumber numberWithBool:self.highlighted] forKey:@"highlighted"];
    //not doing it this way, using accessibility hint instead
    //[dict setObject:[self.image getImagePath] forKey:@"image"];
    
    BOOL hadImage = NO;
    
    NSString* imageName = [ xibElement imageFileName ];
    if ( imageName )
    {
        [ dict setObject:imageName forKey:@"image" ];
        hadImage = YES;
    }
    
    if ( !hadImage && self.ImageFile )
    {
        [dict setObject:self.ImageFile forKey:@"image"];
        hadImage = YES;
    }
    
    if ( !hadImage )
    {
        [dict addComment:@"Note: no image set for view"];
    }
    
    return dict;
}

CustomMemberSynthesize( ImageFile, NSString* );

@end
