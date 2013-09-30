//
//  NSDictionary+Path.m
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import "NSDictionary+Path.h"

@implementation NSDictionary (Path)

-(id)objectAtPath:(NSString*)path withPathSeparator:(NSString*)pathSeparator
{
    id result = self;
    
    NSArray *pathComponents = [path componentsSeparatedByString:pathSeparator];
    
    for (NSString* pathComponent in pathComponents)
    {
        if ( [result isKindOfClass:[NSDictionary class] ] )
        {
            result = [ ( (NSDictionary*)result) objectForKey:pathComponent];
        }
    }
    
    return result;
}

@end
