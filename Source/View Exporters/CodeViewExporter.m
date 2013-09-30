//
//  CodeViewExporter.m
//  XibExporter
//
//  Created by Ian on 9/24/13.
//
//

#import "CodeViewExporter.h"

#import "CodeMap.h"

#import "AppSettings.h"

#import "XcodeProjectHelper.h"

#import "ViewGraphData.h"

#import "UIView+Exports.h"

#import "NSArray+NSString.h"

#import "NSString+Parsing.h"

static NSMutableDictionary* instanceCounts = nil;

@interface CodeViewExporter()

@property (nonatomic, strong) CodeMap* map;

@end

@implementation CodeViewExporter

-(NSString*)factoryKey
{
    NSException* exception = [ [NSException alloc] initWithName:@"Abstract Method" reason:@"Must override [CodeViewExporter factoryKey] method" userInfo:nil];
    @throw exception;

    return @"invalid";
}

-(NSString*)codeMapJSONDefinitionFileName
{
    NSException* exception = [ [NSException alloc] initWithName:@"Abstract Method" reason:@"Must override [CodeViewExporter codeMapJSONDefinitionFileName] method" userInfo:nil];
    @throw exception;
    
    return @"invalid";
}

// TODO: allow subclasses to alter path
-(NSString*)multipleExportedFileNameFormat
{
    NSException* exception = [ [NSException alloc] initWithName:@"Abstract Method" reason:@"Must override [CodeViewExporter multipleExportedFileNameFormat] method" userInfo:nil];
    @throw exception;
    
    return @"invalid";
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.map = [ [CodeMap alloc] initWithJSONFileName:[self codeMapJSONDefinitionFileName] ];
    }
    return self;
}

- (NSString *)exportData:(ViewGraphData*)viewGraphData atomically:(BOOL)flag error:(NSError**)error
{
    return [self exportData:viewGraphData toPath:[AppSettings getFolderForExports] atomically:flag error:error];
}

-(NSString*)exportData:(ViewGraphData*)viewGraphData toPath:(NSString*)targetPath atomically:(BOOL)flag error:(NSError **)error
{
    NSString* exportedFileName = nil;
    
    NSString* xibName = [viewGraphData xibName];
    
    if ( !instanceCounts )
    {
        instanceCounts = [ [ NSMutableDictionary alloc ] init ];
    } else
    {
        [ instanceCounts removeAllObjects ];
    }
    
    NSMutableDictionary* outlets = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSMutableArray array], @"stripped",
                                    [NSMutableArray array], @"unstripped", nil];
    NSMutableArray* includes = [NSMutableArray array];
    NSMutableDictionary* properties = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSMutableArray array], @"outlets",
                                       xibName, @"className", nil];
    
    NSDictionary* output = [self getCodeFor:viewGraphData isInline:NO outlets:outlets includes:includes properties:properties];
    
    NSString* exportFileNameFormat = [self multipleExportedFileNameFormat];
    
    NSString* baseFileName = [NSString stringWithFormat:@"Generated%@", xibName];
    exportedFileName = [NSString stringWithFormat:exportFileNameFormat, baseFileName];
    
    NSString* fileNamePath = [NSString stringWithFormat:@"%@/%@", targetPath, exportedFileName];
    
    [self doCodeExport:viewGraphData toFileNamePath:fileNamePath data:output xibName:xibName atomically:flag error:error];
    
    return exportedFileName;
}

-(NSString*)getStringRepresentationForDictionaryValue:(NSDictionary*)value key:(NSString*)key outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    if ( [ExportUtility isDictionaryEnum:(NSDictionary*)value] )
    {
        return [self valueForEnum:key valueObject:value];
    } else
    {
        return [ [self getCodeFor:value isInline:YES outlets:outlets includes:includes properties:properties] objectForKey:@"code"];
    }
}

