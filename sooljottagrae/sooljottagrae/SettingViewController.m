//
//  SettingViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;



@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    [visualEffectView setFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height)];
    
    [self.view insertSubview:visualEffectView atIndex:0];
    
    //[self setModalPresentationStyle:UIModalPresentationCurrentContext];
    
    
    UIImage *profileImage = [UIImage imageNamed:@"Profile1"];
    [self.profileImageView setImage:profileImage];
    
    [self.profileNameLabel setText:[NSString stringWithFormat:@"%@ 님",self.profileName]];
    
}

- (IBAction)editProfileImageBtn:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)logOUtBtn:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
