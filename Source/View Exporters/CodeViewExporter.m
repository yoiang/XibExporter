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

#import "ViewGraphs.h"
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

- (id) init
{
    self = [super init];
    if (self)
    {
        self.map = [ [CodeMap alloc] initWithJSONFileName:[self codeMapJSONDefinitionFileName] ];
    }
    return self;
}

- (NSArray *)exportData:(ViewGraphs*)viewGraphs toProject:(BOOL)useProjectDir atomically:(BOOL)flag error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified
{
    NSString *targetFile = nil;
    
    if (useProjectDir)
    {
        targetFile = [[AppSettings getGeneratedSourceFolder] stringByAppendingString:@"/ExportedViews.h"];
    }
    else
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        targetFile = [NSString stringWithFormat:@"%@/ExportedViews.h",documentsDirectory];
    }
    
    NSString* location = [NSString stringWithFormat:@"%@.h",[targetFile stringByDeletingPathExtension]];
    if (mult)
    {
        location = [location stringByDeletingLastPathComponent];
    }
    
    return [self exportData:viewGraphs toFile:location atomically:flag error:error saveMultipleFiles:mult useOnlyModifiedFiles:onlyModified];
}

-(NSArray*)exportData:(ViewGraphs *)viewGraphs toFile:(NSString*)location atomically:(BOOL)flag error:(NSError **)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified
{
    
    NSMutableDictionary *output = [NSMutableDictionary dictionary];
    NSMutableArray *outputFileNames = [NSMutableArray array];
    
    //loop through all the VCs, they'll each go in a separate function
    NSArray *keys = viewGraphs.xibNames;
    
    if ( ![AppSettings forceExportAllXibs] )
    {
        keys = [XcodeProjectHelper trimToOnlyModifiedFiles:keys];
    }
    
    if ([keys count] <= 0)
    {
        NSLog(@"Not exporting any views because you haven't made any changes to them.\nTo force changes, edit the viewChanges.txt file found in Xib-Exporter/XibExporter/");
        return outputFileNames;
    }
    
    NSLog(@"Exporting code for %d file(s).\n%@",[keys count],keys);
    
    for (int i = 0; i < [keys count]; i++)
    {
        NSString* xibName = [keys objectAtIndex:i];
        
        ViewGraphData *viewGraphData = [viewGraphs dataForXib:xibName];
        NSMutableDictionary *vc = viewGraphData.data;
        
        if ( !instanceCounts )
        {
            instanceCounts = [ [ NSMutableDictionary alloc ] init ];
        } else
        {
            [ instanceCounts removeAllObjects ];
        }
        
        NSDictionary *obj = [self getCodeFor:viewGraphData
                                    isInline:NO
                                     outlets:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSMutableArray array], @"stripped",
                                              [NSMutableArray array], @"unstripped", nil]
                                    includes:[NSMutableArray array]
                                  properties:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSMutableArray array], @"outlets",
                                              [NSMutableArray array], @"buttons",
                                              [NSNumber numberWithBool:NO], @"hasButtons",
                                              [keys objectAtIndex:i], @"className", nil]
                             ];
        if (obj)
        {
            [output setObject:obj forKey:[keys objectAtIndex:i]];
            
            //create cpp and h files
            if ( [vc objectForKey:@"exportToCode"] )
            {
                [[obj objectForKey:@"properties"] setObject:[obj objectForKey:@"includes"] forKey:@"includes"];
                NSArray *codeFiles = [self exportCodeForDict:vc properties:[obj objectForKey:@"properties"]];
                
                //TODO this should be moved somewhere else
                for ( int j = 0; j < [codeFiles count]; j++ )
                {
                    NSString *code = [codeFiles objectAtIndex:j];
                    NSString *extension = [[self.map.codeExporterFileNames objectAtIndex:j] objectForKey:@"extension"];
                    NSString *loc = [NSString stringWithFormat:@"%@.%@",[keys objectAtIndex:i],extension];
                    loc = [NSString stringWithFormat:@"%@/%@",[location stringByDeletingLastPathComponent],loc];
                    if ( ![[NSFileManager defaultManager] fileExistsAtPath:loc] )
                    {
                        [code writeToFile:loc atomically:flag encoding:NSUTF8StringEncoding error:error];
                    }
                    NSLog(@"Exported code file to %@",loc);
                    //[XcodeProjectHelper addToXcodeProject:codeFiles];
                }
            }
        }
    }
    
    if (mult)
    {
        for (int i = 0; i < [keys count]; i++)
        {
            NSString *k = [keys objectAtIndex:i];
            NSString *fileLocation = [NSString stringWithFormat:@"%@/Generated%@.h",location,k];
            [self doCodeExport:viewGraphs atLocation:fileLocation data:output keys:[NSArray arrayWithObject:k] atomically:flag error:error];
            
            [outputFileNames addObject:[NSString stringWithFormat:@"Generated%@.h",k]];
            /*if (&error)
             {
             return;
             }*/
        }
    }
    else
    {
        [self doCodeExport:viewGraphs atLocation:location data:output keys:keys atomically:flag error:error];
        [outputFileNames addObject:[location lastPathComponent]];
    }
    
    return outputFileNames;
}

