//
//  FontExchange.m
//  XibExporter
//
//  Created by Ian on 9/13/13.
//
//

#import "FontExchange.h"

#import "SBJson.h"

static FontExchange *sharedInstance;

@interface FontExchange()
@property (strong) NSDictionary *fontExchangeList;
@end

@implementation FontExchange

+(FontExchange*)sharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [ [FontExchange alloc] init];
    }
    
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        NSError *error = nil;

        NSString *fontExchangeSettingsContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FontExchange" ofType:@"json"] encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            NSLog(@"Couldn't load FontExchange.json file!");
            self.fontExchangeList = nil;
        }
        else
        {
            self.fontExchangeList = [ fontExchangeSettingsContent JSONValue ];
        }

    }
    return self;
}

-( NSString* )exchangeFont:( NSString* )fontName
{
    NSString* exchanged = [ self.fontExchangeList objectForKey:fontName ];
    if ( exchanged )
    {
        return exchanged;
    }
    return fontName;
}

@end
