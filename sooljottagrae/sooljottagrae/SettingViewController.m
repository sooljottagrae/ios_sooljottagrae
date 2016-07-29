//
//  SettingViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "SettingViewController.h"
#import "EditMyTagsViewController.h"
#import "AppInfoViewController.h"
#import "UserObject.h"
#import "RequestObject.h"
#import <SDWebImage/UIImageView+WebCache.h>

@import ImageIO;
@import AssetsLibrary;

@interface SettingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *tapActionView;

@property (strong, nonatomic) NSString *fileName;


@end

@implementation SettingViewController

- (void) viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.parentViewController.view.bounds;
    //[self.view addSubview:visualEffectView];
    
    [self.view insertSubview:visualEffectView belowSubview:self.menuView];
    
    self.menuView.frame = CGRectMake(-self.view.frame.size.width*0.35, 0, self.view.frame.size.width*0.35, self.view.frame.size.height);

    
    [UIView animateWithDuration:0.3
     
                     animations:^ {
                         //settingVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         self.menuView.frame = CGRectMake(0, 0, self.view.frame.size.width*0.35, self.view.frame.size.height);
                         
                     }
                     completion:nil];
    
    //NSLog(@"Hi");

    UIImage *profileImage = [UIImage imageNamed:@"Profile1"];
    self.profileImageView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.profileImageView.layer.borderWidth = 2.0;
    //self.view.frame.size.width*0.105
    
    //NSLog(@"%lf", self.profileImageView.frame.size.height/2);
    self.profileImageView.layer.masksToBounds = YES;
    [self.profileImageView setImage:profileImage];
    
    [self.profileNameLabel setText:[NSString stringWithFormat:@"%@ 님",self.profileName]];
    
    UITapGestureRecognizer *tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapped:)];
    //tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    
    [self.tapActionView addGestureRecognizer:tapGesture];
    
    // 화면이 돌아갔을 때, notification
    // selector에 화면이 돌아갈 때 하고 싶은 메소드를 구현
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
    
    //강준 20160727
    [self loadUserInfo];
    
    
}

-(void) loadUserInfo{
    
    
    //유저이름
    NSString *userName = [UserObject sharedInstance].userName;
    
    if([userName length] > 0 && [userName isKindOfClass:NSString.class]){
        self.profileNameLabel.text = [UserObject sharedInstance].userName;
    }
    
    //유저아바타
    if([[UserObject sharedInstance].profileUrl isKindOfClass:NSString.class] && [[UserObject sharedInstance].profileUrl length] > 0){
        NSURL *imageUrl = [NSURL URLWithString:[UserObject sharedInstance].profileUrl];
        [self.profileImageView  sd_setImageWithURL:imageUrl placeholderImage:[UIImage new]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             if(cacheType == SDImageCacheTypeNone){
                                                 self.profileImageView.alpha = 0;
                                                 
                                                 [UIView animateWithDuration:0.2f animations:^{
                                                     self.profileImageView.alpha = 1;
                                                 } completion:^(BOOL finished) {
                                                     self.profileImageView.alpha = 1;
                                                 }];
                                                 
                                             }
                                         }];
    }
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
    
    NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    if(referenceURL) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            
        
            
            
            
            
        } failureBlock:^(NSError *error) {
            // error handling
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void) sendProfileToServer:(NSString *) fileName{
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
    UserObject *userObject =[UserObject sharedInstance];
    [parameter setObject:userObject.pk forKey:@"id"];
    [parameter setObject:userObject.userName forKey:@"nickname"];
    [parameter setObject:@[] forKey:@"alcohol_tags"];
    [parameter setObject:@[] forKey:@"food_tags"];
    [parameter setObject:@[] forKey:@"place_tags"];
    [parameter setObject:self.profileImageView.image forKey:@"avatar"];
    [parameter setObject: userObject.userEmail forKey:@"email"];
    [parameter setObject:userObject.passWord forKey:@"password"];
    
    
    NSString *url = [NSString stringWithFormat:@"/api/users/%@/edit/",userObject.pk];
    
    [[RequestObject sharedInstance] sendToServer:url option:@"PUT" parameters:parameter image:self.profileImageView.image fileName:self.fileName success:^(NSURLResponse *response, id responseObject, NSError *error) {
        //성공시
    } progress:^(NSProgress *uploadProgress) {
        //프로세스
    } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
        //실패
    } useAuth:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)logOUtBtn:(id)sender {

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //  강준
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    //자동로그인 해제
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LOGIN"];
    
    //RootViewController 로 간다 (로그인화면으로)
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)editTagsBtn:(id)sender {
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
    EditMyTagsViewController *editMyTagsVC = [stb instantiateViewControllerWithIdentifier:@"EditMyTagsViewController"];
    
    [self presentViewController:editMyTagsVC animated:YES completion:nil];
}

- (void)addBlurView {
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.parentViewController.view.bounds;
    //[self.view addSubview:visualEffectView];
    
    [self.parentViewController.view addSubview:visualEffectView];
}

- (void) gestureTapped:(UIGestureRecognizer *)sender {
    NSLog(@"tapped");
    
    
    /*
    for(UIView *subview in [self.parentViewController.view subviews])
    {
        if([subview isKindOfClass:[UIVisualEffectView class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    [UIView transitionWithView:self.view duration:0.5
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^ {
                        
                        self.view.frame = CGRectMake(-self.view.frame.size.width*0.35, 0, self.view.frame.size.width, self.view.frame.size.height);
                        
                    }
                    completion:^(BOOL finished) {
                        
                        [self.view removeFromSuperview];
                        
                    }];
    */

    
    // 이렇게 구현하면 애니메이션은 다른 쓰레드에서 일어나기 때문에 애니메이션이 끝나고 remove되는게 아니라 바로 그냥 사라져버린다.
    //[self.view removeFromSuperview];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.menuView.frame = CGRectMake(-self.view.frame.size.width*0.35, 0, self.view.frame.size.width*0.35, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//강준
//앱정보를 보여준다.
- (IBAction)appInfoButton:(id)sender {

    
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppInfoViewController *controller = [stb instantiateViewControllerWithIdentifier:@"AppInfoView"];
    
    [self presentViewController:controller animated:YES completion:nil];

    
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
