//
//  AppSettings.m
//  XibExporter
//
//  Created by Ian on 9/17/13.
//
//

#import "AppSettings.h"

@implementation AppSettings

+(NSObject*)objectForInfoDictionaryKey:(NSString*)key
{
    return [ [NSBundle mainBundle] objectForInfoDictionaryKey:key];
}

+(NSString*)stringForInfoDictionaryKey:(NSString*)key
{
    NSString* result = nil;
    
    id object = [self objectForInfoDictionaryKey:key];
    if ( [object isKindOfClass:[NSString class] ] )
    {
        result = (NSString*)object;
    }
    
    return result;
}

+(NSArray*)arrayForInfoDictionaryKey:(NSString*)key
{
    NSArray* result = nil;
    
    id object = [self objectForInfoDictionaryKey:key];
    if ( [object isKindOfClass:[NSArray class] ] )
    {
        result = (NSArray*)object;
    }
    
    return result;
}

+(BOOL)boolForInfoDictionaryKey:(NSString*)key withDefaultValue:(BOOL)defaultValue
{
    BOOL result = defaultValue;
    
    id object = [self objectForInfoDictionaryKey:key];
    if ( [object respondsToSelector:@selector(boolValue) ] )
    {
        result = [object boolValue];
    }
    
    return result;
}

+(NSString*)getXcodeProjectFolder
{
    return [self stringForInfoDictionaryKey:@"XcodeProjectFolder"];
}

+(NSString*)getGeneratedSourceRelativeFolder
{
    return [self stringForInfoDictionaryKey:@"GeneratedSourceRelativeFolder"];
}

+(NSString*)getXcodeProjectRelativeFile
{
    return [self stringForInfoDictionaryKey:@"XcodeProjectRelativeFile"];
}

+(NSString*)getXIBRootRelativeFolder
{
    return [self stringForInfoDictionaryKey:@"XIBRootRelativeFolder"];
}

+ (NSString *) getGeneratedSourceFolder
{
    return [NSString stringWithFormat:@"%@/%@",
            [self getXcodeProjectFolder],
            [self getGeneratedSourceRelativeFolder]
            ];
}

+ (NSString *) getXcodeProjectFile
{
    return [NSString stringWithFormat:@"%@/%@",
            [self getXcodeProjectFolder],
            [self getXcodeProjectRelativeFile]
            ];
}

+ (NSString *) getXIBRoot
{
    return [NSString stringWithFormat:@"%@/%@",
            [self getXcodeProjectFolder],
            [self getXIBRootRelativeFolder]
            ];
}

+ (NSArray *) getSkipXibs
{
    return [self arrayForInfoDictionaryKey:@"SkipXibs" ];
}

+ (NSArray *) getProcessOnlyXibs
{
    return [self arrayForInfoDictionaryKey:@"ProcessOnlyXibs" ];
}

+ (BOOL) forceExportAllXibs
{
    return [self boolForInfoDictionaryKey:@"ForceExportAllXibs" withDefaultValue:NO];
}


+ (BOOL)addExportsToProject
{
    return [self boolForInfoDictionaryKey:@"Add Exports to Project" withDefaultValue:NO];
}

@end
