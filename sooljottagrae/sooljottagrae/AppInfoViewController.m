//
//  AppInfoViewController.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 27..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "AppInfoViewController.h"

@interface AppInfoViewController ()
@property (strong, nonatomic) IBOutlet UIView *fakeNaviView;
@property (strong, nonatomic) IBOutlet UILabel *titleAppInfo;
@property (strong, nonatomic) IBOutlet UITextView *appInfoTextView;

@property (strong, nonatomic) IBOutlet UILabel *titleOpenLicense;
@property (strong, nonatomic) IBOutlet UITextView *textViewOpenLisence;
@end

@implementation AppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadAppInfo{
    
    self.fakeNaviView.backgroundColor = THEMA_BG_COLOR;
    
}


//앱설명 페이지에서 벗어난다.
- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
