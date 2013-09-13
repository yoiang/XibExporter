//
//  ViewExporter.m
//  XibExporter
//
//  The main point of entry for exports.
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewExporter.h"
#import "UIViewController+Exports.h"
#import "SBJson.h"
#import "UIView+Exports.h"
#import "XcodeProjectHelper.h"
#import "CodeExporter.h"

#import "CXMLElement+Xib.h"
#import "NSArray+NSString.h"

static ViewExporter *instance;
static NSMutableDictionary* instanceCounts = nil;

@implementation ViewExporter

@synthesize exportedData, codeMap, fontExchange;

#pragma mark Private Methods

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

//must be written manually, le sigh
- (void) exportXMLTo:(NSString *)location atomically:(BOOL)flag error:(NSError**)error
{
    //TODO
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
        if (![self.codeMap objectForKey:@"_asIsStringKeys"] || [[self.codeMap objectForKey:@"_asIsStringKeys"] objectForKey:key])
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

- (NSString *) replaceCodeSymbols:(NSString *)line dict:(NSDictionary *)dict key:(NSString *)key name:(NSString *)name outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes def:(NSDictionary *)def properties:(NSMutableDictionary *)properties
{
    if (!line)
    {
        line = @"";
    }
    
    NSString *output = [NSString stringWithFormat:@"\t%@",[line stringByReplacingOccurrencesOfString:@"@" withString:name]];
    
    NSRange r = NSMakeRange(0, [output length]);
    while (r.location != NSNotFound && r.location < [output length])
    {
        r = [output rangeOfString:@"$" options:NSLiteralSearch range:NSMakeRange(r.location, [output length] - r.location)];
        if (r.location != NSNotFound)
        {
            //a BS check for enums - if there is a ? before the $, then we have an enum
            BOOL isEnum = (r.location > 0 && [output characterAtIndex:r.location-1] == '?');
            
            NSRange r2 = [output rangeOfString:@"$" options:NSLiteralSearch range:NSMakeRange(r.location+1, [output length] - r.location - 1)];
            if (r2.location != NSNotFound)
            {
                NSString *valueKey = [output substringWithRange:NSMakeRange(r.location+1, r2.location-r.location-1)];
                NSString *value = @"";
                
                //if we have an enum, then do a lookup in this def's enum table
                if (isEnum)
                {
                    NSDictionary *enm = [def objectForKey:@"_enum"];
                    if (enm)
                    {
                        value = [enm objectForKey:[dict objectForKey:valueKey]];
                    }
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
                    if (isEnum)
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
    
    return output;
}

- (NSDictionary *) getCodeFor:(NSMutableDictionary *)dict isInline:(BOOL)isInline outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties
{
    NSMutableString *code = [NSMutableString string];
    NSString *instanceName = nil;
    BOOL isOutlet = NO;
    
    NSString *class = [dict objectForKey:@"class"];
    if (class)
    {
        NSDictionary *def = [self.codeMap objectForKey:class];
        if (def)
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
                    if ([self.codeMap objectForKey:@"_rootViewInstanceName"])
                    {
                        instanceName = [self.codeMap objectForKey:@"_rootViewInstanceName"];
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
            
            //if this is an inline call, simply return the inline constructor
            if (isInline)
            {
                NSString *constructor = [def objectForKey:@"_inlineConstructor"];
                NSString *inl = [self replaceCodeSymbols:constructor dict:dict key:@"_inlineConstructor" name:instanceName outlets:outlets includes:includes def:def properties:properties];
                inl = [inl substringFromIndex:1]; //remove the leading tab for an inline
                [code appendString:inl];
            }
            else
            {
                NSString *constructor = [def objectForKey:@"_constructor"];
                if (constructor)
                {
                    if (isOutlet)
                    {
                        constructor = [self replaceCodeSymbols:[def objectForKey:@"_inlineConstructor"] dict:dict key:@"_inlineConstructor" name:instanceName outlets:outlets includes:includes def:def properties:properties];
                        constructor = [NSString stringWithFormat:@"\t%@ = %@",instanceName,[constructor substringFromIndex:1]];
                    }
                    else
                    {
                        constructor = [self replaceCodeSymbols:constructor dict:dict key:@"_constructor" name:instanceName outlets:outlets includes:includes def:def properties:properties];
                    }

                    [ code appendString:@"\n" ]; 
                    NSString* comments = [ UIView getComments:dict ];
                    if ( comments )
                    {
                        [ code appendString:comments ]; 
                    }

                    //only put the constructor in if this is not the root view, because the root view should be handled by surrounding code
                    if ([dict objectForKey:@"superview"])
                    {
                        [code appendString:[NSString stringWithFormat:@"%@;\n",constructor]]; 
                    }

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
                                [code appendFormat:@"%@;\n",lineFilledIn];
                            }
                        }
                    }
                }
                else
                {
                    NSLog(@"Warning: No _constructor found for %@!",class);
                }
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
                    [code appendFormat:@"\t%@;\n",addsub];
                }
            }
        }
        else
        {
            //only show a warning if this one isn't ignored
            if (![self.codeMap objectForKey:@"_ignoredClasses"] || ![[self.codeMap objectForKey:@"_ignoredClasses"] objectForKey:class])
            {
                NSLog(@"Warning: No def found for %@!",class);
            }
            return nil;
        }
    }
    else
    {
        NSLog(@"Warning: shouldn't be passing a dict with no class into getCode.");
    }
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code", instanceName, @"name", outlets, @"outlets", includes, @"includes", properties, @"properties", nil];
}

- (void) doCodeExport:(NSString *)location data:(NSDictionary *)data keys:(NSArray *)keys atomically:(BOOL)flag error:(NSError**)error
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
        NSArray *funcDefs = [self.codeMap objectForKey:@"_functionDefinitions"];
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
                        NSDictionary *subDict = [self.exportedData objectForKey:k];
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

- (NSArray *) exportCodeTo:(NSString *)location atomically:(BOOL)flag error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified
{
    NSMutableDictionary *output = [NSMutableDictionary dictionary];
    NSMutableArray *outputFileNames = [NSMutableArray array];
    
    //loop through all the VCs, they'll each go in a separate function
    NSArray *keys = nil;
    
    if ( [ XcodeProjectHelper forceExportAllXibs ] )
    {
        keys = [ self.exportedData allKeys ];
    } else
    {
        keys = [ XcodeProjectHelper trimToOnlyModifiedFiles:[ self.exportedData allKeys ] ];
    }
    
    if ([keys count] <= 0)
    {
        NSLog(@"Not exporting any views because you haven't made any changes to them.\nTo force changes, edit the viewChanges.txt file found in Xib-Exporter/XibExporter/");
        return outputFileNames;
    }
    
    NSLog(@"Exporting code for %d files.\n%@",[keys count],keys);
    
    for (int i = 0; i < [keys count]; i++)
    {
        NSMutableDictionary *vc = [self.exportedData objectForKey:[keys objectAtIndex:i]];
        
        if ( !instanceCounts )
        {
            instanceCounts = [ [ NSMutableDictionary alloc ] init ];
        } else
        {
            [ instanceCounts removeAllObjects ];
        }
        
        NSDictionary *obj = [self getCodeFor:vc
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
                NSArray *codeFiles = [[CodeExporter sharedInstance] exportCodeForDict:vc def:self.codeMap properties:[obj objectForKey:@"properties"]];
                
                //TODO this should be moved somewhere else
                for ( int j = 0; j < [codeFiles count]; j++ )
                {
                    NSString *code = [codeFiles objectAtIndex:j];
                    NSString *extension = [[[self.codeMap objectForKey:@"_codeExporterFileNames"] objectAtIndex:j] objectForKey:@"extension"];
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
            [self doCodeExport:fileLocation data:output keys:[NSArray arrayWithObject:k] atomically:flag error:error];
            
            [outputFileNames addObject:[NSString stringWithFormat:@"Generated%@.h",k]];
            /*if (&error)
            {
                return;
            }*/
        }
    }
    else
    {
        [self doCodeExport:location data:output keys:keys atomically:flag error:error];
        [outputFileNames addObject:[location lastPathComponent]];
    }
    
    return outputFileNames;
}

#pragma mark Public Methods

+ (ViewExporter *) sharedInstance
{
    if (!instance)
    {
        instance = [[ViewExporter alloc] init];
    }
    return instance;
}

- (id) init
{
    if (self = [super init])
    {
        NSString *ofxGenericDefinitionJson = @"ofxGenericDefinition";
        
        self.exportedData = [NSMutableDictionary dictionary];
        NSError *error = nil;
        NSString *defFile = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ofxGenericDefinitionJson ofType:@"json"] encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"Couldn't load %@ file!", ofxGenericDefinitionJson);
            self.codeMap = nil;
        }
        else
        {
            self.codeMap = [defFile JSONValue];
            
            //populate subclasses with the data from their superclasses
            NSArray *keys = [self.codeMap allKeys];
            for (int i = 0; i < [keys count]; i++)
            {
                id obj = [self.codeMap objectForKey:[keys objectAtIndex:i]];
                if ([obj isKindOfClass:[NSMutableDictionary class]])
                {
                    NSMutableDictionary *def = obj;
                    while ([def objectForKey:@"_super"])
                    {
                        NSDictionary *superDef = [self.codeMap objectForKey:[def objectForKey:@"_super"]];
                        [def removeObjectForKey:@"_super"];
                        if (superDef)
                        {
                            NSArray *superKeys = [superDef allKeys];
                            for (int j = 0; j < [superKeys count]; j++)
                            {
                                NSString *superKey = [superKeys objectAtIndex:j];
                                if (![def objectForKey:superKey])
                                {
                                    [def setObject:[superDef objectForKey:superKey] forKey:superKey];
                                }
                            }
                        }
                    }
                }
            }
            
        }
        NSString *fontExchangeSettingsContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FontExchange" ofType:@"json"] encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"Couldn't load FontExchange.json file! WTF!");
            self.fontExchange = nil;
        }
        else
        {
            self.fontExchange = [ fontExchangeSettingsContent JSONValue ];
        }
        return self;
    }
    return nil;
}