-(NSString*)getStringRepresentationForArrayValue:(NSArray*)value key:( NSString* )key outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    NSMutableString* result = nil;
    
    for (id individualValue in value)
    {
        NSString* parsedStringValue = [self getStringRepresentation:individualValue key:key outlets:outlets includes:includes properties:properties];
        
        // For now only used for masks
        if (!result)
        {
            result = [NSMutableString stringWithString:parsedStringValue];
        } else
        {
            [result appendFormat:@" | %@", parsedStringValue];
        }
    }
    return result;
}

-(NSString*)getStringRepresentationForStringValue:(NSString*)value key:(NSString*)key
{
    NSString* result = nil;
    
    NSString* buildFormat = nil;
    if (!self.map.asIsStringKeys || [self.map.asIsStringKeys objectForKey:key])
    {
        buildFormat = @"%@";
    } else
    {
        buildFormat = [self.map staticStringDefinition:@"%@"];
    }
    result = [ [NSString stringWithFormat:buildFormat, value] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    result = [result stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    
    return result;
}

-(NSString*)getStringRespresentationForNumberValue:(NSNumber*)value
{
    NSString* result = nil;
    
    if (strcmp([value objCType], @encode(float)) == 0)
    {
        if ([value floatValue] - [value intValue] == 0)
        {
            result = [NSString stringWithFormat:@"%@.0f",[value stringValue]];
        }
        else
        {
            result = [NSString stringWithFormat:@"%@f",[value stringValue]];
        }
    }
    else if (strcmp([value objCType], @encode(BOOL)) == 0)
    {
        if ( [value boolValue] )
        {
            result = @"true";
        }
        else
        {
            result = @"false";
        }
    }
    else
    {
        result = [value stringValue];
    }
    return result;
}

- (NSString *) getStringRepresentation:(id)v key:( NSString* )key outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    NSString *result = nil;
    
    if ([v isKindOfClass:[NSDictionary class]] && outlets && includes && properties )
    {
        result = [self getStringRepresentationForDictionaryValue:v key:key outlets:outlets includes:includes properties:properties];
    } else if ( [v isKindOfClass:[NSArray class] ] )
    {
        result = [self getStringRepresentationForArrayValue:v key:key outlets:outlets includes:includes properties:properties];
    } else if ([v isKindOfClass:[NSString class]])
    {
        result = [self getStringRepresentationForStringValue:v key:key];
    }
    else if ([v isKindOfClass:[NSNumber class]])
    {
        result = [self getStringRespresentationForNumberValue:v];
    }
    
    if (!result)
    {
        result = @"0";
    }
    
    return result;
}

-(NSString*)valueForEnum:(NSString*)valueKey valueObject:(NSObject*)valueObject
{
    NSString* enumValueKey;
    NSRange prefix = [valueKey rangeOfString:@"." options:NSLiteralSearch];
    if (prefix.length == 0)
    {
        enumValueKey = valueKey;
    } else
    {
        enumValueKey = [valueKey substringFromIndex:prefix.location + prefix.length];
    }
    
    NSString* result = nil;
    if ( [valueObject isKindOfClass:[NSDictionary class] ] )
    {
        NSDictionary* valueDict = (NSDictionary*)valueObject;
        result = [self.map convertEnum:[valueDict objectForKey:@"class"] value:[valueDict objectForKey:enumValueKey] ];
    }
    
    return result;
}

-(NSString*)codeForClassConstructor:(NSString*)class instanceName:(NSString*)instanceName outlets:(NSMutableDictionary*)outlets includes:(NSMutableArray*)includes dict:(NSDictionary*)dict def:(NSDictionary*)def properties:(NSMutableDictionary*)properties isInline:(BOOL)isInline isOutlet:(BOOL)isOutlet
{
    NSMutableString* constructor = nil;
    
    //if this is an inline call, simply return the inline constructor
    if (isInline)
    {
        NSString* constructorDef = [def objectForKey:@"_inlineConstructor"];
        NSString* inl = [self replaceCodeSymbols:constructorDef dict:dict key:@"_inlineConstructor" name:instanceName outlets:outlets includes:includes def:def properties:properties];
        constructor = [NSMutableString stringWithString:[inl substringFromIndex:1] ]; //remove the leading tab for an inline
    } else
    {
        
        NSString* constructorDef = [def objectForKey:@"_constructor"];
        if (constructorDef)
        {
            if (isOutlet)
            {
                constructorDef = [self replaceCodeSymbols:[def objectForKey:@"_inlineConstructor"] dict:dict key:@"_inlineConstructor" name:instanceName outlets:outlets includes:includes def:def properties:properties];
                constructorDef = [NSString stringWithFormat:@"\t%@ = %@",[self.map variableReference:instanceName],[constructorDef substringFromIndex:1]];
            }
            else
            {
                constructorDef = [self replaceCodeSymbols:constructorDef dict:dict key:@"_constructor" name:instanceName outlets:outlets includes:includes def:def properties:properties];
            }
            
            constructor = [NSMutableString stringWithString:@"\n"];
            
            NSString* comments = [ UIView getComments:dict ];
            if ( comments )
            {
                [constructor appendString:comments ];
            }
            
            //only put the constructor in if this is not the root view, because the root view should be handled by surrounding code
            if ([dict objectForKey:@"superview"])
            {
                [constructor appendString:[NSString stringWithFormat:@"%@%@\n", constructorDef,[self.map statementEnd] ] ];
            }
        }
        else
        {
            NSLog(@"Warning: No _constructor found for %@!",class);
        }

    }

    return constructor;
}

-(NSString*)codeForObjectSetup:(NSString*)class instanceName:(NSString*)instanceName outlets:(NSMutableDictionary*)outlets includes:(NSMutableArray*)includes dict:(NSDictionary*)dict def:(NSDictionary*)def properties:(NSMutableDictionary*)properties
{
    NSMutableString* objectSetup = [NSMutableString string];
    
    //loop through all keys in the def, and add that code in
    NSArray *keys = [def allKeys];
    for (int i = 0; i < [keys count]; i++)
    {
        NSString *k = [keys objectAtIndex:i];
        if ([k length] > 0 && [k characterAtIndex:0] != '_' && [dict objectForKey:k])
        {
            NSString *line = [def objectForKey:k];
            NSString* lineFilledIn = [self replaceCodeSymbols:line dict:dict key:k name:instanceName outlets:outlets includes:includes def:def properties:properties];
            if ( lineFilledIn && [ lineFilledIn length ] > 0 )
            {
                [objectSetup appendFormat:@"%@%@\n", lineFilledIn, [self.map statementEnd] ];
            }
        }
    }
    
    return objectSetup;
}

-(NSString*)codeForAddSubview:(NSDictionary*)subview instanceName:(NSString*)instanceName def:(NSDictionary*)def
{
    NSString *addsub = [def objectForKey:@"_addSubview"];
    addsub = [addsub stringByReplacingOccurrencesOfString:@"@" withString:[self.map variableReference:instanceName] ];
    addsub = [addsub stringByReplacingOccurrencesOfString:@"%" withString:[self.map variableReference:[subview objectForKey:@"name"] ] ];
    return addsub;
}

- (NSString *) replaceCodeSymbols:(NSString *)line dict:(NSDictionary *)dict key:(NSString *)key name:(NSString *)name outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes def:(NSDictionary *)def properties:(NSMutableDictionary *)properties
{
    if (!line)
    {
        line = @"";
    }
    
    NSString* output = [line stringByReplacingOccurrencesOfString:@"@" withString:[self.map variableReference:name] ];
    
    NSRange r = NSMakeRange(0, [output length]);
    while (r.location != NSNotFound && r.location < [output length])
    {
        r = [output rangeOfString:@"$" options:NSLiteralSearch range:NSMakeRange(r.location, [output length] - r.location)];
        if (r.location != NSNotFound)
        {
            NSRange r2 = [output rangeOfString:@"$" options:NSLiteralSearch range:NSMakeRange(r.location+1, [output length] - r.location - 1)];
            if (r2.location != NSNotFound)
            {
                NSString *valueKey = [output substringWithRange:NSMakeRange(r.location+1, r2.location-r.location-1)];
                NSString *value = @"";
                
                NSObject* valueObject = [dict objectForKey:valueKey];
                
                //a BS check for enums - if there is a ? before the $, then we have an enum
                BOOL isEnum = (r.location > 0 && [output characterAtIndex:r.location-1] == '?') ||
                              ( [valueObject isKindOfClass:[NSDictionary class] ] && [ExportUtility isDictionaryEnum:(NSDictionary*)valueObject] );
            
                //if we have an enum, then do a lookup in this def's enum table
                if (isEnum)
                {
                    value = [self valueForEnum:valueKey valueObject:valueObject];
                }
                else
                {
                    value = [self getStringRepresentation:valueObject key:valueKey outlets:outlets includes:includes properties:properties];
                }
                
                if ( value && [ value length ] > 0 )
                {
                    int oldOutputLength = [output length];
                    int replaceStart = r.location;
                    int replaceLength = r2.location - r.location + 1;
                    if (isEnum && [output characterAtIndex:r.location-1] == '?')
                    {
                        replaceStart--;
                        replaceLength++;
                    }
                    output = [output stringByReplacingCharactersInRange:NSMakeRange(replaceStart, replaceLength) withString:value];
                    r2 = NSMakeRange(r2.location + ([output length] - oldOutputLength), 1);
                } else
                {
                    output = nil;
                }
            }
            
            r = NSMakeRange(r2.location+1, 1);
        }
    }

    if ([output length] > 0)
    {
        output = [NSString stringWithFormat:@"\t%@", output];
    }
    
    return output;
}

- (NSDictionary *) getCodeFor:(id)object isInline:(BOOL)isInline outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    NSDictionary* dict = nil;
    if ( [object isKindOfClass:[ViewGraphData class] ] )
    {
        ViewGraphData* data = (ViewGraphData*)object;
        dict = data.data;
    } else if ( [object isKindOfClass:[NSDictionary class] ] )
    {
        dict = object;
    }
    
    NSMutableString *code = [NSMutableString string];
    NSString *instanceName = nil;
    BOOL isOutlet = NO;
    
    NSString *class = [dict objectForKey:@"class"];
    if (class)
    {
        NSDictionary *def = [self.map definitionForClass:class];
        if (!def)
        {
            //only show a warning if this one isn't ignored
            if (!self.map.ignoredClasses || ![self.map.ignoredClasses objectForKey:class])
            {
                NSLog(@"Warning: No def found for %@!",class);
            }
            return nil;
        }

        //if we have an include, add that in
        if ([def objectForKey:@"_include"])
        {
            NSMutableArray *allIncludes = [NSMutableArray array];
            if ([[def objectForKey:@"_include"] isKindOfClass:[NSArray class]])
            {
                [allIncludes addObjectsFromArray:[def objectForKey:@"_include"]];
            }
            else
            {
                [allIncludes addObject:[def objectForKey:@"_include"]];
            }
            
            for (int i = 0; i < [allIncludes count]; i++)
            {
                if (![includes containsObject:[allIncludes objectAtIndex:i]])
                {
                    [includes addObject:[allIncludes objectAtIndex:i]];
                }
            }
        }
        
        //this is an annoying hack because with a status bar iOS tells us the Y is 0 in app, whereas it's 20 in the XIB
        if (![dict objectForKey:@"superview"] && [[[dict objectForKey:@"frame"] objectForKey:@"height"] floatValue] == 460.0f)
        {
            [[dict objectForKey:@"frame"] setObject:[NSNumber numberWithFloat:20.0f] forKey:@"y"];
        }
        
        //if we have an instance name, pull it out so we can use it later
        if ([dict objectForKey:@"instanceName"])
        {
            instanceName = [dict objectForKey:@"instanceName"];
            [[outlets objectForKey:@"stripped"] addObject:instanceName];
            [[outlets objectForKey:@"unstripped"] addObject:[[def objectForKey:@"_parameter"] stringByReplacingOccurrencesOfString:@"@" withString:instanceName]];
            [[properties objectForKey:@"outlets"] addObject:dict];
            
            isOutlet = YES;
        }
        //the root view is treated special
        else
        {
            if (![dict objectForKey:@"superview"])
            {
                if (self.map.rootViewInstanceName)
                {
                    instanceName = self.map.rootViewInstanceName;
                }
                else
                {
                    instanceName = @"rootView";
                }
            }
            //if it is normal and has no name, autogenerate the name
            else if ([def objectForKey:@"_variableName"])
            {
                NSString* variableName = [ def objectForKey:@"_variableName" ];
                instanceName = [ variableName stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"%@", [ self getInstanceCount:variableName ]]];
            }
        }
        
        NSString* constructor = [self codeForClassConstructor:class instanceName:instanceName outlets:outlets includes:includes dict:dict def:def properties:properties isInline:isInline isOutlet:isOutlet];
        
        [code appendString:constructor];
        
        if (!isInline)
        {
            NSString* setup = [self codeForObjectSetup:class instanceName:instanceName outlets:outlets includes:includes dict:dict def:def properties:properties];
            [code appendString:setup];
        }
        
        
        NSArray *subviews = [dict objectForKey:@"subviews"];
        for (int i = 0; i < [subviews count]; i++)
        {
            NSDictionary *subview = [self getCodeFor:[subviews objectAtIndex:i] isInline:NO outlets:outlets includes:includes properties:properties];
            if (subview)
            {
                [code appendString:[subview objectForKey:@"code"]];
                [code appendFormat:@"\t%@%@\n",
                 [self codeForAddSubview:subview instanceName:instanceName def:def],
                 [self.map statementEnd]
                 ];
            }
        }
    }
    else
    {
        NSLog(@"Warning: shouldn't be passing a dict with no class into getCode.");
    }
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code", instanceName, @"name", outlets, @"outlets", includes, @"includes", properties, @"properties", nil];
}

