////////////////////AUTOGENERATED XIB EXPORTED CODE - DO NOT ALTER////////////////////
//
// Exported from ViewTemplates_Xcode5.xib
//

#pragma once

#include "ofxGenericView.h"
#include "ofxGenericUtility.h"
#include "ofxGenericTextView.h"
#include "ofxGenericLocalization.h"
#include "ofxGenericButtonView.h"
#include "ofxGenericImageView.h"


inline ofRectangle getGeneratedViewTemplates_Xcode5Frame()
{
    return ofRectangle(0.0f, 0.0f, 320.0f, 568.0f);
}

inline void populateGeneratedViewTemplates_Xcode5( ofPtr< ofxGenericView > rootView, ofPtr< ofxGenericTextView > &variableNameLabel, ofPtr< ofxGenericButtonView > &variableNameButton1, ofPtr< ofxGenericButtonView > &variableNameButton2, ofPtr< ofxGenericImageView > &variableNameImage, ofPtr< ofxGenericView > &variableNameView, ofPtr< ofxGenericTextView > &variableNameLabel2 )
{
	rootView->setContentMode( ofxGenericContentModeScaleToFill );
	rootView->setVisible( true );
	rootView->setFrame( ofRectangle( 0.0f, 0.0f, 320.0f, 568.0f ) );
	rootView->setBackgroundColor( ofColor( 255, 255, 255, 255 ) );
	rootView->setAutoresizingMask( ofxGenericViewAutoresizingFlexibleWidth | ofxGenericViewAutoresizingFlexibleHeight );
	rootView->setAlpha( 1.0f );
	rootView->setClipSubviews( false );

	variableNameLabel = ofxGenericTextView::create( );
	variableNameLabel->setClipSubviews( true );
	variableNameLabel->setVisible( true );
	variableNameLabel->setFrame( ofRectangle( 20.0f, 20.0f, 280.0f, 21.0f ) );
	variableNameLabel->setAlpha( 1.0f );
	variableNameLabel->setTextColor( ofColor( 0, 0, 0, 255 ) );
	variableNameLabel->setText( ofxGLocalized( "LabelTextLocalizationKey", "Label" ) );
	variableNameLabel->setFont( ".HelveticaNeueInterface-M3", variableNameLabel->getFontSize() );
	variableNameLabel->setBackgroundColor( ofColor( 209, 255, 201, 255 ) );
	variableNameLabel->setLineBreakMode( ofxGenericTextLinebreakModeTailTruncation );
	variableNameLabel->setTextAlignment( ofxGenericTextHorizontalAlignmentCenter );
	variableNameLabel->setFont( variableNameLabel->getFontName(), 17.0f );
	variableNameLabel->setContentMode( ofxGenericContentModeLeft );
	variableNameLabel->setNumberOfLines( 1 );
	variableNameLabel->setAutosizeFontToFitText( false );
	variableNameLabel->setAutoresizingMask( ofxGenericViewAutoresizingRightMargin | ofxGenericViewAutoresizingBottomMargin );
	rootView->addChildView( variableNameLabel );

	variableNameButton1 = ofxGenericButtonView::create( ofxGenericButtonTypeRoundedRect );
	variableNameButton1->setVisible( true );
	variableNameButton1->setFrame( ofRectangle( 124.0f, 49.0f, 73.0f, 29.0f ) );
	variableNameButton1->setAlpha( 1.0f );
	variableNameButton1->setDownTextColor( ofColor( 0, 122, 255, 255 ) );
	variableNameButton1->setFont( ".HelveticaNeueInterface-M3", variableNameButton1->getFontSize() );
	variableNameButton1->setText( ofxGLocalized( "ButtonTitleLocalizationKey", "Button" ) );
	variableNameButton1->setNumberOfLines( 1 );
	variableNameButton1->setFont( variableNameButton1->getFontName(), 15.0f );
	variableNameButton1->setEnabled( true );
	variableNameButton1->setDownBackgroundImage( "backgroundImageDown.png" );
	variableNameButton1->setLineBreakMode( ofxGenericTextLinebreakModeMiddleTruncation );
	variableNameButton1->setTextColor( ofColor( 0, 122, 255, 255 ) );
	variableNameButton1->setTextAlignment( ofxGenericTextHorizontalAlignmentLeft );
	variableNameButton1->setBackgroundColor( ofColor( 246, 188, 255, 255 ) );
	variableNameButton1->setDelegate( dynamic_pointer_cast< ofxGenericButtonViewDelegate >( rootView ) );
	variableNameButton1->setContentMode( ofxGenericContentModeScaleToFill );
	variableNameButton1->setClipSubviews( false );
	variableNameButton1->setAutoresizingMask( ofxGenericViewAutoresizingRightMargin | ofxGenericViewAutoresizingBottomMargin );
	rootView->addChildView( variableNameButton1 );

	variableNameButton2 = ofxGenericButtonView::create( ofxGenericButtonTypeRoundedRect );
	variableNameButton2->setVisible( true );
	variableNameButton2->setFrame( ofRectangle( 124.0f, 85.0f, 73.0f, 62.0f ) );
	variableNameButton2->setAlpha( 1.0f );
	variableNameButton2->setDownTextColor( ofColor( 0, 122, 255, 255 ) );
	variableNameButton2->setFont( ".HelveticaNeueInterface-M3", variableNameButton2->getFontSize() );
	variableNameButton2->setText( ofxGLocalized( "ButtonTitleLocalizationKey", "Button with Image" ) );
	variableNameButton2->setNumberOfLines( 1 );
	variableNameButton2->setBackgroundImage( "Icon.png" );
	variableNameButton2->setFont( variableNameButton2->getFontName(), 15.0f );
	variableNameButton2->setEnabled( true );
	variableNameButton2->setDownBackgroundImage( "backgroundImageDown.png" );
	variableNameButton2->setLineBreakMode( ofxGenericTextLinebreakModeMiddleTruncation );
	variableNameButton2->setTextColor( ofColor( 0, 122, 255, 255 ) );
	variableNameButton2->setTextAlignment( ofxGenericTextHorizontalAlignmentLeft );
	variableNameButton2->setBackgroundColor( ofColor( 251, 255, 190, 255 ) );
	variableNameButton2->setDelegate( dynamic_pointer_cast< ofxGenericButtonViewDelegate >( rootView ) );
	variableNameButton2->setContentMode( ofxGenericContentModeScaleToFill );
	variableNameButton2->setClipSubviews( false );
	variableNameButton2->setAutoresizingMask( ofxGenericViewAutoresizingRightMargin | ofxGenericViewAutoresizingBottomMargin );
	rootView->addChildView( variableNameButton2 );

	variableNameImage = ofxGenericImageView::create(  );
	variableNameImage->setClipSubviews( false );
	variableNameImage->setVisible( true );
	variableNameImage->setFrame( ofRectangle( 96.0f, 155.0f, 128.0f, 128.0f ) );
	variableNameImage->setBackgroundColor( ofColor( 0, 0, 0, 0 ) );
	variableNameImage->setImage( "Icon.png" );
	variableNameImage->setContentMode( ofxGenericContentModeScaleToFill );
	variableNameImage->setAutoresizingMask( ofxGenericViewAutoresizingRightMargin | ofxGenericViewAutoresizingBottomMargin );
	variableNameImage->setAlpha( 1.0f );
	rootView->addChildView( variableNameImage );

	variableNameView = ofxGenericView::create( );
	variableNameView->setContentMode( ofxGenericContentModeScaleToFill );
	variableNameView->setVisible( true );
	variableNameView->setFrame( ofRectangle( 20.0f, 291.0f, 280.0f, 72.0f ) );
	variableNameView->setBackgroundColor( ofColor( 216, 204, 255, 255 ) );
	variableNameView->setAutoresizingMask( ofxGenericViewAutoresizingRightMargin | ofxGenericViewAutoresizingBottomMargin );
	variableNameView->setAlpha( 1.0f );
	variableNameView->setClipSubviews( false );

	variableNameLabel2 = ofxGenericTextView::create( );
	variableNameLabel2->setClipSubviews( true );
	variableNameLabel2->setVisible( true );
	variableNameLabel2->setFrame( ofRectangle( 0.0f, 26.0f, 280.0f, 21.0f ) );
	variableNameLabel2->setAlpha( 1.0f );
	variableNameLabel2->setTextColor( ofColor( 0, 0, 0, 255 ) );
	variableNameLabel2->setText( ofxGLocalized( "LabelTextLocalizationKey", "Label within View" ) );
	variableNameLabel2->setFont( ".HelveticaNeueInterface-M3", variableNameLabel2->getFontSize() );
	variableNameLabel2->setBackgroundColor( ofColor( 209, 255, 201, 255 ) );
	variableNameLabel2->setLineBreakMode( ofxGenericTextLinebreakModeTailTruncation );
	variableNameLabel2->setTextAlignment( ofxGenericTextHorizontalAlignmentCenter );
	variableNameLabel2->setFont( variableNameLabel2->getFontName(), 17.0f );
	variableNameLabel2->setContentMode( ofxGenericContentModeLeft );
	variableNameLabel2->setNumberOfLines( 1 );
	variableNameLabel2->setAutosizeFontToFitText( false );
	variableNameLabel2->setAutoresizingMask( ofxGenericViewAutoresizingRightMargin | ofxGenericViewAutoresizingBottomMargin );
	variableNameView->addChildView( variableNameLabel2 );
	rootView->addChildView( variableNameView );
}

