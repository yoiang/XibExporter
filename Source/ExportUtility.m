//
//  ExportUtility.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExportUtility.h"

@implementation ExportUtility

+ (NSMutableDictionary *) exportCGSize:(CGSize)size
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:size.width], @"width",
            [NSNumber numberWithFloat:size.height], @"height",
            @"CGSize", @"class", nil];
}

+ (NSMutableDictionary *) exportCGRect:(CGRect)rect
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:rect.origin.x], @"x",
            [NSNumber numberWithFloat:rect.origin.y], @"y",
            [NSNumber numberWithFloat:rect.size.width], @"width",
            [NSNumber numberWithFloat:rect.size.height], @"height",
            @"CGRect", @"class", nil];
}

+ (NSMutableDictionary *) exportUIEdgeInsets:(UIEdgeInsets)insets
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:insets.top], @"top",
            [NSNumber numberWithFloat:insets.left], @"left",
            [NSNumber numberWithFloat:insets.right], @"right",
            [NSNumber numberWithFloat:insets.bottom], @"bottom",
            @"UIEdgeInsets", @"class", nil];
}

+(NSMutableDictionary*)mark:(NSMutableDictionary*)dictionary asType:(NSString*)type
{
    [dictionary setObject:type forKey:@"type"];
    return dictionary;
}

+(NSString*)getType:(NSDictionary*)dictionary
{
    return [dictionary objectForKey:@"type"];
}

+(NSMutableDictionary*)markAsEnumType:(NSMutableDictionary*)dictionary
{
    return [self mark:dictionary asType:@"enum"];
}

+(BOOL)isDictionaryEnum:(NSDictionary*)dictionary
{
    return [ [self getType:dictionary] isEqualToString:@"enum"];
}

+ (NSMutableDictionary *) exportUILineBreakMode:(UILineBreakMode)mode
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"UILineBreakMode" forKey:@"class"];
    NSString *v = @"";
    
    switch (mode)
    {
        case UILineBreakModeCharacterWrap:
            v = @"UILineBreakModeCharacterWrap";
        break;
        case UILineBreakModeClip:
            v = @"UILineBreakModeClip";
        break;
        case UILineBreakModeHeadTruncation:
            v = @"UILineBreakModeHeadTruncation";
        break;
        case UILineBreakModeMiddleTruncation:
            v = @"UILineBreakModeMiddleTruncation";
        break;
        case UILineBreakModeWordWrap:
            v = @"UILineBreakModeWordWrap";
        break;
        case UILineBreakModeTailTruncation:
            v = @"UILineBreakModeTailTruncation";
        break;
    }
    [dict setObject:v forKey:@"lineBreakMode"];
    [self markAsEnumType:dict];
    return dict;
}

+ (NSMutableDictionary *) exportUIButtonType:(UIButtonType)type
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"UIButtonType" forKey:@"class"];
    NSString *v = @"UIButtonTypeRoundedRect";
    switch ( type )
    {
        case UIButtonTypeCustom:
            v = @"UIButtonTypeCustom";
            break;
        case UIButtonTypeRoundedRect:
            v = @"UIButtonTypeRoundedRect";
            break;
        case UIButtonTypeInfoDark:
            v = @"UIButtonTypeInfoDark";
            break;
        case UIButtonTypeInfoLight:
            v = @"UIButtonTypeInfoLight";
            break;
        case UIButtonTypeDetailDisclosure:
            v = @"UIButtonTypeDetailDisclosure";
            break;
        case UIButtonTypeContactAdd:
            v = @"UIButtonTypeContactAdd";
            break;
    }
    [dict setObject:v forKey:@"buttonType"];
    [self markAsEnumType:dict];
    return dict;
}

+ (NSMutableDictionary *) exportUITextAlignment:(UITextAlignment)alignment
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"UITextAlignment" forKey:@"class"];
    NSString *v = @"UITextAlignmentLeft";
    switch ( alignment )
    {
        case UITextAlignmentCenter:
            v = @"UITextAlignmentCenter";
            break;
        case UITextAlignmentLeft:
            v = @"UITextAlignmentLeft";
            break;
        case UITextAlignmentRight:
            v = @"UITextAlignmentRight";
            break;
    }
    [dict setObject:v forKey:@"textAlignment"];
    [self markAsEnumType:dict];
    return dict;
}

