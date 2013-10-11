//
//  UIView_Xcode4.m
//  XibExporterExample
//
//  Created by Ian on 10/11/13.
//
//

#import "UIView_Xcode4.h"

#import "GeneratedViewTemplates_Xcode4.UIKit.h"

@interface UIView_Xcode4()

@end

@implementation UIView_Xcode4

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UILabel* variableNameLabel;
        UIButton* variableNameButton1;
        UIButton* variableNameButton2;
        UIImageView* variableNameImage;
        UIView* variableNameView;
        UILabel* variableNameLabel2;
        
        populateGeneratedViewTemplates_Xcode4(
                                              &self,
                                              &variableNameLabel,
                                              &variableNameButton1,
                                              &variableNameButton2,
                                              &variableNameImage,
                                              &variableNameView,
                                              &variableNameLabel2
                                              );
        self.variableNameLabel = variableNameLabel;
        self.variableNameButton1 = variableNameButton1;
        self.variableNameButton2 = variableNameButton2;
        self.variableNameImage = variableNameImage;
        self.variableNameView = variableNameView;
        self.variableNameLabel2 = variableNameLabel2;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