-(NSString*)exportFunctionCode:(NSString*)xibName
                    viewGraphData:(ViewGraphData*)viewGraphData
                    parameters:(NSString*)params
                          dict:(NSDictionary*)dict
                strippedParams:(NSString*)strippedParams
           strippedParamsComma:(NSString*)strippedParamsComma
                   paramsComma:(NSString*)paramsComma
{
    NSString *func = [self.map combinedFunctionDefinitions];
    
    func = [func stringByReplacingOccurrencesOfString:@"@" withString:xibName];
    func = [func stringByReplacingOccurrencesOfString:@"%" withString:params];
    func = [func stringByReplacingOccurrencesOfString:@"$GeneratedBody$" withString:[dict objectForKey:@"code"]];
    func = [func stringByReplacingOccurrencesOfString:@"§" withString:strippedParams];
    func = [func stringByReplacingOccurrencesOfString:@"∞" withString:strippedParamsComma];
    func = [func stringByReplacingOccurrencesOfString:@"ﬁ" withString:paramsComma];
    
    //get everything in between the ∂ signs and replace it with the proper values
    NSRange r = NSMakeRange(0, [func length]);
    while (r.location != NSNotFound && r.location < [func length])
    {
        r = [func rangeOfString:@"∂" options:NSLiteralSearch range:NSMakeRange(r.location, [func length] - r.location)];
        if (r.location != NSNotFound)
        {
            NSRange r2 = [func rangeOfString:@"∂" options:NSLiteralSearch range:NSMakeRange(r.location+1, [func length] - r.location - 1)];
            if (r2.location != NSNotFound)
            {
                NSString *dictPath = [func substringWithRange:NSMakeRange(r.location+1, r2.location-r.location-1)];
                NSArray *pathComponents = [dictPath componentsSeparatedByString:@"."];
                NSDictionary *subDict = viewGraphData.data;
                for (int i = 0; i < [pathComponents count]-1; i++)
                {
                    subDict = [subDict objectForKey:[pathComponents objectAtIndex:i]];
                }
                NSString *value = [subDict objectForKey:[pathComponents objectAtIndex:[pathComponents count]-1]];
                value = [self getStringRepresentation:value key:nil outlets:nil includes:nil properties:nil];
                
                int oldFuncLength = [func length];
                int replaceStart = r.location;
                int replaceLength = r2.location - r.location + 1;
                func = [func stringByReplacingCharactersInRange:NSMakeRange(replaceStart, replaceLength) withString:value];
                r2 = NSMakeRange(r2.location + ([func length] - oldFuncLength), 1);
            }
            
            r = NSMakeRange(r2.location+1, 1);
        }
    }
    return func;
}

