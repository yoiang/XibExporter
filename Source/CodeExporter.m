//
//  CodeExporter.m
//  XibExporter
//
//  Called by the ViewExporter class to generate code for new xibs.
//  An XIB where the root view's accessibilityHint is __AUTOGENERATE
//  will create however many files are specified in the CodeDefinitions.
//
//  Created by Eli Delventhal on 7/10/12.
//

#import "CodeExporter.h"
#import "ViewExporter.h"
#import "NSString+Parsing.h"

static CodeExporter *sharedCodeExporter;

@implementation CodeExporter

#pragma mark Private

- (NSString *) parseDollarSandwich:(NSString *)inputString dict:(NSDictionary *)dict
{
    //hack
    if ( [inputString isEqualToString:@"instanceName"] )
    {
        return [dict objectForKey:inputString];
    }
    return [[ViewExporter sharedInstance] getStringRepresentation:[dict objectForKey:inputString] key:inputString outlets:nil includes:nil properties:nil];
}

- (NSString *) parseModulusSandwich:(NSString *)inputString def:(NSDictionary *)def
{
    return [def objectForKey:inputString];
}

- (NSString *) parseCopyrightSandwich:(NSString *)condition properties:(NSDictionary *)properties
{
    NSArray *conditionParts = [condition componentsSeparatedByString:@"≠"];
    
    //condition is true, so put the result in
    if ( [conditionParts count] >= 2 && [properties objectForKey:[conditionParts objectAtIndex:0]] )
    {
        return [conditionParts objectAtIndex:1];
    }
    
    return @"";
}

- (NSString *) parseLooperSandwich:(NSString *)loop compoundData:(NSDictionary *)data
{
    NSDictionary *properties = [data objectForKey:@"properties"];
    NSDictionary *def = [data objectForKey:@"def"];
    
    NSMutableString *output = [NSMutableString string];
    
    NSArray *loopParts = [loop componentsSeparatedByString:@"∂"];
    if ( [loopParts count] >= 2 )
    {
        NSString *delimiter = [loopParts count] >= 3 ? [loopParts objectAtIndex:2] : @"\n";
        id collection = [properties objectForKey:[loopParts objectAtIndex:0]];
        
        if ( collection && [collection isKindOfClass:[NSArray class]] )
        {
            for ( int i = 0; i < [collection count]; i++ )
            {
                id obj = [collection objectAtIndex:i];
                
                if ( [obj isKindOfClass:[NSDictionary class]] )
                {
                    NSDictionary *subDef = [def objectForKey:[obj objectForKey:@"class"]];
                    
                    NSString *result = [self translateSingleObjectCodeString:[loopParts objectAtIndex:1] dict:obj withDef:subDef properties:properties];
                    [output appendFormat:@"%@%@",result,delimiter];
                }
                else
                {
                    [output appendFormat:@"%@%@",obj,delimiter];
                }
                
            }
        }
    }
    
    return output;
}

#pragma mark Public

+ (CodeExporter *) sharedInstance
{
    if ( !sharedCodeExporter )
    {
        sharedCodeExporter = [[CodeExporter alloc] init];
    }
    return sharedCodeExporter;
}

- ( NSArray * ) exportCodeForDict:(NSDictionary *)dict def:(NSDictionary *)def properties:(NSDictionary *)properties
{
    NSArray *files = [def objectForKey:@"_codeExporterFileNames"];
    NSMutableArray *outputArray = [NSMutableArray array];
    
    for ( int i = 0; i < [files count]; i++ )
    {
        NSString *fileName = [[files objectAtIndex:i] objectForKey:@"inputFile"];
        NSString *fileExtension = [fileName pathExtension];
        fileName = [fileName stringByDeletingPathExtension];
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];
        NSError *error = nil;
                          
        NSString *classFile = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        if ( error )
        {
            NSLog( @"Error reading code exporter file %@: %@",[files objectAtIndex:i],error);
        }
        
        NSString *output = [self translateCodeString:classFile dict:dict withDef:def properties:properties];
        [outputArray addObject:output];
    }
    
    return outputArray;
}

//translates the entire code string, dict and def are global dictionaries
- ( NSString * ) translateCodeString:(NSString *)classFile dict:(NSDictionary *)dict withDef:(NSDictionary *)def properties:(NSDictionary *)properties
{
    if (!classFile)
    {
        classFile = @"";
    }
    
    //%classname% is a reserved phrase and is replaced with the className
    NSString *output = [classFile stringByReplacingOccurrencesOfString:@"%classname%" withString:[properties objectForKey:@"className"]];
    
    //find any conditions that exist and strip them out if they are not true
    output = [output stringByParsingSandwiches:@"©" parseObject:self parseSelector:@selector(parseCopyrightSandwich:properties:) userData:properties];
    
    //expand loops that we have
    NSDictionary *compoundData = [NSDictionary dictionaryWithObjectsAndKeys:dict, @"dict", def, @"def", properties, @"properties", nil];
    output = [output stringByParsingSandwiches:@"¬" parseObject:self parseSelector:@selector(parseLooperSandwich:compoundData:) userData:compoundData];
    
    return output;
}

//translates a single object only, dict and def are drilled down to this individual object
- ( NSString * ) translateSingleObjectCodeString:(NSString *)codeString dict:(NSDictionary *)dict withDef:(NSDictionary *)def properties:(NSDictionary *)properties
{
    NSString *output = [NSString stringWithString:codeString];
    
    output = [output stringByParsingSandwiches:@"$" parseObject:self parseSelector:@selector(parseDollarSandwich:dict:) userData:dict];
    output = [output stringByParsingSandwiches:@"%" parseObject:self parseSelector:@selector(parseModulusSandwich:def:) userData:def];
    
    return output;
}
     
@end