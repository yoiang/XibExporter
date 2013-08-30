//
//  CodeExporter.h
//  XibExporter
//
//  Called by the ViewExporter class to generate code for new xibs.
//  An XIB where the root view's accessibilityHint is __AUTOGENERATE
//  will create however many files are specified in the CodeDefinitions.
//
//  Created by Eli Delventhal on 7/10/12.
//

@interface CodeExporter : NSObject

+ (CodeExporter *) sharedInstance;

- ( NSArray * ) exportCodeForDict:(NSDictionary *)dict def:(NSDictionary *)def properties:(NSDictionary *)properties;

- ( NSString * ) translateCodeString:(NSString *)classFile dict:(NSDictionary *)dict withDef:(NSDictionary *)def properties:(NSDictionary *)properties;
- ( NSString * ) translateSingleObjectCodeString:(NSString *)codeString dict:(NSDictionary *)dict withDef:(NSDictionary *)def properties:(NSDictionary *)properties;

@end