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
#import "NSDictionary+Path.h"

#import "NSDictionary+ClassDefinition.h"
#import "NSDictionary+InstanceDefinition.h"

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

-(NSString*)exportData:(ViewGraphData*)viewGraphData toPath:(NSString*)targetPath error:(NSError **)error
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
                                       nil];
    
    NSDictionary* output = [self getCodeFor:viewGraphData isInline:NO outlets:outlets includes:includes properties:properties];
    
    NSString* exportFileNameFormat = [self multipleExportedFileNameFormat];
    
    NSString* baseFileName = [NSString stringWithFormat:@"Generated%@", xibName];
    exportedFileName = [NSString stringWithFormat:exportFileNameFormat, baseFileName];
    
    NSString* fileNamePath = [NSString stringWithFormat:@"%@/%@", targetPath, exportedFileName];
    
    [self doCodeExport:viewGraphData toFileNamePath:fileNamePath instanceDefinition:output xibName:xibName error:error];
    
    return exportedFileName;
}

-(NSString*)getStringRepresentationForDictionaryValue:(NSDictionary*)value key:(NSString*)key outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    NSString* result = nil;
    if ( [ExportUtility isDictionaryEnum:(NSDictionary*)value] )
    {
        result = [self stringValueForEnum:key valueObject:value];
    } else
    {
        NSDictionary* codeInfo = [self getCodeFor:value isInline:YES outlets:outlets includes:includes properties:properties];
        result = [codeInfo objectForKey:@"code"];
    }
    
    return result;
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

-(NSString*)stringValueForEnum:(NSString*)valueKey valueObject:(NSObject*)valueObject
{
    NSString* enumValueKey;
    NSRange prefix = [valueKey rangeOfString:@"." options:NSLiteralSearch];
    if (prefix.length == 0)
    {
        enumValueKey = valueKey;
    } else
    {
        enumValueKey = [valueKey substringFromIndex:prefix.location + prefix.length]; // TODO: think about subvalues, shouldn't these be processed in full like anything else?
    }
    
    NSString* result = nil;
    if ( [valueObject isKindOfClass:[NSDictionary class] ] )
    {
        NSDictionary* valueDict = (NSDictionary*)valueObject;
        result = [self.map convertEnum:valueDict.className value:[valueDict objectForKey:enumValueKey] ];
    }
    
    return result;
}

