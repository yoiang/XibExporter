//
//  UIPageControl+Exports.m
//  XibExporter
//
//  Created by Eli Delventhal on 9/4/12.
//
//

#import "UIPageControl+Exports.h"
#import "UIView+Exports.h"

@implementation UIPageControl (Exported)

-( NSMutableDictionary* )exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary *dict = [super exportToDictionary:xibElement];
    
    [ dict setObject:[ NSNumber numberWithInt:self.currentPage ] forKey:@"currentPage" ];
    [ dict setObject:[ NSNumber numberWithInt:self.numberOfPages ] forKey:@"numberOfPages" ];
    [ dict setObject:[ NSNumber numberWithBool:self.hidesForSinglePage ] forKey:@"hidesForSinglePage" ];
    [ dict setObject:[ NSNumber numberWithBool:self.defersCurrentPageDisplay ] forKey:@"defersCurrentPageDisplay" ];
    
    return dict;
}

@end
