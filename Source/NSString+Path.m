//
//  NSString+Path.m
//  XibExporter
//
//  Created by Ian on 10/10/13.
//
//

#import "NSString+Path.h"

@implementation NSString (Path)

// based on http://stackoverflow.com/a/6542181/96153
+(NSString*)stringWithPath:(NSString*)path relativeTo:(NSString*)anchorPath;
{
    BOOL isDirectionory = NO;
    if ( ![ [NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectionory] )
    {
        NSLog(@"Unable to complete [NSString stringWithPath:%@ relativeTo:%@, path does not exist", path, anchorPath);
        return nil;
    }
    if (!isDirectionory)
    {
        path = [path stringByDeletingLastPathComponent];
    }
    NSArray *pathComponents = [path pathComponents];
    
    if ( ![ [NSFileManager defaultManager] fileExistsAtPath:anchorPath isDirectory:&isDirectionory] )
    {
        NSLog(@"Unable to complete [NSString stringWithPath:%@ relativeTo:%@, relativeTo does not exist", path, anchorPath);
        return nil;
    }
    if (!isDirectionory)
    {
        anchorPath = [anchorPath stringByDeletingLastPathComponent];
    }
    NSArray *anchorComponents = [anchorPath pathComponents];
    
    NSInteger componentsInCommon = MIN( [pathComponents count], [anchorComponents count] );
    for (NSInteger i = 0, n = componentsInCommon; i < n; i++)
    {
        if ( ![ [pathComponents objectAtIndex:i] isEqualToString:[anchorComponents objectAtIndex:i] ] )
        {
            componentsInCommon = i;
            break;
        }
    }
    
    NSUInteger numberOfParentComponents = [anchorComponents count] - componentsInCommon;
    NSUInteger numberOfPathComponents = [pathComponents count] - componentsInCommon;
    
    NSMutableArray *relativeComponents = [NSMutableArray arrayWithCapacity:
                                          numberOfParentComponents + numberOfPathComponents];
    for (NSInteger i = 0; i < numberOfParentComponents; i++)
    {
        [relativeComponents addObject:@".."];
    }
    [relativeComponents addObjectsFromArray:[pathComponents subarrayWithRange:NSMakeRange(componentsInCommon, numberOfPathComponents) ] ];
    return [NSString pathWithComponents:relativeComponents];
}

@end
