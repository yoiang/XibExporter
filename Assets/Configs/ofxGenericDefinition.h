inline ofRectangle getGenerated@Frame()
{
    return ofRectangle(∂frame.x∂, ∂frame.y∂, ∂frame.width∂, ∂frame.height∂);
}

inline void populateGenerated@( ofPtr< ofxGenericView > rootViewﬁ )
{ƒ}

inline void populatePreserveGenerated@( ofPtr< ofxGenericView > rootView, bool preserveTopLeft, bool preserveSizeﬁ )
{
    ofRectangle preservedFrame = rootView->getFrame();

    populateGenerated@( rootView∞ );
    ofRectangle generatedFrame = getGenerated@Frame();
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

inline ofPtr< ofxGenericView > constructGenerated@( % )
{
    ofPtr< ofxGenericView > rootView = ofxGenericView::create();
    populateGenerated@( rootView∞ );
    return rootView;
}