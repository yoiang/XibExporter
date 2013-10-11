//
//  CompareExportViewController.h
//  XibExporterExample
//
//  Created by Ian on 10/11/13.
//
//

#import <UIKit/UIKit.h>

@protocol CompareExportViewControllerDelegate;

@interface CompareExportViewController : UIViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProgramaticView:(UIView *)view;
-(void)setCompareExportViewControllerDelegate:(id<CompareExportViewControllerDelegate>) delegate;

@end

@protocol CompareExportViewControllerDelegate <NSObject>

-(void)compareExportViewControllerFinished;

@end