-(NSString*)codeForClassConstructor:(NSString*)class instanceName:(NSString*)instanceName outlets:(NSMutableDictionary*)outlets includes:(NSMutableArray*)includes instanceDefinition:(NSDictionary*)instanceDefinition properties:(NSMutableDictionary*)properties isInline:(BOOL)isInline isOutlet:(BOOL)isOutlet
{
    NSMutableString* constructor = nil;
    
    NSDictionary* classDefinition = [self.map definitionForClassOfInstance:instanceDefinition];
    
    //if this is an inline call, simply return the inline constructor
    if (isInline)
    {
        NSString* constructorDef = [classDefinition objectForKey:@"_inlineConstructor"];
        NSString* inl = [self replaceCodeSymbols:constructorDef instanceDefinition:instanceDefinition key:@"_inlineConstructor" name:instanceName outlets:outlets includes:includes properties:properties];
        constructor = [NSMutableString stringWithString:[inl substringFromIndex:1] ]; //remove the leading tab for an inline
    } else
    {
        
        NSString* constructorDef = [classDefinition objectForKey:@"_constructor"];
        if (constructorDef)
        {
            if (isOutlet)
            {
                constructorDef = [self replaceCodeSymbols:[classDefinition objectForKey:@"_inlineConstructor"] instanceDefinition:instanceDefinition key:@"_inlineConstructor" name:instanceName outlets:outlets includes:includes properties:properties];
                constructorDef = [NSString stringWithFormat:@"\t%@ = %@",[self.map variableReference:instanceName],[constructorDef substringFromIndex:1]];
            }
            else
            {
                constructorDef = [self replaceCodeSymbols:constructorDef instanceDefinition:instanceDefinition key:@"_constructor" name:instanceName outlets:outlets includes:includes properties:properties];
            }
            
            constructor = [NSMutableString stringWithString:@"\n"];
            
            NSString* comments = [ UIView getComments:instanceDefinition ];
            if ( comments )
            {
                [constructor appendString:comments ];
            }
            
            //only put the constructor in if this is not the root view, because the root view should be handled by surrounding code
            if ([instanceDefinition objectForKey:@"superview"])
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

-(NSString*)codeForInstanceSetup:(NSString*)instanceName outlets:(NSMutableDictionary*)outlets includes:(NSMutableArray*)includes instanceDefinition:(NSDictionary*)instanceDefinition properties:(NSMutableDictionary*)properties
{
    NSMutableString* objectSetup = [NSMutableString string];
    
    NSDictionary* classDefinition = [self.map definitionForClassOfInstance:instanceDefinition];

    for (NSString* classMember in [classDefinition allKeys] )
    {
        if ( [classDefinition isValidClassMember:classMember] && [instanceDefinition hasValueForMember:classMember] )
        {
            NSString *line = [classDefinition objectForKey:classMember];
            NSString* lineFilledIn = [self replaceCodeSymbols:line instanceDefinition:instanceDefinition key:classMember name:instanceName outlets:outlets includes:includes properties:properties];
            if ( lineFilledIn && [ lineFilledIn length ] > 0 )
            {
                [objectSetup appendFormat:@"%@%@\n", lineFilledIn, [self.map statementEnd] ];
            }
        }
    }
    
    return objectSetup;
}

-(NSString*)codeForAddSubview:(NSDictionary*)subview instanceName:(NSString*)instanceName classDefinition:(NSDictionary*)classDefinition
{
    NSString *addsub = [classDefinition objectForKey:@"_addSubview"];
    addsub = [addsub stringByReplacingOccurrencesOfString:@"@" withString:[self.map variableReference:instanceName] ];
    addsub = [addsub stringByReplacingOccurrencesOfString:@"%" withString:[self.map variableReference:[subview objectForKey:@"name"] ] ];
    return addsub;
}

-(NSString*)replace:(NSString*)string stringBetweenOccurencesOf:(NSString*)find withStringRepresentationFromInstance:(NSDictionary*)instanceDefinition outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    NSString* result = string;
    
    NSRange foundMarker = [result rangeOfString:find options:NSLiteralSearch];
    while (foundMarker.location != NSNotFound && foundMarker.length != 0)
    {
        NSString *valueKey = [result substringBetweenOccurancesOf:find];
        
        NSString *value = @"";
        
        NSObject* valueObject = [instanceDefinition objectAtPath:valueKey withPathSeparator:@"."];
        if (valueObject)
        {
            value = [self getStringRepresentation:valueObject key:valueKey outlets:outlets includes:includes properties:properties];
        }
        
        if ( value && [ value length ] > 0 )
        {
            NSRange replaceRange = [result rangeOfString:[NSString stringWithFormat:@"%@%@%@", find, valueKey, find] options:NSLiteralSearch];
            
            result = [result stringByReplacingCharactersInRange:replaceRange withString:value];
        } else
        {
            break;
        }
        
        foundMarker = [result rangeOfString:find options:NSLiteralSearch];
    }
    
    return result;
}

- (NSString *) replaceCodeSymbols:(NSString *)line instanceDefinition:(NSDictionary *)instanceDefinition key:(NSString *)key name:(NSString *)name outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    if (!line)
    {
        line = @"";
    }
    
    NSString* output = [line stringByReplacingOccurrencesOfString:@"@" withString:[self.map variableReference:name] ];
    output = [self replace:output stringBetweenOccurencesOf:@"$" withStringRepresentationFromInstance:instanceDefinition outlets:outlets includes:includes properties:properties];

    NSRange foundMarker = [output rangeOfString:@"$" options:NSLiteralSearch];
    if (foundMarker.length != 0) // instance didn't contain all values the definition wanted
    {
        output = nil;
    } else
    {
        output = [NSString stringWithFormat:@"\t%@", output];
    }
    
    return output;
}

-(void)addIncludes:(NSMutableArray*)includes forClass:(NSString*)className
{
    NSDictionary* classDefinition = [self.map definitionForClass:className];

    //if we have an include, add that in
    if ( [classDefinition objectForKey:@"_include"] )
    {
        NSMutableArray *allIncludes = [NSMutableArray array];
        
        id classIncludes = [classDefinition objectForKey:@"_include"];
        if ( [classIncludes isKindOfClass:[NSArray class] ] )
        {
            [allIncludes addObjectsFromArray:classIncludes];
        } else
        {
            [allIncludes addObject:classIncludes];
        }
        
        for (NSString* include in allIncludes)
        {
            if ( ![includes containsObject:include ] )
            {
                [includes addObject:include];
            }
        }
    }
}

- (NSDictionary *) getCodeFor:(id)object isInline:(BOOL)isInline outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    NSDictionary* instanceDefinition = nil;
    if ( [object isKindOfClass:[ViewGraphData class] ] )
    {
        ViewGraphData* data = (ViewGraphData*)object;
        instanceDefinition = data.rootViewInstanceDefinition;
    } else if ( [object isKindOfClass:[NSDictionary class] ] )
    {
        instanceDefinition = object;
    }
    
    NSMutableString *code = [NSMutableString string];
    NSString *instanceName = nil;
    BOOL isOutlet = NO;
    
    NSString* className = instanceDefinition.className;
    if (className)
    {
        NSDictionary *classDefinition = [self.map definitionForClass:className];
        if (!classDefinition)
        {
            //only show a warning if this one isn't ignored
            if (!self.map.ignoredClasses || ![self.map.ignoredClasses objectForKey:className])
            {
                NSLog(@"Warning: No class definition found for %@!",className);
            }
            return nil;
        }

        [self addIncludes:includes forClass:className];
        
        // TODO: check if this is still necessary
        //this is an annoying hack because with a status bar iOS tells us the Y is 0 in app, whereas it's 20 in the XIB
        if (![instanceDefinition objectForKey:@"superview"] && [[[instanceDefinition objectForKey:@"frame"] objectForKey:@"height"] floatValue] == 460.0f)
        {
            [[instanceDefinition objectForKey:@"frame"] setObject:[NSNumber numberWithFloat:20.0f] forKey:@"y"];
        }
        
        instanceName = [instanceDefinition instanceName];
        if (!instanceName)
        {
            if ( [classDefinition objectForKey:@"_variableName"] )
            {
                NSString* variableName = [classDefinition objectForKey:@"_variableName"];
                instanceName = [variableName stringByReplacingOccurrencesOfString:@"#" withString:[NSString stringWithFormat:@"%@", [self getInstanceCount:variableName] ] ];
            }
        }
        isOutlet = [instanceDefinition isOutlet];
        
        if (isOutlet)
        {
            [[outlets objectForKey:@"stripped"] addObject:instanceName];
            [[outlets objectForKey:@"unstripped"] addObject:[[classDefinition objectForKey:@"_parameter"] stringByReplacingOccurrencesOfString:@"@" withString:instanceName]];
            [[properties objectForKey:@"outlets"] addObject:instanceDefinition];
        }
        
        NSString* constructor = [self codeForClassConstructor:className instanceName:instanceName outlets:outlets includes:includes instanceDefinition:instanceDefinition properties:properties isInline:isInline isOutlet:isOutlet];
        
        [code appendString:constructor];
        
        if (!isInline)
        {
            NSString* setup = [self codeForInstanceSetup:instanceName outlets:outlets includes:includes instanceDefinition:instanceDefinition properties:properties];
            [code appendString:setup];
        }
        
        
        NSArray *subviews = [instanceDefinition objectForKey:@"subviews"];
        for (int i = 0; i < [subviews count]; i++)
        {
            NSDictionary *subview = [self getCodeFor:[subviews objectAtIndex:i] isInline:NO outlets:outlets includes:includes properties:properties];
            if (subview)
            {
                [code appendString:[subview objectForKey:@"code"]];
                [code appendFormat:@"\t%@%@\n",
                 [self codeForAddSubview:subview instanceName:instanceName classDefinition:classDefinition],
                 [self.map statementEnd]
                 ];
            }
        }
    }
    else
    {
        NSLog(@"Warning: shouldn't be passing a instance definiton with no class into getCode.");
    }
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code", instanceName, @"name", outlets, @"outlets", includes, @"includes", properties, @"properties", nil];
}