- (void) doCodeExport:(ViewGraphData*)viewGraphData toFileNamePath:(NSString *)fileNamePath data:(NSDictionary *)data xibName:(NSString *)xibName atomically:(BOOL)flag error:(NSError**)error
{
    NSMutableString *code = [NSMutableString string];
    
    //autogeneration warning
    [code appendString:@"////////////////////AUTOGENERATED XIB EXPORTED CODE - DO NOT ALTER////////////////////\n"];
    
    //pragma
    [code appendString:@"\n"];
    [code appendString:@"#pragma once\n\n"];
    
    //includes
    NSArray *includes = [data objectForKey:@"includes"];
    for (NSObject* include in includes)
    {
        [code appendFormat:@"%@\n", include];
    }
    
    //construct a string representing all the outlet parameters
    NSDictionary *outlets = [data objectForKey:@"outlets"];
    NSString *params = @"";
    NSString *strippedParams = @"";
    NSString *paramsComma = @"";
    NSString *strippedParamsComma = @"";
    for (int j = 0; j < [[outlets objectForKey:@"unstripped"] count]; j++)
    {
        params = [params stringByAppendingFormat:@"%@%@",(j > 0 ? @", " : @""),[[outlets objectForKey:@"unstripped"] objectAtIndex:j]];
        paramsComma = [NSString stringWithFormat:@", %@",params];
        strippedParams = [strippedParams stringByAppendingFormat:@"%@%@",(j > 0 ? @", " : @""),[[outlets objectForKey:@"stripped"] objectAtIndex:j]];
        strippedParamsComma = [NSString stringWithFormat:@", %@",strippedParams];
    }
    
    [code appendString:[self exportFunctionCode:xibName viewGraphData:viewGraphData parameters:params dict:data strippedParams:strippedParams strippedParamsComma:strippedParamsComma paramsComma:paramsComma] ];
    
    [code writeToFile:fileNamePath atomically:flag encoding:NSUTF8StringEncoding error:error];
}

