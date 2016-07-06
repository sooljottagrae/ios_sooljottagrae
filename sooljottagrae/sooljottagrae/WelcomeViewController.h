//
//  WelcomeViewController.h
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *profileNameLabel;
@property (nonatomic, strong) NSString *profileNmae;

@end
