//
//  MainViewController.h
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, weak) IBOutlet UIView *placeholderView;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *tabBarButtons;

@end
