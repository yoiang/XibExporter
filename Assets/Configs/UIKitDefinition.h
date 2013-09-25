inline CGRect getGenerated@Frame()
{
    return CGRectMake(∂frame.x∂, ∂frame.y∂, ∂frame.width∂, ∂frame.height∂);
}

inline void populateGenerated@( UIView** rootViewﬁ )
{ƒ}

inline void populatePreserveGenerated@( UIView** rootView, bool preserveTopLeft, bool preserveSizeﬁ )
{
    CGRect preservedFrame = [ (*rootView) frame];

    populateGenerated@( rootView∞ );
    CGRect generatedFrame = getGenerated@Frame();
    if ( !preserveTopLeft )
    {
    preservedFrame = CGRectMake( 
                        generatedFrame.origin.x,
                        generatedFrame.origin.y,
                        preservedFrame.size.width,
                        preservedFrame.size.height
                        );
    }

    if ( !preserveSize )
    {
    preservedFrame = CGRectMake( 
                        preservedFrame.origin.x,
                        preservedFrame.origin.y,
                        generatedFrame.size.width,
                        generatedFrame.size.height
                        );
    }
    if ( preserveTopLeft || preserveSize )
    {
        [ (*rootView) setFrame:preservedFrame];
    }
}

inline UIView* constructGenerated@( % )
{
    UIView* rootView = [ [UIView alloc] init];
    populateGenerated@( &rootView∞ );
    return rootView;
}