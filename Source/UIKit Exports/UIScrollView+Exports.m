//
//  UIScrollView+Exports.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIScrollView+Exports.h"
#import "UIView+Exports.h"
#import "ExportUtility.h"

#import "NSDictionary+ClassDefinition.h"

@implementation UIScrollView (Exports)

- (NSMutableDictionary *) exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary *dict = [super exportToDictionary:xibElement ];
    
    NSMutableArray* subviewsArray = ( NSMutableArray* )[ dict objectForKey:@"subviews" ];
    int index = 0;  
    while ( index < [ subviewsArray count ] )
    {
        NSDictionary* subclassDict = ( NSDictionary* )[ subviewsArray objectAtIndex:index ];
        if ( [ [ NSString stringWithFormat:@"%@", [ UIImageView class ] ] isEqualToString:subclassDict.className ] )
        {
            [ subviewsArray removeObjectAtIndex:index ];
        } else 
        {
            index ++;
        }
    }
    
    [dict setObject:[ExportUtility exportCGSize:self.contentSize] forKey:@"contentSize"];
    [dict setObject:[ExportUtility exportUIEdgeInsets:self.contentInset] forKey:@"contentInset"];
    [dict setObject:[NSNumber numberWithBool:self.scrollEnabled] forKey:@"scrollEnabled"];
    [dict setObject:[NSNumber numberWithBool:self.directionalLockEnabled] forKey:@"directionalLockEnabled"];
    [dict setObject:[NSNumber numberWithBool:self.scrollsToTop] forKey:@"scrollsToTop"];
    [dict setObject:[NSNumber numberWithBool:self.pagingEnabled] forKey:@"pagingEnabled"];
    [dict setObject:[NSNumber numberWithBool:self.bounces] forKey:@"bounces"];
    [dict setObject:[NSNumber numberWithBool:self.alwaysBounceVertical] forKey:@"alwaysBounceVertical"];
    [dict setObject:[NSNumber numberWithBool:self.alwaysBounceHorizontal] forKey:@"alwaysBounceHorizontal"];
    [dict setObject:[NSNumber numberWithBool:self.canCancelContentTouches] forKey:@"canCancelContentTouches"];
    [dict setObject:[NSNumber numberWithBool:self.delaysContentTouches] forKey:@"delaysContentTouches"];
    [dict setObject:[NSNumber numberWithFloat:self.decelerationRate] forKey:@"decelerationRate"];
    [dict setObject:(self.indicatorStyle == UIScrollViewIndicatorStyleDefault ? @"UIScrollViewIndicatorStyleDefault" :
                     self.indicatorStyle == UIScrollViewIndicatorStyleBlack ? @"UIScrollViewIndicatorStyleBlack" :
                     @"UIScrollViewIndicatorStyleWhite") forKey:@"indicatorStyle"];
    [dict setObject:[ExportUtility exportUIEdgeInsets:self.scrollIndicatorInsets] forKey:@"scrollIndicatorInsets"];
    [dict setObject:[NSNumber numberWithBool:self.showsHorizontalScrollIndicator] forKey:@"showsHorizontalScrollIndicator"];
    [dict setObject:[NSNumber numberWithBool:self.showsVerticalScrollIndicator] forKey:@"showsVerticalScrollIndicator"];
    [dict setObject:[NSNumber numberWithFloat:self.maximumZoomScale] forKey:@"maximumZoomScale"];
    [dict setObject:[NSNumber numberWithFloat:self.minimumZoomScale] forKey:@"minimumZoomScale"];
    [dict setObject:[NSNumber numberWithBool:self.bouncesZoom] forKey:@"bouncesZoom"];
    
    [ dict setObject:[ NSNumber numberWithBool:YES ] forKey:@"autoContentSizeToFit" ];
    return dict;
}

@end
