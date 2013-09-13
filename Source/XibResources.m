//
//  XibResources.m
//  XibExporter
//
//  Created by Ian on 9/13/13.
//
//

#import "XibResources.h"

#import "CXMLElement+Xib.h"

@interface XibResources()

@property (nonatomic, strong) NSMutableDictionary *xibResources;

@end

@implementation XibResources

-(id)init
{
    self = [super init];
    
    if (self)
    {
        self.xibResources = [ [NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)clearXibResources
{
    [self.xibResources removeAllObjects];
}

-( void )addXibResource:( CXMLElement* )element
{
    if ( [ element attributeIdStringValue ] )
    {
        [ self.xibResources setObject:element forKey:[ element attributeIdStringValue ] ];
    }
}

-( CXMLElement* )getXibResource:( NSString* )referenceId
{
    return [ self.xibResources objectForKey:referenceId ];
}

@end
