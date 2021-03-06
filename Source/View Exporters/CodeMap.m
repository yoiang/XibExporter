//
//  CodeMap.m
//  XibExporter
//
//  Created by Ian on 9/17/13.
//
//

#import "CodeMap.h"

#import "SBJson.h"

#import "NSMutableDictionary+ClassDefinition.h"
#import "NSMutableDictionary+InstanceDefinition.h"

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
    for (NSString* className in self.definedClasses)
    {
        NSMutableDictionary *classDef = [self definitionForClass:className];
        while ( [classDef superClassName] )
        {
            [classDef replaceSuperClassWithProperties:[self definitionForClass:[classDef superClassName] ] ];
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

-(NSMutableDictionary*)definitionForClassOfInstance:(NSDictionary*)instanceDefinition
{
    return [self definitionForClass:instanceDefinition.className];
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

-(NSString*)functionDefinitionFileName
{
    return [self.data objectForKey:@"_functionDefinitionFileName"];
}

// TODO: add order definition to JSON to ensure correct order each time
-(NSString*)combinedFunctionDefinitions
{
    NSMutableString* functionDefinitions = [NSMutableString string];
    
    if ([ [self functionDefinitionFileName] length] > 0)
    {
        NSString* filePath = [ [NSBundle mainBundle] pathForResource:[self functionDefinitionFileName] ofType:@""];
        if ( [filePath length] == 0)
        {
            NSLog(@"Unabled to find specified Function Definition File %@", [self functionDefinitionFileName] );
        } else
        {
            NSError* error;
            
            [functionDefinitions appendString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error ]
             ];
        }
    }
    if ( [functionDefinitions length] == 0 && [self.definedFunctions count] > 0)
    {
        for (NSString* functionName in self.definedFunctions)
        {
            [functionDefinitions appendFormat:@"\n\n%@",[self functionDefinition:functionName] ];
        }
    }
    
    return functionDefinitions;
}

-(NSDictionary*)ignoredClasses
{
    return [self.data objectForKey:@"_ignoredClasses"];
}

-(NSDictionary*)asIsStringKeys
{
    return [self.data objectForKey:@"_asIsStringKeys"];
}

-(NSString*)variableReference:(NSString*)name;
{
    NSString* variableReference = [self.data objectForKey:@"_variableReference"];
    if ( [variableReference length] == 0)
    {
        variableReference = @"$instanceName$";
    }
    return [variableReference stringByReplacingOccurrencesOfString:@"$instanceName$" withString:name];
}

-(NSString*)localVariableReference:(NSString*)name;
{
    NSString* localVariableReference = [self.data objectForKey:@"_localVariableReference"];
    if ( [localVariableReference length] == 0)
    {
        localVariableReference = @"$instanceName$";
    }
    return [localVariableReference stringByReplacingOccurrencesOfString:@"$instanceName$" withString:name];
}

-(NSString*)variableReferenceForInstanceDefinitionUsage:(NSDictionary*)instanceDefinition
{
    NSString* result = nil;
    if ( [instanceDefinition isOutlet] )
    {
        result = [self variableReference:[instanceDefinition instanceName] ];
    } else
    {
        result = [self localVariableReference:[instanceDefinition instanceName] ];
    }
    
    return result;
}

-(NSString*)staticStringDefinition:(NSString*)contents
{
    NSString* staticStringDefinition = [self.data objectForKey:@"_staticStringDefinition"];
    if ( [staticStringDefinition length] == 0)
    {
        staticStringDefinition = @"\"$\"";
    }
    return [staticStringDefinition stringByReplacingOccurrencesOfString:@"$" withString:contents];
}

-(NSString*)statementEnd
{
    return [self.data objectForKey:@"_statementEnd"];
}

@end
