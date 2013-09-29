//
//  ExportedUIView.m
//  XibExporter
//
//  Exports a UIView to an NSMutableDictionary
//
//  Created by Eli Delventhal on 4/2/12.
//

#import "UIView+Exports.h"
#import "ExportedViewMap.h"
#import "UIColor+Exports.h"
#import "ExportUtility.h"

#import "CXMLElement+UIView.h"

static int viewId = 0;

@implementation UIView (Exported)

-( BOOL )isMarkedForFlattening:( NSString* )accessibilityLabel
{
    if ( [ accessibilityLabel isEqualToString:@"_FLATTENED" ] )
        return YES;
    if ( [ accessibilityLabel isEqualToString:@"_FLATTEN" ] )
        return YES;
    return NO;
}

-( BOOL )isMarkedForExportingCode:( NSString* )accessibilityLabel
{
    if ( [ accessibilityLabel isEqualToString:@"_EXPORTED" ] )
        return YES;
    if ( [ accessibilityLabel isEqualToString:@"_EXPORT" ] )
        return YES;
    return NO;
}

-( NSMutableDictionary* )exportToDictionaryFlattened:( CXMLElement* )xibElement
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    UIView* contentView = [self.subviews objectAtIndex:0];
    CXMLElement* xibContentView = [ xibElement subviewAtIndex:0 ];

    dict = [ contentView exportToDictionary:xibContentView ];
    
    if (self.accessibilityHint && [self.accessibilityHint length] > 0 && !([self.accessibilityHint isEqualToString:self.accessibilityLabel]))
    {
        [dict setObject:self.accessibilityHint forKey:@"instanceName"];
    }
    [dict setObject:[ExportUtility exportCGRect:self.frame] forKey:@"frame"];
    
    return dict;
}

-( NSMutableDictionary* )exportToDictionaryUIView:( CXMLElement* )xibElement
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if ( [self isMarkedForExportingCode:self.accessibilityLabel] )
    {
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"exportToCode"];
    }
    
    //globally defined stuff
    [dict setObject:[NSString stringWithFormat:@"%@",[self class]] forKey:@"class"];
    [dict setObject:[NSNumber numberWithInt:viewId] forKey:@"viewId"];
    [[ExportedViewMap sharedInstance] setId:viewId forView:self];
    viewId++;
    if (self.superview) //don't necessarily need this but what the hey
    {
        int parentViewId = [[ExportedViewMap sharedInstance] getViewId:self.superview];
        [dict setObject:[NSNumber numberWithInt:parentViewId] forKey:@"superview"];
    }
    
    if ( self.Outlet )
    {
        [dict setObject:self.Outlet forKey:@"instanceName"];
    }
    
    //UIView specific stuff
    [dict setObject:[NSNumber numberWithFloat:self.alpha]  forKey:@"alpha"];
    [dict setObject:[ExportUtility exportCGRect:self.frame] forKey:@"frame"];
    if (self.backgroundColor)
    {
        [dict setObject:[self.backgroundColor exportToDictionary] forKey:@"backgroundColor"];
    }
    else
    {
        [dict setObject:[[UIColor clearColor] exportToDictionary] forKey:@"backgroundColor"];
    }
    [dict setObject:[NSNumber numberWithBool:self.userInteractionEnabled] forKey:@"userInteractionEnabled"];
    [dict setObject:[NSNumber numberWithBool:self.multipleTouchEnabled] forKey:@"multipleTouchEnabled"];
    [dict setObject:[NSNumber numberWithBool:self.exclusiveTouch] forKey:@"exclusiveTouch"];
    [dict setObject:[NSNumber numberWithBool:self.autoresizesSubviews] forKey:@"autoresizesSubviews"];
    [dict setObject:[NSNumber numberWithInt:self.tag] forKey:@"tag"];
    [dict setObject:[NSNumber numberWithBool:!self.hidden] forKey:@"visible"]; // TODO: way to specific NOT of value in JSON?
    [dict setObject:[NSNumber numberWithBool:self.hidden] forKey:@"hidden"];
    [ dict setObject:[ ExportUtility exportUIViewAutoresizing:self.autoresizingMask ] forKey:@"autoresizingMask" ]; // TODO: store or translate mask values
    [ dict setObject:[ NSNumber numberWithBool:self.clipsToBounds ] forKey:@"clipsToBounds" ];
    [ dict setObject:[ExportUtility exportUIViewContentMode:self.contentMode] forKey:@"contentMode" ];
    
    NSMutableArray *children = [NSMutableArray array];
    
    //subviews
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIView* subview = [ self.subviews objectAtIndex:i ];
        CXMLElement* xibSubview = nil;

        CXMLElement* xibSubviewAtIndex = [xibElement subviewAtIndex:i];
        if ( [ [subview class] isSubclassOfClass:[xibSubviewAtIndex classType] ] )
        {
            xibSubview = xibSubviewAtIndex;
        } else
        {
            NSLog(@"Unable to match %@ with xml data, found %@ instead", [subview class], [xibSubviewAtIndex classType] );
        }
        
        [ children addObject:[ subview exportToDictionary:xibSubview ] ];
    }
    
    [dict setObject:children forKey:@"subviews"];
    
    return dict;
}