inline void populatePreserveGeneratedViewTemplates_Xcode5( ofPtr< ofxGenericView > rootView, bool preserveTopLeft, bool preserveSize, ofPtr< ofxGenericTextView > &variableNameLabel, ofPtr< ofxGenericButtonView > &variableNameButton1, ofPtr< ofxGenericButtonView > &variableNameButton2, ofPtr< ofxGenericImageView > &variableNameImage, ofPtr< ofxGenericView > &variableNameView, ofPtr< ofxGenericTextView > &variableNameLabel2 )
{
    ofRectangle preservedFrame = rootView->getFrame();

    populateGeneratedViewTemplates_Xcode5( rootView, variableNameLabel, variableNameButton1, variableNameButton2, variableNameImage, variableNameView, variableNameLabel2 );
    ofRectangle generatedFrame = getGeneratedViewTemplates_Xcode5Frame();
    if ( !preserveTopLeft )
    {
        preservedFrame.x = generatedFrame.x;
        preservedFrame.y = generatedFrame.y;
    }

    if ( !preserveSize )
    {
        preservedFrame.width = generatedFrame.width;
        preservedFrame.height = generatedFrame.height;
    }
    if ( preserveTopLeft || preserveSize )
    {
        rootView->setFrame( preservedFrame );
    }
}

inline ofPtr< ofxGenericView > constructGeneratedViewTemplates_Xcode5( ofPtr< ofxGenericTextView > &variableNameLabel, ofPtr< ofxGenericButtonView > &variableNameButton1, ofPtr< ofxGenericButtonView > &variableNameButton2, ofPtr< ofxGenericImageView > &variableNameImage, ofPtr< ofxGenericView > &variableNameView, ofPtr< ofxGenericTextView > &variableNameLabel2 )
{
    ofPtr< ofxGenericView > rootView = ofxGenericView::create();
    populateGeneratedViewTemplates_Xcode5( rootView, variableNameLabel, variableNameButton1, variableNameButton2, variableNameImage, variableNameView, variableNameLabel2 );
    return rootView;
}