+ (NSMutableDictionary *) exportUIViewContentMode:(UIViewContentMode)contentMode
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"UIViewContentMode" forKey:@"class"];
    NSString *v = @"UIViewContentModeScaleToFill";
    switch ( contentMode )
    {
        case UIViewContentModeScaleToFill:
            v = @"UIViewContentModeScaleToFill";
            break;
        case UIViewContentModeScaleAspectFit:
            v = @"UIViewContentModeScaleAspectFit";
            break;
        case UIViewContentModeScaleAspectFill:
            v = @"UIViewContentModeScaleAspectFill";
            break;
        case UIViewContentModeRedraw:
            v = @"UIViewContentModeRedraw";
            break;
        case UIViewContentModeCenter:
            v = @"UIViewContentModeCenter";
            break;
        case UIViewContentModeTop:
            v = @"UIViewContentModeTop";
            break;
        case UIViewContentModeBottom:
            v = @"UIViewContentModeBottom";
            break;
        case UIViewContentModeLeft:
            v = @"UIViewContentModeLeft";
            break;
        case UIViewContentModeRight:
            v = @"UIViewContentModeRight";
            break;
        case UIViewContentModeTopLeft:
            v = @"UIViewContentModeTopLeft";
            break;
        case UIViewContentModeTopRight:
            v = @"UIViewContentModeTopRight";
            break;
        case UIViewContentModeBottomLeft:
            v = @"UIViewContentModeBottomLeft";
            break;
        case UIViewContentModeBottomRight:
            v = @"UIViewContentModeBottomRight";
            break;
    }
    [dict setObject:v forKey:@"contentMode"];
    [self markAsEnumType:dict];
    return dict;
}

+ (NSMutableDictionary *) exportUIActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle) style
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"UIActivityIndicatorViewStyle" forKey:@"class"];
    NSString *v = @"UIActivityIndicatorViewStyleWhite";
    switch ( style )
    {
        case UIActivityIndicatorViewStyleWhiteLarge:
            v = @"UIActivityIndicatorViewStyleWhiteLarge";
            break;
        case UIActivityIndicatorViewStyleWhite:
            v = @"UIActivityIndicatorViewStyleWhite";
            break;
        case UIActivityIndicatorViewStyleGray:
            v = @"UIActivityIndicatorViewStyleGray";
            break;
    }
    [dict setObject:v forKey:@"indicatorStyle"];
    [self markAsEnumType:dict];
    return dict;
}

NSString* UIKeyboardTypeToString( UIKeyboardType type )
{
    NSString* result = EnumAsString( UIKeyboardTypeDefault );
    switch ( type )
    {
            EnumToStringCase( UIKeyboardTypeDefault, result = );
            EnumToStringCase( UIKeyboardTypeASCIICapable, result = );
            EnumToStringCase( UIKeyboardTypeNumbersAndPunctuation, result = );
            EnumToStringCase( UIKeyboardTypeURL, result = );
            EnumToStringCase( UIKeyboardTypeNumberPad, result = );
            EnumToStringCase( UIKeyboardTypePhonePad, result = );
            EnumToStringCase( UIKeyboardTypeNamePhonePad, result = );
            EnumToStringCase( UIKeyboardTypeEmailAddress, result = );
#if __IPHONE_4_1 <= __IPHONE_OS_VERSION_MAX_ALLOWED
            EnumToStringCase( UIKeyboardTypeDecimalPad, result = );
#endif
#if __IPHONE_5_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
            EnumToStringCase( UIKeyboardTypeTwitter, result = );
#endif
    }
    return result;
}

+( NSMutableDictionary* ) exportUIKeyboardType:( UIKeyboardType ) type
{
    NSMutableDictionary* dict = [ NSMutableDictionary dictionary ];
    [ dict setObject:@"UIKeyboardType" forKey:@"class" ];
    [ dict setObject:UIKeyboardTypeToString( type ) forKey:@"keyboardType" ];
    [self markAsEnumType:dict];
    return dict;
}