- (void) processAllXibs
{
    xibResources = [ [ NSMutableDictionary alloc ] init ];
    
    NSArray* onlyProcessXibs = [ XcodeProjectHelper getProcessOnlyXibs ];
    NSArray* skipXibs = [ XcodeProjectHelper getSkipXibs ];
    
    NSError *error = nil;
    NSString *rootFolder = [[[NSBundle mainBundle] pathForResource:@"XibFinder" ofType:@"txt"] stringByDeletingLastPathComponent];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootFolder error:&error];
    
    if (error)
    {
        NSLog(@"Error reading xibs! %@",error);
    }
    else
    {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.nib'"];
        NSArray *xibs = [dirContents filteredArrayUsingPredicate:filter];
        
        for (int i = 0; i < [xibs count]; i++)
        {
            NSString *xibName = [[[xibs objectAtIndex:i] lastPathComponent] stringByDeletingPathExtension];
            
            if ( [ onlyProcessXibs count ] > 0 )
            {
                if ( [ onlyProcessXibs containsString:xibName ] )
                {
                    [ self processXib:xibName ];
                }
            } else
            {
                if ( ![ skipXibs containsString:xibName ] )
                {
                    [ self processXib:xibName ];
                } else
                {
                    NSLog( @"Skipping %@", xibName );
                }
            }
        }
    }
}

