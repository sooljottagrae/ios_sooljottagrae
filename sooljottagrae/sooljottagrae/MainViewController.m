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


@interface MainViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIButton *targetButton;                   //현재 탭바 타겟

@property (strong, nonatomic) IBOutlet UIButton *mostCommentedButton;   //가장많이댓글단뷰 버튼
@property (strong, nonatomic) IBOutlet UIButton *myTagsButton;          //내태그들뷰 버튼


@property (nonatomic) NSArray *availableIdentifiers;                    //


@property (strong, nonatomic) IBOutlet UIView *menuView;                //상단메뉴 영역
@property (strong, nonatomic) IBOutlet UIView *tabAreaView;             //탭바 영역

@property (strong, nonatomic) IBOutlet UIButton *profileButton;         //프로필버튼
@property (strong, nonatomic) IBOutlet UIButton *addPostButton;         //포스팅버튼



//스크롤 페이징을 위한 셋팅
@property (strong, nonatomic) UIScrollView *pageScrollView;             //스크롤뷰
@property (strong, nonatomic) NSMutableArray *arrayForPages;            //스크롤뷰 페이징을 위한 배열
@property (weak, nonatomic)IBOutlet UIPageControl *pageControl;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createView];
    [self settingFoTabbarButton];
    
    //기본세그 선택
    [self performSegueWithIdentifier:@"mostCommented" sender:self.tabBarButtons[0]];
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createView{
    
    
    self.menuView.backgroundColor = THEMA_BG_COLOR;
    self.tabAreaView.backgroundColor = [UIColor whiteColor];
    
//    //상위메뉴 배경 그라디언트
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.menuView.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0xffffff,1.0) CGColor],
//                       (id)[UIColorFromRGB(0xfdc2ff,1.0) CGColor],nil];
//    gradient.locations =[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.09],
//                         [NSNumber numberWithFloat:0.91], nil];
//    
//    [self.menuView.layer insertSublayer:gradient atIndex:0];

}


//탭바를 위한 셋팅
-(void) settingFoTabbarButton{
    
    self.availableIdentifiers = @[@"mostCommented", @"MyTags"];
    self.tabBarButtons = @[self.mostCommentedButton, self.myTagsButton];
    
    
}



//페이지컨트롤러를 위한 설정
-(void) initPageControllerSetting{
    
    //보여줄 페이지 맥시멈 갯수
    NSInteger maxPageCount = 2;
    
    //보여준 녀석의 초기화
    self.arrayForPages = [[NSMutableArray alloc]init];
    
    //값을 일단 null로 넣는다.
    for(NSInteger i=0; i<maxPageCount; i++){
        [self.arrayForPages addObject:[NSNull null]];
    }
    
    //페이징을 위한 설정
    
    [self.pageScrollView setDelegate:self];     //delegate
    [self.pageScrollView setPagingEnabled:YES]; //페이징여부
    [self.pageScrollView setFrame:self.placeholderView.bounds];
    
    [self.pageScrollView setBounces:NO];
    [self.pageScrollView setScrollsToTop:NO];
    [self.pageScrollView setScrollEnabled:YES];
    
    //스크롤바 안보이게 설정
    self.pageScrollView.showsVerticalScrollIndicator = NO;
    self.pageScrollView.showsHorizontalScrollIndicator = NO;
    
    [self.pageControl setNumberOfPages:2];
    [self.pageControl setCurrentPage:0];
    
    
    
}
/*
- (void)loadScrollViewDataSourceWithPage:(NSInteger)page{
    // 스크롤뷰에서 표시할 뷰를 미리 로드합니다.
    
    // 페이지가 범위를 벗어나면 로드하지않습니다.
    if(page >= self.arrayForPages.count){
        return;
    }
    
    // 페이지의 뷰컨트롤러를 배열에서 읽어옵니다.
    //PageViewController *controller = [_pageControl objectAtIndex:page];
    
    // 현재 컨트롤러가 비어있다면, 컨트롤러를 초기화해줍니다.
    // (initScrollViewAndPageControl 참조)
    if((NSNull *)controller == [NSNull null]){
        NSLog(@"Page %ld Controller Init..",page);
    }
    // 현재 스토리보드에서 SinglePageView라는 StoryboardIdentifier를 가진 뷰를 읽어옵니다.
    controller = [[self storyboard] instantiateViewControllerWithIdentifier:@"SinglePageView"];
    // 현재 컨트롤러의 뷰에 Frame을 초기화해줍니다.
    [controller.view setFrame:_scrollView.frame];
    // 컨트롤러에 이미지와 텍스트들을 설정합니다.
    [controller initPageViewInfo:page];
    // 현재 컨트롤러와 배열에 들어있는 객체를 교체합니다.
    [_controllers replaceObjectAtIndex:page withObject:controller];
    
    
    // 현재 컨트롤러의 뷰가 superview를 가지지 못했을 경우(현재 스크롤뷰의 서브뷰가 아닌 경우)
    // 스크롤 뷰의 서브뷰로 추가해줍니다.
    if(controller.view.superview == nil){
        NSLog(@"Page %d Controller Add On ScrollView..",page);
        
        // 현재 컨트롤러의 뷰가 위치할 frame을 잡아줍니다.
        // Page에 따라 Origin의 x값이 달라집니다.
        CGRect curFrame = _scrollView.frame;
        curFrame.origin.x = CGRectGetWidth(curFrame) * page;
        curFrame.origin.y = 0;
        controller.view.frame = curFrame;
        
        // 컨트롤러를 현재 컨트롤러의 ChildViewController로 등록하고 컨트롤러의 뷰를 스크롤뷰에 Subview로 추가해줍니다.
        [self addChildViewController:controller];
        [_scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}
*/
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
//가로모드일때 사이즈가 그대로이다.(유동적으로 변해야한다)
-(void) selectedButton:(UIButton *)sender{
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, sender.frame.size.height-3, sender.frame.size.width, 3.0f);
    
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
                //[self removeSelectedLine:selected];
            } else if(sender != nil) {
                [selected setSelected: YES];
                //[self selectedButton:selected];
                self.targetButton = selected;
            }
        }
    }
}


@end
