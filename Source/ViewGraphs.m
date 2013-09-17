//
//  ViewGraphs.m
//  XibExporter
//
//  Created by Ian on 9/13/13.
//
//

#import "ViewGraphs.h"

#import "ViewGraphData.h"

@interface ViewGraphs()

@property (nonatomic, strong) NSMutableDictionary *datas;

@end

@implementation ViewGraphs

-(id)init
{
    self = [super init];
    if (self)
    {
        self.datas = [ [NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)processXib:(NSString*)xibName
{
    ViewGraphData* data = [ [ViewGraphData alloc] initWithXib:xibName];
    
    [self.datas setObject:data forKey:xibName];
}

-(NSArray*)xibNames
{
    return [self.datas allKeys];
}

-(ViewGraphData*)dataForXib:(NSString*)xibName
{
    return [self.datas objectForKey:xibName];
}

@end