-(NSString*)exportFunctionCode:(NSString*)xibName
                    viewGraphData:(ViewGraphData*)viewGraphData
                    parameters:(NSString*)params
                          instanceDefinition:(NSDictionary*)instanceDefinition
                strippedParams:(NSString*)strippedParams
           strippedParamsComma:(NSString*)strippedParamsComma
                   paramsComma:(NSString*)paramsComma
{
    NSString *func = [self.map combinedFunctionDefinitions];
    
    func = [func stringByReplacingOccurrencesOfString:@"@" withString:xibName];
    func = [func stringByReplacingOccurrencesOfString:@"%" withString:params];
    func = [func stringByReplacingOccurrencesOfString:@"$GeneratedBody$" withString:[instanceDefinition objectForKey:@"code"]];
    func = [func stringByReplacingOccurrencesOfString:@"§" withString:strippedParams];
    func = [func stringByReplacingOccurrencesOfString:@"∞" withString:strippedParamsComma];
    func = [func stringByReplacingOccurrencesOfString:@"ﬁ" withString:paramsComma];
    
    func = [self replace:func stringBetweenOccurencesOf:@"∂" withStringRepresentationFromInstance:viewGraphData.rootViewInstanceDefinition outlets:nil includes:nil properties:nil];

    return func;
}

- (void) doCodeExport:(ViewGraphData*)viewGraphData toFileNamePath:(NSString *)fileNamePath instanceDefinition:(NSDictionary *)instanceDefinition xibName:(NSString *)xibName error:(NSError**)error
{
    NSMutableString *code = [NSMutableString string];
    
    //autogeneration warning
    [code appendString:@"////////////////////AUTOGENERATED XIB EXPORTED CODE - DO NOT ALTER////////////////////\n"];
    
    //pragma
    [code appendString:@"\n"];
    [code appendString:@"#pragma once\n\n"];
    
    //includes
    NSArray *includes = [instanceDefinition objectForKey:@"includes"];
    for (NSObject* include in includes)
    {
        [code appendFormat:@"%@\n", include];
    }
    
    //construct a string representing all the outlet parameters
    NSDictionary *outlets = [instanceDefinition objectForKey:@"outlets"];
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
    
    [code appendString:[self exportFunctionCode:xibName viewGraphData:viewGraphData parameters:params instanceDefinition:instanceDefinition strippedParams:strippedParams strippedParamsComma:strippedParamsComma paramsComma:paramsComma] ];
    
    [code writeToFile:fileNamePath atomically:NO encoding:NSUTF8StringEncoding error:error];
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