//
//  AppSettings.m
//  XibExporter
//
//  Created by Ian on 9/17/13.
//
//

#import "AppSettings.h"

#import "NSDictionary+TypeForKey.h"

@implementation AppSettings

+(NSString*)getOSXApplicationSupportPath
{
    // total hacktastic and could break when Apple moves this folder
    NSError* error = nil;
    
    NSURL* directory = [ [NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                               inDomain:NSUserDomainMask
                                                      appropriateForURL:nil
                                                                 create:YES
                                                                  error:&error];
    directory = [directory URLByDeletingLastPathComponent];
    while ( ![ [directory lastPathComponent] isEqualToString:@"Application Support" ] && [ [directory path] length] > [@"Application Support" length] )
    {
        directory = [directory URLByDeletingLastPathComponent];
    }
    
    return [directory path];
}

+(NSString*)getFolderContainingNibsToProcess
{
    return [ [NSBundle mainBundle] bundlePath];
}

+(NSDictionary*)getSettingsDictionary
{
    return [ [NSBundle mainBundle] infoDictionary];
}

+(NSDictionary*)getExportSettingsDictionary
{
    return [ [self getSettingsDictionary] dictionaryForKey:@"Export Settings"];
}

+ (NSString *) getFolderForExports
{
    return [ [self getExportSettingsDictionary] stringForKey:@"Folder for Exports"];
}

+ (NSString *)getPathToAddExportsToProjectFile
{
    // TODO: check if we were given an xcproj or what
    return [ [ [self getAddExportsToProjectFile] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
}

+ (NSString *) getAddExportsToProjectFile
{
    // TODO: check if we were given an xcproj or what
    return [ [self getExportSettingsDictionary] stringForKey:@"Add Exports To Project" ];
}

+ (NSString *) getFolderContainingXibsToProcess
{
    return [ [self getExportSettingsDictionary] stringForKey:@"Process Xibs in Folder" ];
}

+ (NSArray *) getSkipXibs
{
    return [ [self getExportSettingsDictionary] arrayForKey:@"Skip Xibs" ];
}

+ (NSArray *) getProcessOnlyXibs
{
    return [ [self getExportSettingsDictionary] arrayForKey:@"Process Only Xibs"];
}

+(BOOL)ForceProcessUnchangedXibs
{
    return [ [self getExportSettingsDictionary] boolForKey:@"Force Process Unchanged Xibs" withDefaultValue:NO];
}

+(BOOL)addExportsToProject
{
    return [ [self getExportSettingsDictionary] boolForKey:@"Add Exports to Project" withDefaultValue:NO];
}

+(NSArray*)getRegisterExporterClasses
{
    return [ [self getSettingsDictionary] arrayForKey:@"Register Exporter Classes"];
}

+(NSDictionary*)getExports
{
    return [ [self getExportSettingsDictionary] dictionaryForKey:@"Enabled Exports"];
}

+(NSArray*)getEnabledExports
{
    NSMutableArray* enabledExports = [ [NSMutableArray alloc] init];
    
    NSDictionary* exports = [self getExports];
    
    for (NSString* key in [exports allKeys] )
    {
        if ( [ [exports objectForKey:key] boolValue] == YES)
        {
            [enabledExports addObject:key];
        }
    }
    
    return enabledExports;
}

@end