//translates the entire code string, dict and def are global dictionaries
- ( NSString * ) translateCodeString:(NSString *)classFile dict:(NSDictionary *)dict properties:(NSDictionary *)properties
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
    NSDictionary *compoundData = [NSDictionary dictionaryWithObjectsAndKeys:dict, @"dict", properties, @"properties", nil];
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

- (NSString *) parseDollarSandwich:(NSString *)inputString dict:(NSDictionary *)dict
{
    //hack
    if ( [inputString isEqualToString:@"instanceName"] )
    {
        return [dict objectForKey:inputString];
    }
    return [self getStringRepresentation:[dict objectForKey:inputString] key:inputString outlets:nil includes:nil properties:nil];
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
                    NSDictionary *subDef = [self.map definitionForClass:[obj objectForKey:@"class"]];
                    
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

-( NSNumber* )getInstanceCount:( NSString* )type
{
    unsigned int instanceCount = 0;
    
    NSNumber* storedInstanceCount = [ instanceCounts objectForKey:type ];
    if ( storedInstanceCount )
    {
        instanceCount = [ storedInstanceCount unsignedIntValue ];
    }
    
    [ instanceCounts setObject:[ NSNumber numberWithUnsignedInt:instanceCount + 1 ] forKey:type ];
    
    return [ NSNumber numberWithUnsignedInt:instanceCount ];
}

@end