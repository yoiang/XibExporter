//
//  XibUpdateStatus.m
//  XibExporter
//
//  Created by Ian on 9/26/13.
//
//

#import "XibUpdateStatus.h"

#import "AppSettings.h"

@interface XibUpdateStatus()

@property (nonatomic, strong) NSMutableDictionary *previousStatus;
@property (nonatomic, strong) NSMutableDictionary *currentStatus;

@end

@implementation XibUpdateStatus

-(id)init
{
    self = [super init];
    if (self)
    {
        [self initPreviousStatus];
    }
    return self;
}

-(NSString*)getStatusFilePath
{
    return [AppSettings getFolderContainingXibsToProcess];
}

-(NSString*)getStatusFileName
{
    return @"XibExporter.viewMD5s.txt";
}

-(NSString*)getStatusFileNamePath
{
    return [NSString stringWithFormat:@"%@/%@", [self getStatusFilePath], [self getStatusFileName] ];
}

-(void)initPreviousStatus
{
    NSError *error = nil;
    NSString *previousStatusFile = [NSString stringWithContentsOfFile:[self getStatusFileNamePath] encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        NSLog(@"Error attempting to read previous Xib Update Status file %@: %@", [self getStatusFileNamePath], error);
    }
    
    NSArray *previouslyProcessedXibs = [previousStatusFile componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"] ];
    for (NSString *xibAndMD5 in previouslyProcessedXibs)
    {
        NSArray *xibInfo = [xibAndMD5 componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="] ];
        if ( [xibInfo count] == 2)
        {
            [self addXibToPrevious:[xibInfo objectAtIndex:0] withMD5:[xibInfo objectAtIndex:1] ];
        }
    }
}

-(void)addXib:(NSString*)xibName withMD5:(NSString*)md5 toDictionary:(NSMutableDictionary*)dictionary
{
    [dictionary setObject:md5 forKey:xibName];
}

-(void)addXibToPrevious:(NSString *)xibName withMD5:(NSString *)md5
{
    if (!self.previousStatus)
    {
        self.previousStatus = [NSMutableDictionary dictionary];
    }
    [self addXib:xibName withMD5:md5 toDictionary:self.previousStatus];
}

-(void)addXibToCurrent:(NSString *)xibName withMD5:(NSString*)md5
{
    if (!self.currentStatus)
    {
        self.currentStatus = [NSMutableDictionary dictionary];
    }
    [self addXib:xibName withMD5:md5 toDictionary:self.currentStatus];
}

-(void)updateXib:(NSString*)xibName withMD5:(NSString*)md5
{
    NSString* previousMD5 = [self getXibMD5:xibName fromDictionary:self.previousStatus];
    if (!previousMD5 || ![previousMD5 isEqualToString:md5])
    {
        [self addXibToCurrent:xibName withMD5:md5];
    }
}

-(NSString*)getXibMD5:(NSString*)xibName fromDictionary:(NSDictionary*)dictionary
{
    return [dictionary objectForKey:xibName];
}

-(BOOL)hasXibChanged:(NSString*)xibName
{
    return [self getXibMD5:xibName fromDictionary:self.currentStatus] != nil;
}

-(void)saveCurrentStatus
{
    NSMutableDictionary* squishedDictionary = [NSMutableDictionary dictionary];
    
    [squishedDictionary setValuesForKeysWithDictionary:self.previousStatus];
    [squishedDictionary setValuesForKeysWithDictionary:self.currentStatus];
    
    NSMutableString *fileContents = [NSMutableString string];
    for (NSString* xibName in [squishedDictionary allKeys] )
    {
        NSString* md5 = [squishedDictionary objectForKey:xibName];
        if (md5)
        {
            if ( [fileContents length] > 0)
            {
                [fileContents appendString:@"\n"];
            }
            [fileContents appendFormat:@"%@=%@", xibName, md5];
        }
    }
    
    NSError* error = nil;
    [fileContents writeToFile:[self getStatusFileNamePath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        NSLog(@"Error attempting to write previous Xib Update Status file %@: %@", [self getStatusFileNamePath], error);
    }

    self.previousStatus = squishedDictionary;
    self.currentStatus = nil;
    
/*    for (NSString* xibName in [self.previousStatus allKeys])
    {
        [squishedDictionary setObject:[self.previousStatus objectForKey:xibName] forKey:xibName];
    }

    for (NSString* xibName in [self.currentStatus allKeys])
    {
        [squishedDictionary setObject:[self.currentStatus objectForKey:xibName] forKey:xibName];
    }
 */
}

@end