+( NSString* )getPathOfFile:( NSString* )findFileName start:( NSString* )start
{
    NSFileManager* fileManager = [ NSFileManager defaultManager ];

    NSError* error = nil;
    
    NSArray* filesAndDirectoriesKeys = [ NSArray arrayWithObjects:NSURLIsRegularFileKey, NSURLIsDirectoryKey, nil ];
//    NSArray* onlyFilesKeys = [ NSArray arrayWithObject:NSURLIsRegularFileKey ];
//    NSArray* files = [ fileManager contentsOfDirectoryAtURL:[ NSURL URLWithString:start ] includingPropertiesForKeys:onlyFilesKeys options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error ];

    if ( error )
    {
        NSLog( @"Error in ViewExporter::getPathOfFile, could not get contents of URL at %@", start );
        return nil;
    }
    
//    NSArray* onlyDirectoriesKeys = [ NSArray arrayWithObject:NSURLIsDirectoryKey ];

    NSDirectoryEnumerator* enumerator = [ fileManager
                                         enumeratorAtURL:[ NSURL URLWithString:start ]
                                         includingPropertiesForKeys:filesAndDirectoriesKeys
                                         options:0
                                         errorHandler:^( NSURL *url, NSError *error ) {
                                             NSLog( @"Error in directory enumerator: %@", error );
                                             return YES;
                                         }];
    
    for ( NSURL* url in enumerator )
    {
        error = nil;
        NSDictionary* attributes = [ fileManager attributesOfItemAtPath:[ url path ] error:&error ];
        if ( error )
        {
            NSLog( @"Error in ViewExporter::getPathOfFile, could not get attributes of URL at %@", url );
            continue;
        }
        
        if ( [ [ attributes fileType ] isEqualToString:NSFileTypeRegular ] )
        {
            NSArray* pathComponents = [ url pathComponents ];
            if ( [ pathComponents count ] >= 1 )
            {
                NSString* enumeratedFileName = [ NSString stringWithFormat:@"%@", [ pathComponents objectAtIndex:[ pathComponents count ] - 1 ] ];
                if ( [ enumeratedFileName isEqualToString:findFileName ] )
                {
                    return [ url path ];
                }
            }
        }
    }
    
    NSLog( @"Unable to find %@ within %@, file was either incorrectly removed, a reference to it remains in viewChanges.txt when it was removed, or your .app needs to be cleaned", findFileName, start );
    return nil;
}

