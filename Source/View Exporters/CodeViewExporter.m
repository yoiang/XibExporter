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

-(NSString*)codeForClassConstructor:(NSString*)class instanceName:(NSString*)instanceName instanceDefinition:(NSDictionary*)instanceDefinition properties:(NSMutableDictionary*)properties isInline:(BOOL)isInline isOutlet:(BOOL)isOutlet
{
    NSMutableString* constructor = nil;
    
    NSDictionary* classDefinition = [self.map definitionForClassOfInstance:instanceDefinition];
    
    //if this is an inline call, simply return the inline constructor
    if (isInline)
    {
        NSString* inl = [self replaceCodeSymbols:[classDefinition asInlineConstructorToParse] instanceDefinition:instanceDefinition instanceName:instanceName properties:properties];
        constructor = [NSMutableString stringWithString:[inl substringFromIndex:1] ]; //remove the leading tab for an inline
    } else
    {
        
        NSString* constructorDef = [classDefinition asConstructorToParse];
        if (constructorDef)
        {
            if (isOutlet)
            {
                constructorDef = [self replaceCodeSymbols:[classDefinition asInlineConstructorToParse] instanceDefinition:instanceDefinition instanceName:instanceName properties:properties];
                constructorDef = [NSString stringWithFormat:@"\t%@ = %@",[self.map variableReference:instanceName],[constructorDef substringFromIndex:1]];
            }
            else
            {
                constructorDef = [self replaceCodeSymbols:constructorDef instanceDefinition:instanceDefinition instanceName:instanceName properties:properties];
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

-(NSString*)codeForInstanceSetup:(NSString*)instanceName instanceDefinition:(NSDictionary*)instanceDefinition properties:(NSMutableDictionary*)properties
{
    NSMutableString* objectSetup = [NSMutableString string];
    
    NSDictionary* classDefinition = [self.map definitionForClassOfInstance:instanceDefinition];

    for (NSString* classMember in [classDefinition allKeys] )
    {
        if ( [classDefinition isValidClassMember:classMember] && [instanceDefinition hasValueForMember:classMember] )
        {
            NSString *line = [classDefinition objectForKey:classMember];
            NSString* lineFilledIn = [self replaceCodeSymbols:line instanceDefinition:instanceDefinition instanceName:instanceName properties:properties];
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
    return [classDefinition asAddSubViewWithInstanceName:[self.map variableReference:instanceName] andSubviewInstanceName:[self.map variableReference:[subview objectForKey:@"name"] ] ];
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

- (NSString *) replaceCodeSymbols:(NSString *)line instanceDefinition:(NSDictionary *)instanceDefinition instanceName:(NSString *)instanceName properties:(NSMutableDictionary *)properties
{
    if (!line)
    {
        line = @"";
    }
    
    NSString* output = [line stringByReplacingOccurrencesOfString:@"$instanceName$" withString:[self.map variableReference:instanceName] ];
    output = [self replace:output stringBetweenOccurencesOf:@"$" withStringRepresentationFromInstance:instanceDefinition properties:properties];

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

        [self addIncludes:[properties objectForKey:@"includes"] forClass:className];
        
        // TODO: check if this is still necessary
        //this is an annoying hack because with a status bar iOS tells us the Y is 0 in app, whereas it's 20 in the XIB
        if (![instanceDefinition objectForKey:@"superview"] && [[[instanceDefinition objectForKey:@"frame"] objectForKey:@"height"] floatValue] == 460.0f)
        {
            [[instanceDefinition objectForKey:@"frame"] setObject:[NSNumber numberWithFloat:20.0f] forKey:@"y"];
        }
        
        instanceName = [instanceDefinition instanceName];
        if (!instanceName)
        {
            instanceName = [NSString stringWithFormat:@"generic%@%@", className, [self getInstanceCount:className] ];
        }
        isOutlet = [instanceDefinition isOutlet];
        
        if (isOutlet)
        {
            [[properties objectForKey:@"outlets"] addObject:instanceDefinition];
        }
        
        NSString* constructor = [self codeForClassConstructor:className instanceName:instanceName instanceDefinition:instanceDefinition properties:properties isInline:isInline isOutlet:isOutlet];
        
        [code appendString:constructor];
        
        if (!isInline)
        {
            NSString* setup = [self codeForInstanceSetup:instanceName instanceDefinition:instanceDefinition properties:properties];
            [code appendString:setup];
        }
        
        
        NSArray *subviews = [instanceDefinition objectForKey:@"subviews"];
        for (int i = 0; i < [subviews count]; i++)
        {
            NSDictionary *subview = [self getCodeFor:[subviews objectAtIndex:i] isInline:NO properties:properties];
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
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code", instanceName, @"name", properties, @"properties", nil];
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
    
    [code replaceOccurrencesOfString:@"$instanceName$" withString:xibName ]; // TODO: Objective-C strings begin with @, change XibExporter matching @

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