//
//  SettingViewController.h
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSString *profileName;
@property (weak, nonatomic) IBOutlet UIView *menuView;

- (void)addBlurView;

@end
