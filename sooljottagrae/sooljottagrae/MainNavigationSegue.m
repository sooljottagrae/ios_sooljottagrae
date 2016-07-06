//
//  MainNavigationSegue.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "MainNavigationSegue.h"
#import "MainViewController.h"

@implementation MainNavigationSegue

-(void) perform{
    MainViewController *mainVC = (MainViewController *)self.sourceViewController;
    UIViewController *destinationController = (UIViewController *)self.destinationViewController;
    
    for (UIView *view in mainVC.placeholderView.subviews)
    {
        [view removeFromSuperview];
    }
    
    // Add view to placeholder view
    mainVC.currentViewController = destinationController;
    [mainVC.placeholderView addSubview: destinationController.view];
    
    // Set autoresizing
    [mainVC.placeholderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIView *childview = destinationController.view;
    [childview setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    // fill horizontal
    [mainVC.placeholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"H:|[childview]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(childview)]];
    
    // fill vertical
    [mainVC.placeholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[childview]-0-|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(childview)]];
    
    [mainVC.placeholderView layoutIfNeeded];
    
    // notify did move
    [destinationController didMoveToParentViewController: mainVC];

}


@end
