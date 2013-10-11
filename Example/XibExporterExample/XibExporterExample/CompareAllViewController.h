//
//  CompareAllViewController.h
//  XibExporterExample
//
//  Created by Ian on 10/11/13.
//
//

#import <UIKit/UIKit.h>

#import "CompareExportViewController.h"

@interface CompareAllViewController : UIViewController< CompareExportViewControllerDelegate >

+(NSDictionary*)dictionaryForComparingNibName:(NSString*)nibName inBundle:(NSBundle*)bundle withView:(UIView*)view;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil compareList:(NSArray *)compare;

@end
