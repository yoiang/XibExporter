//
//  CodeMap.m
//  XibExporter
//
//  Created by Ian on 9/17/13.
//
//

#import "CodeMap.h"

#import "SBJson.h"

@interface CodeMap()

@property (nonatomic, strong) NSDictionary* data;

@end

@implementation CodeMap

-(id)initWithJSONFileName:(NSString*)jsonFileName
{
    self = [super init];
    if (self)
    {
        NSError *error = nil;
        
        NSString *defFile = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"] encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"CodeMap was unable to load file %@", jsonFileName);
            self.data = nil;
        }
        else
        {
            self.data = [defFile JSONValue];
            [self copySuperProperties];
        }
    }
    return self;
}

// TODO: we should instead reference our super's dictionary
-(void)copySuperProperties
{
    //populate subclasses with the data from their superclasses
    for (NSString* className in self.definedClasses )
    {
        NSMutableDictionary *classDef = [self definitionForClass:className];
        while ( [classDef objectForKey:@"_super"] )
        {
            NSDictionary *superDef = [self definitionForClass:[classDef objectForKey:@"_super"] ];
            [classDef removeObjectForKey:@"_super"];
            if (superDef)
            {
                for (NSString* superMemberName in [superDef allKeys] )
                {
                    if ( ![classDef objectForKey:superMemberName] && [superDef objectForKey:superMemberName] )
                    {
                        [classDef setObject:[superDef objectForKey:superMemberName] forKey:superMemberName];
                    }
                }
            }
        }
    }
}

-(NSMutableDictionary*)definitionsForClasses
{
    return [self.data objectForKey:@"Class Definitions"];
}

-(NSArray*)definedClasses
{
    return [self.definitionsForClasses allKeys];
}

-(NSMutableDictionary*)definitionForClass:(NSString*)className
{
    return [self.definitionsForClasses objectForKey:className];
}

-(NSMutableDictionary*)definitionsForEnums
{
    return [self.data objectForKey:@"Enum Definitions"];
}

-(NSArray*)definedEnums
{
    return [self.definitionsForEnums allKeys];
}

-(NSMutableDictionary*)definitionForEnum:(NSString *)enumName
{
    return [self.definitionsForEnums objectForKey:enumName];
}

-(NSString*)convertEnum:(NSString*)enumName value:(NSString*)value
{
    // TODO: add debugging logs
    return [ [ [self definitionForEnum:enumName] objectForKey:@"_enum"] objectForKey:value ];
}

-(NSDictionary*)functionDefinitions
{
    return [self.data objectForKey:@"_functionDefinitions"];
}

-(NSArray*)definedFunctions
{
    return [self.functionDefinitions allKeys];
}

-(NSString*)functionDefinition:(NSString*)function
{
    return [self.functionDefinitions objectForKey:function];
}

-(NSString*)rootViewInstanceName
{
    return [self.data objectForKey:@"_rootViewInstanceName"];
}

-(NSDictionary*)ignoredClasses
{
    return [self.data objectForKey:@"_ignoredClasses"];
}

-(NSDictionary*)asIsStringKeys
{
    return [self.data objectForKey:@"_asIsStringKeys"];
}

-(NSArray*)codeExporterFileNames
{
    return [self.data objectForKey:@"_codeExporterFileNames"];
}

-(NSString*)statementEnd
{
    return [self.data objectForKey:@"_statementEnd"];
}

@end
