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
#import "NSMutableString+Parsing.h"
#import "NSDictionary+Path.h"

#import "NSDictionary+ClassDefinition.h"
#import "NSMutableDictionary+InstanceDefinition.h"

static NSMutableDictionary* instanceCounts = nil;

@interface CodeViewExporter()

@property (nonatomic, strong) CodeMap* map;

@end

// TODO: map from code def and instance def directly to data instead of particular parsing

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
    if ( !instanceCounts )
    {
        instanceCounts = [ [ NSMutableDictionary alloc ] init ];
    } else
    {
        [ instanceCounts removeAllObjects ];
    }
    
    NSMutableDictionary* properties = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSMutableArray array], @"outlets",
                                       [NSMutableArray array], @"includes",
                                       nil];
    
    NSDictionary* rootInstanceDefinition = [self getCodeFor:viewGraphData isInline:NO properties:properties];

    NSString* xibName = [viewGraphData xibName];

    NSString *code = [self writeCodeTemplate:xibName viewGraphData:viewGraphData rootInstanceDefinition:rootInstanceDefinition properties:properties];

    NSString* exportFileNameFormat = [self multipleExportedFileNameFormat];
    
    NSString* exportedFileName = nil;

    NSString* baseFileName = [NSString stringWithFormat:@"Generated%@", xibName];
    exportedFileName = [NSString stringWithFormat:exportFileNameFormat, baseFileName];
    
    NSString* fileNamePath = [NSString stringWithFormat:@"%@/%@", targetPath, exportedFileName];
    
    [code writeToFile:fileNamePath atomically:NO encoding:NSUTF8StringEncoding error:error];
    
    return exportedFileName;
}

-(NSString*)getStringRepresentationForDictionaryValue:(NSDictionary*)value key:(NSString*)key properties:(NSMutableDictionary *)properties
{
    NSString* result = nil;
    if ( [ExportUtility isDictionaryEnum:(NSDictionary*)value] )
    {
        result = [self stringValueForEnum:key valueObject:value];
    } else
    {
        NSDictionary* codeInfo = [self getCodeFor:value isInline:YES properties:properties];
        result = [codeInfo objectForKey:@"code"];
    }
    
    return result;
}

