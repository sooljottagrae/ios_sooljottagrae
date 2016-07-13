//
//  SettingViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "SettingViewController.h"
#import "EditMyTagsViewController.h"

@interface SettingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;



@end

@implementation SettingViewController

- (void) viewWillAppear:(BOOL)animated {
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.view.bounds;
    //[self.view addSubview:visualEffectView];
    
    [self.parentViewController.view addSubview:visualEffectView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    UIImage *profileImage = [UIImage imageNamed:@"Profile1"];
    self.profileImageView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.profileImageView.layer.borderWidth = 2.0;
    //self.view.frame.size.width*0.105
    
    //NSLog(@"%lf", self.profileImageView.frame.size.height/2);
    self.profileImageView.layer.masksToBounds = YES;
    [self.profileImageView setImage:profileImage];
    
    [self.profileNameLabel setText:[NSString stringWithFormat:@"%@ 님",self.profileName]];
    
    // 화면이 돌아갔을 때, notification
    // selector에 화면이 돌아갈 때 하고 싶은 메소드를 구현
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}


- (void) orientationChanged {
//    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2;
    //NSLog(@"size.width %f", self.profileImageView.frame.size.width);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2;
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

- (IBAction)editTagsBtn:(id)sender {
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
    EditMyTagsViewController *editMyTagsVC = [stb instantiateViewControllerWithIdentifier:@"EditMyTagsViewController"];
    
    [self presentViewController:editMyTagsVC animated:YES completion:nil];
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