- ( NSArray * ) exportCodeForDict:(NSDictionary *)dict properties:(NSDictionary *)properties
{
    NSArray *files = self.map.codeExporterFileNames;
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
        
        NSString *output = [self translateCodeString:classFile dict:dict properties:properties];
        [outputArray addObject:output];
    }
    
    return outputArray;
}

- (NSString *) getStringRepresentation:(id)v key:( NSString* )key outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    NSString *value = nil;
    
    if ([v isKindOfClass:[NSDictionary class]] && outlets && includes && properties )
    {
        value = [[self getCodeFor:v isInline:YES outlets:outlets includes:includes properties:properties] objectForKey:@"code"];
    }
    else if ([v isKindOfClass:[NSString class]])
    {
        NSString* buildFormat = @"\"%@\"";
        if (!self.map.asIsStringKeys || [self.map.asIsStringKeys objectForKey:key])
        {
            buildFormat = @"%@";
        }
        value = [[NSString stringWithFormat:buildFormat,v] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        value = [value stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    }
    else if ([v isKindOfClass:[NSNumber class]])
    {
        if (strcmp([v objCType], @encode(float)) == 0)
        {
            if ([v floatValue] - [v intValue] == 0)
            {
                value = [NSString stringWithFormat:@"%@.0f",[v stringValue]];
            }
            else
            {
                value = [NSString stringWithFormat:@"%@f",[v stringValue]];
            }
        }
        else if (strcmp([v objCType], @encode(BOOL)) == 0)
        {
            if ( [v boolValue] )
            {
                value = @"true";
            }
            else
            {
                value = @"false";
            }
        }
        else
        {
            value = [v stringValue];
        }
    }
    
    if (!value)
    {
        value = @"0";
    }
    
    return value;
}

-(NSString*)valueForEnum:(NSString*)valueKey dict:(NSDictionary *)dict def:(NSDictionary*)def
{
    NSDictionary* enumValue = [dict objectForKey:valueKey];
    
    NSString* enumValueKey;
    NSRange prefix = [valueKey rangeOfString:@"." options:NSLiteralSearch];
    if (prefix.length == 0)
    {
        enumValueKey = valueKey;
    } else
    {
        enumValueKey = [valueKey substringFromIndex:prefix.location + prefix.length];
    }
    
    return [self.map convertEnum:[enumValue objectForKey:@"class"] value:[enumValue objectForKey:enumValueKey] ];
}

-(NSString*)constructorForClass:(NSString*)class instanceName:(NSString*)instanceName outlets:(NSMutableDictionary*)outlets includes:(NSMutableArray*)includes dict:(NSDictionary*)dict def:(NSDictionary*)def properties:(NSMutableDictionary*)properties isInline:(BOOL)isInline isOutlet:(BOOL)isOutlet
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
                constructorDef = [NSString stringWithFormat:@"\t%@ = %@",instanceName,[constructorDef substringFromIndex:1]];
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

-(NSString*)objectSetup:(NSString*)class instanceName:(NSString*)instanceName outlets:(NSMutableDictionary*)outlets includes:(NSMutableArray*)includes dict:(NSDictionary*)dict def:(NSDictionary*)def properties:(NSMutableDictionary*)properties
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

- (NSString *) replaceCodeSymbols:(NSString *)line dict:(NSDictionary *)dict key:(NSString *)key name:(NSString *)name outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes def:(NSDictionary *)def properties:(NSMutableDictionary *)properties
{
    if (!line)
    {
        line = @"";
    }
    
    NSString* output = [line stringByReplacingOccurrencesOfString:@"@" withString:name];
    
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
                    value = [self valueForEnum:valueKey dict:dict def:def];
                }
                else
                {
                    value = [self getStringRepresentation:[dict objectForKey:valueKey] key:valueKey outlets:outlets includes:includes properties:properties];
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

//        if (def)
        {
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
                
                //add me to the buttons list if I'm a button
                if ( [class rangeOfString:@"button" options:NSCaseInsensitiveSearch].location != NSNotFound )
                {
                    [properties setObject:[NSNumber numberWithBool:YES] forKey:@"hasButtons"];
                    [[properties objectForKey:@"buttons"] addObject:dict];
                }
                
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
            
            NSString* constructor = [self constructorForClass:class instanceName:instanceName outlets:outlets includes:includes dict:dict def:def properties:properties isInline:isInline isOutlet:isOutlet];
            
            [code appendString:constructor];
            
            if (!isInline)
            {
                NSString* setup = [self objectSetup:class instanceName:instanceName outlets:outlets includes:includes dict:dict def:def properties:properties];
                [code appendString:setup];
            }
            
            
            NSArray *subviews = [dict objectForKey:@"subviews"];
            for (int i = 0; i < [subviews count]; i++)
            {
                NSDictionary *subview = [self getCodeFor:[subviews objectAtIndex:i] isInline:NO outlets:outlets includes:includes properties:properties];
                if (subview)
                {
                    [code appendString:[subview objectForKey:@"code"]];
                    NSString *addsub = [def objectForKey:@"_addSubview"];
                    addsub = [addsub stringByReplacingOccurrencesOfString:@"@" withString:instanceName];
                    addsub = [addsub stringByReplacingOccurrencesOfString:@"%" withString:[subview objectForKey:@"name"]];
                    [code appendFormat:@"\t%@%@\n", addsub, [self.map statementEnd] ];
                }
            }
        }
    }
    else
    {
        NSLog(@"Warning: shouldn't be passing a dict with no class into getCode.");
    }
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code", instanceName, @"name", outlets, @"outlets", includes, @"includes", properties, @"properties", nil];
}