+( CXMLElement* )getXibUIViewRootForDocument:( CXMLDocument* )document
{
    CXMLElement* result = nil;
    
    NSError* error = nil;
    
    NSArray* dataArrayObjects = [ document nodesForXPath:@"/archive/data/array" error:&error ];
    if ( error )
    {
        NSLog( @"Error trying to find root node: %@", error );
    } else
    {
        for ( CXMLNode* dataArrayNode in dataArrayObjects )
        {
            if ( [ dataArrayNode kind ] == CXMLElementKind )
            {
                CXMLElement* dataArrayElement = ( CXMLElement* )dataArrayNode;
                if ( [ [ dataArrayElement attributeKeyStringValue ] isEqualToString:@"IBDocument.RootObjects" ] )
                {
                    NSArray* rootArrayObjects = [ dataArrayElement children ];
                    for ( CXMLNode* rootArrayNode in rootArrayObjects )
                    {
                        if ( [ rootArrayNode kind ] == CXMLElementKind )
                        {
                            CXMLElement* rootArrayElement = ( CXMLElement* )rootArrayNode;
                            if ( [ [ rootArrayElement attributeClassStringValue ] isEqualToString:@"IBUIView" ] )
                            {
                                result = rootArrayElement;
                                break;
                            }
                        }
                    }
                    if ( result )
                    {
                        break;
                    }
                }
            }
        }
    }
    return result;
}

+( CXMLElement* )getXibUIViewRoot:( NSString* )xibName
{
    CXMLElement* result = nil;
    
    NSString* xibPath = [ ViewExporter getPathOfFile:[ NSString stringWithFormat:@"%@.xib", xibName ] start:[ XcodeProjectHelper getXIBRoot ] ];
    if ( xibPath )
    {
        NSData* xmlData = [ NSData dataWithContentsOfFile:xibPath ];
        result = [ ViewExporter getXibUIViewRootForDocument:[ [ [ CXMLDocument alloc ] initWithData:xmlData options:0 error:nil ] autorelease ] ];
    }
    return result;
}

-( void )addXibResource:( CXMLElement* )element
{
    if ( [ element attributeIdStringValue ] )
    {
        [ xibResources setObject:element forKey:[ element attributeIdStringValue ] ];
    }
}

-( CXMLElement* )getXibResource:( NSString* )referenceId
{
    return [ xibResources objectForKey:referenceId ];
}

- (void) processXib:(NSString *)xibName
{
    _uiViewCustomMemberDictionary = [ [ NSMutableDictionary alloc ] init ];
    [ xibResources removeAllObjects ];

    //NSLog( @"Processing xib %@", xibName );
    UIViewController *vc = [[UIViewController alloc] initWithNibName:xibName bundle:[NSBundle mainBundle]];
    if (vc)
    {
        CXMLElement* xibRoot = [ ViewExporter getXibUIViewRoot:xibName ];
        NSDictionary *d = [vc exportToDictionary:xibRoot xibName:xibName ];
        if (d)
        {
            [self.exportedData setObject:d forKey:xibName];
        }
    }
}

- (NSArray *) exportDataTo:(NSString *)location atomically:(BOOL)flag format:(ViewExporterFormat)format error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified
{
    //NSString *exportFolder = [[location stringByDeletingLastPathComponent] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    //NSLog(@"open %@",exportFolder);
    switch (format)
    {
        case ViewExporterFormatJSON:
            location = [NSString stringWithFormat:@"%@.json",[location stringByDeletingPathExtension]];
            [[self.exportedData JSONRepresentation] writeToFile:location atomically:flag encoding:NSUTF8StringEncoding error:error];
            break;
        case ViewExporterFormatPlist:
            location = [NSString stringWithFormat:@"%@.plist",[location stringByDeletingPathExtension]];
            [self.exportedData writeToFile:location atomically:flag];
            break;
        case ViewExporterFormatXML:
            location = [NSString stringWithFormat:@"%@.xml",[location stringByDeletingPathExtension]];
            [self exportXMLTo:location atomically:flag error:error];
            break;
        case ViewExporterFormatOpenFramework:
            location = [NSString stringWithFormat:@"%@.h",[location stringByDeletingPathExtension]];
            return [self exportCodeTo:mult ? [location stringByDeletingLastPathComponent] : location atomically:flag error:error saveMultipleFiles:mult useOnlyModifiedFiles:onlyModified];
            break;
    }
    return [NSArray arrayWithObject:location];
}

- (NSArray *) exportDataToProject:(BOOL)useProjectDir atomically:(BOOL)flag format:(ViewExporterFormat)format error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified
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
    
    return [self exportDataTo:targetFile atomically:flag format:format error:error saveMultipleFiles:mult useOnlyModifiedFiles:onlyModified];
}

-( NSString* )exchangeFont:( NSString* )fontName
{
    NSString* exchanged = [ self.fontExchange objectForKey:fontName ];
    if ( exchanged )
    {
        return exchanged;
    }
    return fontName;
}

@end
