//
//  UIView+XibExporter.m
//  XibExporterExample
//
//  Created by Ian on 10/11/13.
//
//

#import "UIView+XibExporter.h"

@implementation UIView (XibExporter)

-( void )setValue:( id )value forUndefinedKey:( NSString* )key
{
    NSLog(
          @"Ignoring set value %@ for member %@ on object %p of type %@",
          value,
          key,
          self,
          [ self class ]
          );
}

@end