-(NSString*)getStringRepresentationForArrayValue:(NSArray*)value key:( NSString* )key properties:(NSMutableDictionary *)properties
{
    NSMutableString* result = [NSMutableString string];
    
    // For now only used for masks
    for (id individualValue in value)
    {
        NSString* parsedStringValue = [self getStringRepresentation:individualValue key:key properties:properties];
        [result appendString:parsedStringValue withNonEmptySeparator:@" | "];
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

-(NSString*)stringValueForNumber:(NSNumber*)value
{
    NSString* result = nil;
    
    if (strcmp([value objCType], @encode(float)) == 0)
    {
        result = [self stringValueForFloat:[value floatValue] ];
    } else if (strcmp([value objCType], @encode(BOOL)) == 0)
    {
        result = [self stringValueForBoolean:[value boolValue] ];
    } else
    {
        result = [value stringValue];
    }
    return result;
}

- (NSString *) getStringRepresentation:(id)v key:( NSString* )key properties:(NSMutableDictionary *)properties
{
    NSString *result = nil;
    
    if ([v isKindOfClass:[NSDictionary class]] && properties )
    {
        result = [self getStringRepresentationForDictionaryValue:v key:key properties:properties];
    } else if ( [v isKindOfClass:[NSArray class] ] )
    {
        result = [self getStringRepresentationForArrayValue:v key:key properties:properties];
    } else if ([v isKindOfClass:[NSString class]])
    {
        result = [self getStringRepresentationForStringValue:v key:key];
    }
    else if ([v isKindOfClass:[NSNumber class]])
    {
        result = [self stringValueForNumber:v];
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

-(NSString*)stringValueForFloat:(float)value
{
    NSException* exception = [ [NSException alloc] initWithName:@"Abstract Method" reason:@"Must override [CodeViewExporter stringValueForFloat] method" userInfo:nil];
    @throw exception;
    
    return @"invalid";
}

-(NSString*)stringValueForBoolean:(BOOL)value
{
    NSException* exception = [ [NSException alloc] initWithName:@"Abstract Method" reason:@"Must override [CodeViewExporter stringValueForBoolean] method" userInfo:nil];
    @throw exception;
    
    return @"invalid";
}

-(NSString*)codeForClassConstructor:(NSString*)class instanceDefinition:(NSDictionary*)instanceDefinition properties:(NSMutableDictionary*)properties isInline:(BOOL)isInline
{
    NSString* constructor = nil;
    
    NSDictionary* classDefinition = [self.map definitionForClassOfInstance:instanceDefinition];
    
    //if this is an inline call, simply return the inline constructor
    if (isInline)
    {
        constructor = [self replaceCodeSymbols:[classDefinition asInlineConstructorToParse] instanceDefinition:instanceDefinition properties:properties];
    } else
    {
        //only put the constructor in if this is not the root view, because the root view should be handled by surrounding code
        if ( ![instanceDefinition isRootView] )
        {
            if ( [instanceDefinition isOutlet] )
            {
                constructor = [NSString stringWithFormat:@"%@ = %@",[self.map variableReference:[instanceDefinition instanceName] ], [self codeForClassConstructor:class instanceDefinition:instanceDefinition properties:properties isInline:YES] ];
            }
            else
            {
                constructor = [self replaceCodeSymbols:[classDefinition asConstructorToParse] instanceDefinition:instanceDefinition properties:properties];
            }
        }
    }

    return constructor;
}

-(NSString*)codeForInstanceSetup:(NSDictionary*)instanceDefinition properties:(NSMutableDictionary*)properties
{
    NSMutableString* objectSetup = [NSMutableString string];
    
    NSDictionary* classDefinition = [self.map definitionForClassOfInstance:instanceDefinition];

    for (NSString* classMember in [classDefinition allKeys] )
    {
        if ( [classDefinition isValidClassMember:classMember] && [instanceDefinition hasValueForMember:classMember] )
        {
            NSString *line = [classDefinition objectForKey:classMember];
            NSString* lineFilledIn = [self replaceCodeSymbols:line instanceDefinition:instanceDefinition properties:properties];
            if ( lineFilledIn && [ lineFilledIn length ] > 0 )
            {
                [self appendToCode:objectSetup statement:lineFilledIn tabbed:YES];
            }
        }
    }
    
    return objectSetup;
}

-(NSString*)replace:(NSString*)string stringBetweenOccurencesOf:(NSString*)find withStringRepresentationFromInstance:(NSDictionary*)instanceDefinition properties:(NSMutableDictionary *)properties
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
            value = [self getStringRepresentation:valueObject key:valueKey properties:properties];
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

- (NSString *) replaceCodeSymbols:(NSString *)line instanceDefinition:(NSDictionary *)instanceDefinition properties:(NSMutableDictionary *)properties
{
    if (!line)
    {
        line = @"";
    }
    
    NSString* output = [line stringByReplacingOccurrencesOfString:@"$instanceName$" withString:[self.map variableReference:[instanceDefinition instanceName] ] ];
    output = [self replace:output stringBetweenOccurencesOf:@"$" withStringRepresentationFromInstance:instanceDefinition properties:properties];

    NSRange foundMarker = [output rangeOfString:@"$" options:NSLiteralSearch];
    if (foundMarker.length != 0) // instance didn't contain all values the definition wanted
    {
        output = nil;
    } else
    {
        output = [NSString stringWithFormat:@"%@", output];
    }
    
    return output;
}

-(void)addIncludes:(NSMutableArray*)includes forClass:(NSString*)className
{
    for (NSString* include in [ [self.map definitionForClass:className] includes] )
    {
        if ( ![includes containsObject:include ] )
        {
            [includes addObject:include];
        }
    }
}

- (NSDictionary *) getCodeFor:(id)object isInline:(BOOL)isInline properties:(NSMutableDictionary *)properties
{
    NSMutableDictionary* instanceDefinition = nil;
    if ( [object isKindOfClass:[ViewGraphData class] ] )
    {
        ViewGraphData* data = (ViewGraphData*)object;
        instanceDefinition = data.rootViewInstanceDefinition;
    } else if ( [object isKindOfClass:[NSDictionary class] ] )
    {
        instanceDefinition = object;
    }
    
    NSMutableString *code = [NSMutableString string];
    
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

        [self addIncludes:[properties objectForKey:@"includes"] forClass:className];
        
        // TODO: check if this is still necessary
        //this is an annoying hack because with a status bar iOS tells us the Y is 0 in app, whereas it's 20 in the XIB
        if ( [instanceDefinition isRootView] && [[[instanceDefinition objectForKey:@"frame"] objectForKey:@"height"] floatValue] == 460.0f)
        {
            [[instanceDefinition objectForKey:@"frame"] setObject:[NSNumber numberWithFloat:20.0f] forKey:@"y"];
        }
        
        if ( ![instanceDefinition instanceName] )
        {
            instanceDefinition.instanceName = [NSString stringWithFormat:@"generic%@%@", className, [self getInstanceCount:className] ];
        }
        
        if ( [instanceDefinition isOutlet] )
        {
            [[properties objectForKey:@"outlets"] addObject:instanceDefinition];
        }
        
        if (!isInline)
        {
            [code appendString:@"\n"];
            for (NSString* comment in [instanceDefinition comments] )
            {
                [self appendToCode:code statement:[NSString stringWithFormat:@"// %@", comment] tabbed:YES];
            }
        }
        
        NSString* constructor = [self codeForClassConstructor:className instanceDefinition:instanceDefinition properties:properties isInline:isInline];
        
        if (isInline)
        {
            [code appendString:constructor];
        } else
        {
            [self appendToCode:code statement:constructor tabbed:YES];
        }
        
        if (!isInline)
        {
            NSString* setup = [self codeForInstanceSetup:instanceDefinition properties:properties];
            [code appendString:setup];
        }
        
        
        for (NSDictionary* subViewDefinition in [instanceDefinition subviews] )
        {
            NSDictionary *subviewCode = [self getCodeFor:subViewDefinition isInline:NO properties:properties];
            if (subviewCode)
            {
                [code appendString:[subviewCode objectForKey:@"code"]];
                
                NSString* addSubviewStatement = [classDefinition asAddSubViewWithInstanceName:[self.map variableReference:[instanceDefinition instanceName] ] andSubviewInstanceName:[self.map variableReference:[subviewCode objectForKey:@"instanceName"] ] ];
                [self appendToCode:code statement:addSubviewStatement tabbed:YES];
            }
        }
    }
    else
    {
        NSLog(@"Warning: shouldn't be passing a instance definiton with no class into getCode.");
    }
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code", [instanceDefinition instanceName], @"instanceName", nil];
}

-(void)appendToCode:(NSMutableString*)code statement:(NSString*)statement tabbed:(BOOL)tabbed
{
    if ( [statement length] > 0 )
    {
        if (tabbed)
        {
            // TODO: move to config json
            [code appendString:@"\t"];
        }
        
        [code appendFormat:@"%@%@\n", statement, [self.map statementEnd] ];
    }
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

#pragma mark Write selectors

-(NSString*)writeCodeTemplate:(NSString*)xibName
                viewGraphData:(ViewGraphData*)viewGraphData
       rootInstanceDefinition:(NSDictionary*)rootInstanceDefinition
                   properties:(NSDictionary*)properties
{
    NSMutableString* code = [NSMutableString string];
    
    [code appendString:[self.map combinedFunctionDefinitions] ];
    
    [code replaceOccurrencesOfString:@"$instanceName$" withString:xibName ];

    // TODO: exported by whom
    
    NSDate* now = [NSDate date];
    [code replaceOccurrencesOfString:@"$exportTime$" withString:[NSString stringWithFormat:@"%@", now] ];
    
    //includes
    NSArray* includes = [properties objectForKey:@"includes"];
    [code replaceOccurrencesOfString:@"$includes$" withString:[includes componentsJoinedByString:@"\n"] ];
    
    NSDictionary* outlets = [properties objectForKey:@"outlets"];
    [self writeCodeTemplate:code forOutlets:outlets];
    
    NSString* generatedBody = [rootInstanceDefinition objectForKey:@"code"];
    [code replaceOccurrencesOfString:@"$GeneratedBody$" withString:generatedBody ];
    
    // TODO: change replace: to accept mutable string
    code = [NSMutableString stringWithString:[self replace:code stringBetweenOccurencesOf:@"∂" withStringRepresentationFromInstance:viewGraphData.rootViewInstanceDefinition properties:nil] ];
    
    return code;
}

-(void)writeCodeTemplate:(NSMutableString*)code forOutlets:(NSDictionary*)outlets
{
    //construct a string representing all the outlet parameters
    NSMutableString* params = [NSMutableString string];
    NSMutableString* strippedParams = [NSMutableString string];
    
    for (NSDictionary* instanceDefinition in outlets )
    {
        NSDictionary* classDefinition = [self.map definitionForClassOfInstance:instanceDefinition];
        
        NSString* strippedOutlet = [instanceDefinition instanceName];
        NSString* unstrippedOutlet = [classDefinition asParameterWithInstanceName:strippedOutlet];
        
        // TODO: C style parameters, support template of other formats
        [params appendString:unstrippedOutlet withNonEmptySeparator:@", "];
        [strippedParams appendString:strippedOutlet withNonEmptySeparator:@", "];
    }
    
    NSString* paramsFollowingComma = nil;
    if ([params length] > 0)
    {
        paramsFollowingComma = [NSString stringWithFormat:@", %@", params];
    }
    
    NSString* strippedParamsComma = nil;
    if ( [strippedParams length] > 0)
    {
        strippedParamsComma = [NSString stringWithFormat:@", %@", strippedParams];
    }
    
    [code replaceOccurrencesOfString:@"%" withString:params];
    [code replaceOccurrencesOfString:@"§" withString:strippedParams];
    [code replaceOccurrencesOfString:@"∞" withString:strippedParamsComma];
    [code replaceOccurrencesOfString:@"ﬁ" withString:paramsFollowingComma];
}

@end