- (NSMutableDictionary *)exportToDictionary:( CXMLElement* )xibElement
{
    NSMutableDictionary* dict = nil;
    
    //if our accessibility label is _FLATTENED, then use our first child instead
    if ( [ self isMarkedForFlattening:self.accessibilityLabel ] && [ self.subviews count ] > 0)
    {
        dict = [ self exportToDictionaryFlattened:xibElement ];
    }
    else
    {
        dict = [ self exportToDictionaryUIView:xibElement ];
    }
    
    [ dict setObject:@"TODO: rootView instance" forKey:@"rootView" ];
    
    return dict;
}

#pragma mark Comments

#define CommentsKey @"_comments"

+( void )addToComments:( NSString* )string members:( NSMutableDictionary* )members
{
    NSMutableString* comments = [ members objectForKey:CommentsKey ];
    if ( !comments )
    {
        comments = [ NSMutableString string ];
    }
    [ comments appendFormat:@"\t// %@\n", string ];
    [ members setObject:comments forKey:CommentsKey ];    
}

+( NSString* )getComments:( NSDictionary* )members
{
    return [ members objectForKey:CommentsKey ];
}

-( NSString* )getKeyForSelf
{
    return [ UIView getKeyForView:self ];
}

+( NSString* )getKeyForView:( UIView* )view
{
    return [ NSString stringWithFormat:@"%p", view ];
}

+( void )addToMemberDictionary:( NSString* )member value:( NSObject* )value inView:( UIView* )view dictionary:( NSMutableDictionary* )dictionary
{
    if ( dictionary == nil )
    {
        NSLog( @"Could not added member %@ of %p with value %@ to custom member dictionary, custom member dictionary is nil", member, view, value );
        return;
    }
    NSMutableDictionary* memberDictionary = [ dictionary objectForKey:member ];
    if ( memberDictionary == nil )
    {
        memberDictionary = [ [ NSMutableDictionary alloc ] init ];
        [ dictionary setObject:memberDictionary forKey:member ];
    }
    [ memberDictionary setObject:value forKey:[ UIButton getKeyForView:view ] ];
}

+( NSObject* )getMemberValue:( NSString* )member inView:( UIView* )view dictionary:( NSMutableDictionary* )dictionary
{
    if ( dictionary == nil )
    {
        NSLog( @"Could not get member value %@ of %p to custom member dictionary, custom member dictionary is nil", member, view );
        return nil;
    }
    NSMutableDictionary* memberDictionary = [ dictionary objectForKey:member ];
    if ( memberDictionary == nil )
    {
        memberDictionary = [ [ NSMutableDictionary alloc ] init ];
        [ dictionary setObject:memberDictionary forKey:member ];
    }
    return ( NSString* )[ memberDictionary objectForKey:[ UIButton getKeyForView:view ] ];
}

-( void )addCustomMember:( NSString* )member value:( NSObject* )value
{
    [ UIView addToMemberDictionary:member value:value inView:self dictionary:_uiViewCustomMemberDictionary ];
}

-( NSObject* )getCustomMemberValue:( NSString* )member
{
    return [ UIView getMemberValue:member inView:self dictionary:_uiViewCustomMemberDictionary ];
}

-( void )setValue:( id )value forUndefinedKey:( NSString* )key
{
    NSLog(
          @"Unable to set value %@ for member %@ on object %p of type %@, member does not exist",
          value,
          key,
          self,
          [ self class ]
          );
}

CustomMemberSynthesize( Outlet, NSString* );

@end
