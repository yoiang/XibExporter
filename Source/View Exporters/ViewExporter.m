//
//  ofxGenericViewExporter.h
//  XibExporter
//
//  Created by Ian on 9/17/13.
//
//

#import "ViewExporter.h"

NSMutableDictionary* exporters = nil;

@implementation ViewExporterFactory

+(void)registerExporter:(id<ViewExporter>)viewExporter
{
    if (exporters == nil)
    {
        exporters = [ [NSMutableDictionary alloc] init];
    }
    
    [exporters setObject:viewExporter forKey:[viewExporter factoryKey] ];
}

+(id<ViewExporter>)exporterForKey:(NSString*)exporterKey
{
    return [exporters objectForKey:exporterKey];
}

@end