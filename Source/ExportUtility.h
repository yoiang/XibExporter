//
//  ExportUtility.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExportUtility : NSObject

+ (NSMutableDictionary *) exportCGSize:(CGSize)size;
+ (NSMutableDictionary *) exportCGRect:(CGRect)rect;

+(BOOL)isDictionaryEnum:(NSDictionary*)dictionary;
+ (NSMutableDictionary *) exportUIEdgeInsets:(UIEdgeInsets)insets;
+ (NSMutableDictionary *) exportUILineBreakMode:(UILineBreakMode)mode NS_DEPRECATED_IOS(2_0,6_0);
+ (NSMutableDictionary *) exportNSLineBreakMode:(NSLineBreakMode)mode NS_AVAILABLE_IOS(6_0);
+ (NSMutableDictionary *) exportUIButtonType:(UIButtonType)type;
+ (NSMutableDictionary *) exportUITextAlignment:(UITextAlignment)alignment NS_DEPRECATED_IOS(2_0,6_0);
+ (NSMutableDictionary *) exportNSTextAlignment:(NSTextAlignment)alignment NS_AVAILABLE_IOS(6_0);
+ (NSMutableDictionary *) exportUIViewContentMode:(UIViewContentMode)contentMode;
+ (NSMutableDictionary *) exportUIActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle) style;
+( NSMutableDictionary* ) exportUIKeyboardType:( UIKeyboardType ) type;
+( NSMutableDictionary* ) exportUIReturnKeyType:( UIReturnKeyType ) type;
+( NSMutableDictionary* ) exportUITextAutocapitalizationType:( UITextAutocapitalizationType ) type;
+( NSMutableDictionary* ) exportUITextBorderStyle:( UITextBorderStyle ) style;
+( NSString* ) exportUIViewAutoresizing:( UIViewAutoresizing ) mask;
@end

extern NSMutableDictionary* _uiViewCustomMemberDictionary;

#define CustomMemberHeader( Name, type ) \
@property (readwrite) type Name

#define CustomMemberSynthesize( Name, type ) \
-( void )set##Name:( type )value \
{ \
[ self addCustomMember:@"" #Name "" value:value ]; \
} \
\
-( type )Name \
{ \
return ( type )[ self getCustomMemberValue:@"" #Name "" ]; \
}

#define EnumAsString( enumValue ) \
    @""# enumValue

#define EnumToStringCase( enumValue, statement ) \
    case enumValue: \
        statement EnumAsString( enumValue ); \
        break;

#define EnumMaskToStringArray( appendToArray, enumValue ) \
    if ( mask & enumValue ) \
    { \
        [appendToArray addObject:EnumAsString( enumValue ) ]; \
    }