NSString* UIReturnKeyTypeToString( UIReturnKeyType type )
{
    NSString* result = EnumAsString( UIReturnKeyDefault );
    switch ( type )
    {
            EnumToStringCase( UIReturnKeyDefault, result = );
            EnumToStringCase( UIReturnKeyGo, result = );
            EnumToStringCase( UIReturnKeyGoogle, result = );
            EnumToStringCase( UIReturnKeyJoin, result = );
            EnumToStringCase( UIReturnKeyNext, result = );
            EnumToStringCase( UIReturnKeyRoute, result = );
            EnumToStringCase( UIReturnKeySearch, result = );
            EnumToStringCase( UIReturnKeySend, result = );
            EnumToStringCase( UIReturnKeyYahoo, result = );
            EnumToStringCase( UIReturnKeyDone, result = );
            EnumToStringCase( UIReturnKeyEmergencyCall, result = );
    }
    return result;
}

+( NSMutableDictionary* ) exportUIReturnKeyType:( UIReturnKeyType ) type
{
    NSMutableDictionary* dict = [ NSMutableDictionary dictionary ];
    [ dict setObject:@"UIReturnKeyType" forKey:@"class" ];
    [ dict setObject:UIReturnKeyTypeToString( type ) forKey:@"returnKeyType" ];
    [self markAsEnumType:dict];
    return dict;
}

NSString* UITextAutocapitalizationTypeToString( UITextAutocapitalizationType type )
{
    NSString* result = EnumAsString( UITextAutocapitalizationTypeNone );
    switch ( type )
    {
            EnumToStringCase( UITextAutocapitalizationTypeNone, result = );
            EnumToStringCase( UITextAutocapitalizationTypeWords, result = );
            EnumToStringCase( UITextAutocapitalizationTypeSentences, result = );
            EnumToStringCase( UITextAutocapitalizationTypeAllCharacters, result = );
    }
    return result;
}

+( NSMutableDictionary* ) exportUITextAutocapitalizationType:( UITextAutocapitalizationType ) type
{
    NSMutableDictionary* dict = [ NSMutableDictionary dictionary ];
    [ dict setObject:@"UITextAutocapitalizationType" forKey:@"class" ];
    [ dict setObject:UITextAutocapitalizationTypeToString( type ) forKey:@"autocapitalizationType" ];
    [self markAsEnumType:dict];
    return dict;
}

NSString* UITextBorderStyleToString( UITextBorderStyle type )
{
    NSString* result = EnumAsString( UITextBorderStyleNone );
    switch ( type )
    {
            EnumToStringCase( UITextBorderStyleNone, result = );
            EnumToStringCase( UITextBorderStyleLine, result = );
            EnumToStringCase( UITextBorderStyleBezel, result = );
            EnumToStringCase( UITextBorderStyleRoundedRect, result = );
    }
    return result;
}

+( NSMutableDictionary* ) exportUITextBorderStyle:( UITextBorderStyle ) style
{
    NSMutableDictionary* dict = [ NSMutableDictionary dictionary ];
    [ dict setObject:@"UITextBorderStyle" forKey:@"class" ];
    [ dict setObject:UITextBorderStyleToString( style ) forKey:@"textBorderStyle" ];
    [self markAsEnumType:dict];
    return dict;
}

NSArray* UIViewAutoresizingToArray( UIViewAutoresizing mask )
{
    NSMutableArray* result = [NSMutableArray array];
    EnumMaskToStringArray( result, UIViewAutoresizingFlexibleLeftMargin );
    EnumMaskToStringArray( result, UIViewAutoresizingFlexibleWidth );
    EnumMaskToStringArray( result, UIViewAutoresizingFlexibleRightMargin );
    EnumMaskToStringArray( result, UIViewAutoresizingFlexibleTopMargin );
    EnumMaskToStringArray( result, UIViewAutoresizingFlexibleHeight );
    EnumMaskToStringArray( result, UIViewAutoresizingFlexibleBottomMargin );
    
    if ( [result count] == 0 )
    {
//        EnumToMask(result, UIViewAutoresizingNone); // TODO: Test
        [result addObject:EnumAsString(UIViewAutoresizingNone) ];
    }

    return result;
}

+( NSArray* ) exportUIViewAutoresizing:( UIViewAutoresizing ) mask
{
    NSMutableArray* result = [NSMutableArray array];
    for (NSString* value in UIViewAutoresizingToArray( mask ) )
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:@"UIViewAutoresizing" forKey:@"class"];
        [dict setObject:value forKey:@"autoresizingMask"];
        [self markAsEnumType:dict];
        
        [result addObject:dict];
    }
    return result;
}

@end