- (void) doCodeExport:(ViewGraphs*)viewGraphs atLocation:(NSString *)location data:(NSDictionary *)data keys:(NSArray *)keys atomically:(BOOL)flag error:(NSError**)error
{
    NSMutableString *code = [NSMutableString string];
    
    //autogeneration warning
    [code appendString:@"////////////////////AUTOGENERATED XIB EXPORTED CODE - DO NOT ALTER////////////////////\n"];
    
    //pragma
    [code appendString:@"\n"];
    [code appendString:@"#pragma once\n\n"];
    
    //includes
    NSMutableArray *allIncludes = [NSMutableArray array];
    for (int i = 0; i < [keys count]; i++)
    {
        NSDictionary *dict = [data objectForKey:[keys objectAtIndex:i]];
        NSArray *includes = [dict objectForKey:@"includes"];
        for (int j = 0; j < [includes count]; j++)
        {
            if (![allIncludes containsObject:[includes objectAtIndex:j]])
            {
                [allIncludes addObject:[includes objectAtIndex:j]];
            }
        }
    }
    for (int i = 0; i < [allIncludes count]; i++)
    {
        [code appendFormat:@"%@\n",[allIncludes objectAtIndex:i]];
    }
    
    //code
    for (int i = 0; i < [keys count]; i++)
    {
        NSString *k = [keys objectAtIndex:i];
        NSDictionary *dict = [data objectForKey:k];
        
        //construct a string representing all the outlet parameters
        NSDictionary *outlets = [dict objectForKey:@"outlets"];
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
        
        //go through all the function definitions and create them
        NSArray *funcDefs = self.map.functionDefinitions;
        for (int i = 0; i < [funcDefs count]; i++)
        {
            NSString *func = [[funcDefs objectAtIndex:i] stringByReplacingOccurrencesOfString:@"@" withString:k];
            func = [func stringByReplacingOccurrencesOfString:@"%" withString:params];
            func = [func stringByReplacingOccurrencesOfString:@"ƒ" withString:[dict objectForKey:@"code"]];
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
                        ViewGraphData *viewGraphData = [viewGraphs dataForXib:k];
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
            
            [code appendFormat:@"\n\n%@",func];
        }
        
        /*
         //get the outlets and write them as pointers into the function signature
         NSString *func = [[self.codeMap objectForKey:@"_function"] stringByReplacingOccurrencesOfString:@"@" withString:k];
         NSArray *outlets = [dict objectForKey:@"outlets"];
         NSString *params = @"";
         for (int j = 0; j < [outlets count]; j++)
         {
         NSString *param = [outlets objectAtIndex:j];
         params = [params stringByAppendingFormat:@"%@%@",(j > 0 ? @", " : @""),param];
         }
         func = [func stringByReplacingOccurrencesOfString:@"%" withString:params];
         
         [code appendFormat:@"%@\n{\n",func];
         NSString *ret = [[self.codeMap objectForKey:@"_return"] stringByReplacingOccurrencesOfString:@"@" withString:[dict objectForKey:@"name"]];
         [code appendFormat:@"%@\t%@;\n}\n\n",[dict objectForKey:@"code"], ret];*/
    }
    
    [code writeToFile:location atomically:flag encoding:NSUTF8StringEncoding error:error];
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

/*
 #import "UIViewController+Exports.h"
 #import "SBJson.h"
 #import "UIView+Exports.h"
 #import "XcodeProjectHelper.h"
 
 #import "NSArray+NSString.h"
 #import "NSString+Parsing.h"
 
 #import "AppDelegate.h"
 #import "XibResources.h"
 
 #import "CXMLElement+UIView.h"
 
 #import "ViewGraphData.h"
 
 #pragma mark Public Methods
 
 
 
 
 
 - (NSArray *) exportData:(ViewGraphs*)viewGraphs toProject:(BOOL)useProjectDir atomically:(BOOL)flag format:(ViewExporterFormat)format error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified
 {
 NSString *targetFile = nil;
 
 if (useProjectDir)
 {
 targetFile = [[XcodeProjectHelper getGeneratedSourceFolder] stringByAppendingString:@"/ExportedViews.h"];
 }
 else
 {
 NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
 targetFile = [NSString stringWithFormat:@"%@/ExportedViews.h",documentsDirectory];
 }
 
 return [self exportData:viewGraphs toFile:targetFile atomically:flag format:format error:error saveMultipleFiles:mult useOnlyModifiedFiles:onlyModified];
 }
 
 
 
 @end
 */