//
//  CompareAllViewController.m
//  XibExporterExample
//
//  Created by Ian on 10/11/13.
//
//

#import "CompareAllViewController.h"

#define NibNameKey @"Nib"
#define NibBundleKey @"Nib Bundle"
#define ExportedKey @"Exported"

@implementation NSDictionary (CompareAllViewController)

-(NSString*)nibName
{
    return [self objectForKey:NibNameKey];
}

-(NSBundle*)nibBundle
{
    return [self objectForKey:NibBundleKey];
}

-(UIView*)exported
{
    return [self objectForKey:ExportedKey];
}

@end

@interface CompareAllViewController ()
{
    NSUInteger compareIndex;
}

@property (nonatomic, strong) NSArray* compare;
@property (nonatomic, strong) CompareExportViewController* currentCompareViewController;

@end

@implementation CompareAllViewController

+(NSDictionary*)dictionaryForComparingNibName:(NSString*)nibName inBundle:(NSBundle*)bundle withView:(UIView*)view
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    [result setObject:nibName forKey:NibNameKey];
    [result setObject:bundle forKey:NibBundleKey];
    [result setObject:view forKey:ExportedKey];
    return result;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil compareList:(NSArray *)compare
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.compare = compare;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    compareIndex = 0;
    if ( ![self showCompareExportViewControllerAtIndex:compareIndex] )
    {
        NSLog(@"Error: no items found for comparing!");
        exit(0);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)showCompareExportViewControllerAtIndex:(NSUInteger)index
{
    [self.currentCompareViewController.view removeFromSuperview];
    [self.currentCompareViewController removeFromParentViewController];
    
    BOOL result = NO;
    if ( [self.compare count] > index )
    {
        NSDictionary* compareInfo = [self.compare objectAtIndex:index];
        CompareExportViewController* compareViewController = [ [CompareExportViewController alloc] initWithNibName:compareInfo.nibName bundle:compareInfo.nibBundle andProgramaticView:compareInfo.exported];
        
        if (compareViewController)
        {
            self.currentCompareViewController = compareViewController;
            [self.currentCompareViewController setCompareExportViewControllerDelegate:self];
            [self addChildViewController:self.currentCompareViewController];
            
            [self.view addSubview:self.currentCompareViewController.view];
            result = YES;
        } else
        {
            result = NO;
        }
    } else
    {
        result = NO;
    }
    
    return result;
}

-(void)compareExportViewControllerFinished
{
    compareIndex ++;
    if ( ![self showCompareExportViewControllerAtIndex:compareIndex] )
    {
        exit(0);
    }
}

@end
