//
//  CompareExportViewController.m
//  XibExporterExample
//
//  Created by Ian on 10/11/13.
//
//

#import "CompareExportViewController.h"

@interface CompareExportViewController ()

@property (nonatomic, strong) IBOutlet UIView* prompt;
@property (nonatomic, strong) IBOutlet UIView* overlay;
@property (nonatomic, strong) IBOutlet UILabel* compareName;

@property (nonatomic, strong) UIView* xibView;
@property (nonatomic, strong) UIView* programaticView;

@property (nonatomic, weak) id<CompareExportViewControllerDelegate> delegate;

@end

@implementation CompareExportViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andProgramaticView:(UIView *)programaticView
{
    self = [self initWithNibName:@"ComparePromptView" bundle:[NSBundle mainBundle] ];
    if (self)
    {
        UIViewController* xibViewController = [ [UIViewController alloc] initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        
        self.xibView = xibViewController.view;
        self.programaticView = programaticView;
        
        [self.view insertSubview:self.xibView belowSubview:self.overlay];
        [self.view insertSubview:self.programaticView belowSubview:self.overlay];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCompareExportViewControllerDelegate:(id<CompareExportViewControllerDelegate>)delegate
{
    self.delegate = delegate;
}

-(IBAction)toggleViews:(id)sender
{
    BOOL hideProgramatic = ![self.programaticView isHidden];
    [self.xibView setHidden:!hideProgramatic];
    [self.programaticView setHidden:hideProgramatic];
    if (hideProgramatic)
    {
        self.compareName.text = @"Xib";
    } else
    {
        self.compareName.text = @"Exported";
    }
}

-(IBAction)finished:(id)sender
{
    [self.delegate compareExportViewControllerFinished];
}

@end
