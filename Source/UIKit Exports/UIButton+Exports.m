//
//  UIButton+Exports.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+Exports.h"
#import "UIColor+Exports.h"
#import "UIButton+Exports.h"
#import "ExportUtility.h"
#import "CXMLElement+UIImage.h"
#import "CXMLElement+UIButton.h"

@implementation UIButton (Exports)

- (NSMutableDictionary *)exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary *dict = [ super exportToDictionary:xibElement ];
    
    //the accessibility label automatically gets filled for labels, so check for that and remove if it happened
    if ([dict objectForKey:@"instanceName"] && ([dict objectForKey:@"instanceName"] == [self titleForState:UIControlStateNormal]))
    {
        [dict removeObjectForKey:@"instanceName"];
    }
    
    //uncomment this to have the label me as titleLabel, not as a subview
    //if (self.titleLabel)
    //{
    //    [dict setObject:[self.titleLabel exportToDictionary] forKey:@"titleLabel"];
    //}
    
    //not doing this, we don't support multiple states and it's a PITA to make this work with the code exporter
    /*NSMutableDictionary *titleColors = [NSMutableDictionary dictionary];
    [titleColors setObject:[[self titleColorForState:UIControlStateNormal] exportToDictionary] forKey:@"UIControlStateNormal"];
    [titleColors setObject:[[self titleColorForState:UIControlStateApplication] exportToDictionary] forKey:@"UIControlStateApplication"];
    [titleColors setObject:[[self titleColorForState:UIControlStateHighlighted] exportToDictionary] forKey:@"UIControlStateHighlighted"];
    [titleColors setObject:[[self titleColorForState:UIControlStateDisabled] exportToDictionary] forKey:@"UIControlStateDisabled"];
    [titleColors setObject:[[self titleColorForState:UIControlStateSelected] exportToDictionary] forKey:@"UIControlStateSelected"];
    [titleColors setObject:[[self titleColorForState:UIControlStateReserved] exportToDictionary] forKey:@"UIControlStateReserved"];
    
    NSMutableDictionary *titles = [NSMutableDictionary dictionary];
    [titles setObject:[self titleForState:UIControlStateNormal] forKey:@"UIControlStateNormal"];
    [titles setObject:[self titleForState:UIControlStateApplication] forKey:@"UIControlStateApplication"];
    [titles setObject:[self titleForState:UIControlStateHighlighted] forKey:@"UIControlStateHighlighted"];
    [titles setObject:[self titleForState:UIControlStateDisabled] forKey:@"UIControlStateDisabled"];
    [titles setObject:[self titleForState:UIControlStateSelected] forKey:@"UIControlStateSelected"];
    [titles setObject:[self titleForState:UIControlStateReserved] forKey:@"UIControlStateReserved"];
    
    NSMutableDictionary *titleShadows = [NSMutableDictionary dictionary];
    [titleShadows setObject:[[self titleShadowColorForState:UIControlStateNormal] exportToDictionary] forKey:@"UIControlStateNormal"];
    [titleShadows setObject:[[self titleShadowColorForState:UIControlStateApplication] exportToDictionary] forKey:@"UIControlStateApplication"];
    [titleShadows setObject:[[self titleShadowColorForState:UIControlStateHighlighted] exportToDictionary] forKey:@"UIControlStateHighlighted"];
    [titleShadows setObject:[[self titleShadowColorForState:UIControlStateDisabled] exportToDictionary] forKey:@"UIControlStateDisabled"];
    [titleShadows setObject:[[self titleShadowColorForState:UIControlStateSelected] exportToDictionary] forKey:@"UIControlStateSelected"];
    [titleShadows setObject:[[self titleShadowColorForState:UIControlStateReserved] exportToDictionary] forKey:@"UIControlStateReserved"];
    
    [dict setObject:titles forKey:@"titles"];
    [dict setObject:titleColors forKey:@"titleColors"];
    [dict setObject:titleShadows forKey:@"titleShadowColors"];*/
    
    
    [ dict setObject:[ExportUtility exportUIButtonType:self.buttonType] forKey:@"buttonType" ];
    
    [ dict setObject:[ NSNumber numberWithBool:self.enabled ] forKey:@"enabled" ];
    
    NSString* localizedTextKey = nil;
    if ( self.TextKey )
    {
        localizedTextKey = self.TextKey;
    }
    
    if ( localizedTextKey )
    {
        NSString* defaultText = [ self titleForState:UIControlStateNormal ];
        if ( !defaultText )
        {
            defaultText = localizedTextKey;
        }
        [ dict setObject:defaultText forKey:@"localizedTitleDefaultKey" ];
        [ dict setObject:localizedTextKey forKey:@"localizedTitleKey" ];
    } else
    {
        if ( [ self titleForState:UIControlStateNormal ] )
        {
            [ dict setObject:[ self titleForState:UIControlStateNormal ] forKey:@"title" ];
        }
    }
    
    if ([self titleColorForState:UIControlStateNormal])
    {
        [dict setObject:[[self titleColorForState:UIControlStateNormal] exportToDictionary] forKey:@"titleColor"];
    }
    if ([self titleShadowColorForState:UIControlStateNormal])
    {
        [dict setObject:[[self titleShadowColorForState:UIControlStateNormal] exportToDictionary] forKey:@"titleShadowColor"];
    }
    if ([self titleColorForState:UIControlStateHighlighted])
    {
        [dict setObject:[[self titleColorForState:UIControlStateHighlighted] exportToDictionary] forKey:@"downTitleColor"];
    }
    if ([self titleShadowColorForState:UIControlStateHighlighted])
    {
        [dict setObject:[[self titleShadowColorForState:UIControlStateHighlighted] exportToDictionary] forKey:@"downTitleShadowColor"];
    }
    
    [dict setObject:[NSNumber numberWithBool:self.adjustsImageWhenHighlighted] forKey:@"adjustsImageWhenHighlighted"];
    [dict setObject:[NSNumber numberWithBool:self.adjustsImageWhenDisabled] forKey:@"adjustsImageWhenDisabled"];
    [dict setObject:[NSNumber numberWithBool:self.showsTouchWhenHighlighted] forKey:@"showsTouchWhenHighlighted"];
    
    [dict setObject:[NSNumber numberWithBool:self.adjustsImageWhenHighlighted] forKey:@"adjustsImageWhenHighlighted"];
    [dict setObject:[NSNumber numberWithBool:self.adjustsImageWhenHighlighted] forKey:@"adjustsImageWhenHighlighted"];

    if ([self backgroundImageForState:UIControlStateNormal])
    {
        NSString* imageName = [ xibElement normalBackgroundImageFileName ];
        if ( imageName )
        {
            [ dict setObject:imageName forKey:@"backgroundImage" ];
            
            //TODO: use actual values, not automatic Up and Down
            //automatically create a highlighted image we set one in the XIB
            if ( [ self backgroundImageForState:UIControlStateHighlighted ] != [ self backgroundImageForState:UIControlStateNormal ] &&
                [ imageName rangeOfString:@"Up" ].location != NSNotFound )
            {
                NSString *downImageString = [ imageName stringByReplacingOccurrencesOfString:@"Up" withString:@"Down" ];
                [ dict setObject:downImageString forKey:@"backgroundDownImage" ];
            }
        }
    }
    
    if ( self.Image )
    {
        [dict setObject:self.Image forKey:@"backgroundImage"];
    }
    
    if ( self.ImageUp )
    {
        [dict setObject:self.ImageUp forKey:@"backgroundImage"];
    }
    
    if ( self.ImageFile )
    {
        [dict setObject:self.ImageFile forKey:@"backgroundImage"];
    }
    
    if ( self.ActiveImage )
    {
        [dict setObject:self.ActiveImage forKey:@"backgroundDownImage"];
    }
    
    if ( self.ImageDown )
    {
        [dict setObject:self.ImageDown forKey:@"backgroundDownImage"];
    }
    
    
    [dict setObject:[self.titleLabel exportToDictionary:nil] forKey:@"titleLabel"];
    
    //button subviews just add a whole lot of issues - don't allow any of them
    //these are auto-added by the xib, like a label and an image
    [dict setObject:[NSMutableArray array] forKey:@"subviews"];
    
    return dict;
}

CustomMemberSynthesize( TextKey, NSString* );
CustomMemberSynthesize( Image, NSString* );
CustomMemberSynthesize( ImageUp, NSString* );
CustomMemberSynthesize( ImageFile, NSString* );
CustomMemberSynthesize( ActiveImage, NSString* );
CustomMemberSynthesize( ImageDown, NSString* );

@end
