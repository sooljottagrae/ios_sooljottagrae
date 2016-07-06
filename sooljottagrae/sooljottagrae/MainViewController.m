//
//  MainViewController.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "RequestObject.h"


@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UIButton *mostCommentedButton;
@property (strong, nonatomic) IBOutlet UIButton *myTagsButton;


@property (nonatomic) NSArray *availableIdentifiers;
@property (strong, nonatomic) IBOutlet UIView *menuView;
@property (strong, nonatomic) IBOutlet UIView *tabAreaView;

@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) IBOutlet UIButton *addPostButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self settingFoTabbarButton];
    
    [self performSegueWithIdentifier:@"mostCommented" sender:self.tabBarButtons[0]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createView{
    
    self.menuView.backgroundColor = UIColorFromRGB(0x000000, 1.0);
    self.tabAreaView.backgroundColor = [UIColor whiteColor];
    
    
}


//탭바를 위한 셋팅
-(void) settingFoTabbarButton{
    
    self.availableIdentifiers = @[@"mostCommented", @"MyTags"];
    self.tabBarButtons = @[self.mostCommentedButton, self.myTagsButton];
    
}


/****************************************************************
 * 버튼 기능 구현
 ****************************************************************/

//프로필 버튼 액션
- (IBAction)clickedProfileButton:(UIButton *)sender {
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
    SettingViewController *settingVC = [stb instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    /*
    UIViewController * contributeViewController = [[UIViewController alloc] init];
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *beView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    beView.frame = self.view.bounds;
    
    contributeViewController.view.frame = self.view.bounds;
    contributeViewController.view.backgroundColor = [UIColor clearColor];
    [contributeViewController.view insertSubview:beView atIndex:0];
    contributeViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
     

    
    //임시버튼을 만들어서 추가 한다.
    UIButton *dissButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 300, 30)];
    [dissButton setTitle:@"닫기" forState:UIControlStateNormal];
    [dissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dissButton addTarget:self action:@selector(dissmissButton) forControlEvents:UIControlEventTouchUpInside];
    
    [contributeViewController.view addSubview:dissButton];
    
    */
    
    [self addChildViewController:settingVC];
//    contributeViewController.view.frame = CGRectMake(0, 0, 0, contributeViewController.view.frame.size.height);
    [settingVC setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self.view addSubview:settingVC.view];
    

    
    //애니메이션
    [UIView animateWithDuration:0.2 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                          settingVC.view.frame = self.view.bounds;
                     } completion:^(BOOL finished) {
                          [settingVC didMoveToParentViewController:self];
                     }];
    

    
}
//어린이뷰를 꺼버린다~~
-(void) dissmissButton{
    UIViewController *vc = [self.childViewControllers lastObject];
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}

//선택된 탭바에 언더바를 넣는다.
-(void) selectedButton:(UIButton *)sender{
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, sender.frame.size.height-3, self.view.frame.size.width/2, 3.0f);
    bottomBorder.backgroundColor = [UIColor blackColor].CGColor;
    [sender.layer addSublayer:bottomBorder];
}


//선택된 탭바의 언더바를 해제한다.
-(void) removeSelectedLine:(UIButton *) sender{
    for(CALayer *layer in sender.layer.sublayers) {
        layer.backgroundColor = [UIColor clearColor].CGColor;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.availableIdentifiers containsObject: segue.identifier]){
        for(UIButton *selected in self.tabBarButtons){
            if(sender != nil && ![selected isEqual: sender]) {
                [selected setSelected: NO];
                [self removeSelectedLine:selected];
            } else if(sender != nil) {
                [selected setSelected: YES];
                [self selectedButton:selected];
            }
        }
    }
}


@end
