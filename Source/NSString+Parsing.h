//
//  NSString+Parsing.h
//  XibExporter
//
//  Created by Eli Delventhal on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface NSString (Parsing)

- (NSString *) stringByParsingSandwiches:(NSString *)sandwichString parseObject:(id)object parseSelector:(SEL)selector userData:(id)userData;

-(NSString*)substringBetweenOccurancesOf:(NSString*)find;

@end
