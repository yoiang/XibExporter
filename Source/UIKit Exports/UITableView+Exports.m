//
//  UITableView+Exports.m
//  XibExporter
//
//  Created by Ian Grossberg on 4/16/12.
//

#import "UITableView+Exports.h"
#import "UIView+Exports.h"
#import "UIColor+Exports.h"
#import "ExportUtility.h"

@implementation UITableView (Exported)

-( NSMutableDictionary* )exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary* dict = [ super exportToDictionary:xibElement ];
    
    /*
     typedef enum {
     UITableViewStylePlain,                  // regular table view
     UITableViewStyleGrouped                 // preferences style table view
     } UITableViewStyle;
     */
    [ dict setObject:[ NSNumber numberWithInt:self.style ] forKey:@"style" ];
    
    [ dict setObject:[ NSNumber numberWithInt:self.separatorStyle ] forKey:@"separatorStyle" ];
    if ( self.separatorColor )
    {
        [ dict setObject:[ self.separatorColor exportToDictionary ] forKey:@"separatorColor" ];
    }
    
    [ dict setObject:[ NSNumber numberWithBool:self.allowsSelection ] forKey:@"allowsSelection" ];
    [ dict setObject:[ NSNumber numberWithBool:self.allowsSelectionDuringEditing ] forKey:@"allowsSelectionDuringEditing" ];
    [ dict setObject:[ NSNumber numberWithBool:self.allowsMultipleSelection ] forKey:@"allowsMultipleSelection" ];
    [ dict setObject:[ NSNumber numberWithBool:self.allowsMultipleSelectionDuringEditing ] forKey:@"allowsMultipleSelectionDuringEditing" ];
    
    // index row limit
    
    [ dict setObject:[ NSNumber numberWithInt:self.rowHeight ] forKey:@"rowHeight" ];
    [ dict setObject:[ NSNumber numberWithInt:self.sectionHeaderHeight ] forKey:@"sectionHeaderHeight" ];
    [ dict setObject:[ NSNumber numberWithInt:self.sectionFooterHeight ] forKey:@"sectionFooterHeight" ];

    if ( self.contentInset.bottom != 0 )
    {
        [ dict setObject:[ NSNumber numberWithInt:abs( self.contentInset.bottom ) ] forKey:@"contentInsetBottom" ];
    }
    
    return dict;
}

@end