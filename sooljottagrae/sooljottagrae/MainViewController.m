//
//  MainViewController.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "WritePostViewController.h"
#import "RequestObject.h"
#import "MostCommentedCollectionViewController.h"
#import "MyTagsCollectionViewController.h"


@interface MainViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIButton *targetButton;                   //현재 탭바 타겟

@property (strong, nonatomic) IBOutlet UIButton *mostCommentedButton;   //가장많이댓글단뷰 버튼
@property (strong, nonatomic) IBOutlet UIButton *myTagsButton;          //내태그들뷰 버튼


@property (nonatomic) NSArray *availableIdentifiers;                    //사용가능한 탭바Segue


@property (strong, nonatomic) IBOutlet UIView *menuView;                //상단메뉴 영역
@property (strong, nonatomic) IBOutlet UIView *tabAreaView;             //탭바 영역

@property (strong, nonatomic) IBOutlet UIButton *profileButton;         //프로필버튼
@property (strong, nonatomic) IBOutlet UIButton *addPostButton;         //포스팅버튼



//스크롤 페이징을 위한 셋팅
@property (strong, nonatomic)IBOutlet UIScrollView *pageScrollView;     //스크롤뷰
@property (strong, nonatomic) NSMutableArray *arrayForPages;            //스크롤뷰 페이징을 위한 배열
@property (weak, nonatomic)IBOutlet UIPageControl *pageControl;         //페이지 컨트롤러

@property (strong, nonatomic) NSMutableArray *pageNames;                //페이지 이름들


//gm
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectedBarWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectedBarLeftMargin;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createView];
    [self settingFoTabbarButton];
    
    //페이지컨트롤 설정
    [self initPageControllerSetting];
    
    //초기화면 셋팅 및 버튼 선택
    [self clickedTabButton:self.mostCommentedButton];
    
    //기본세그 선택
//    [self performSegueWithIdentifier:@"mostCommented" sender:self.tabBarButtons[0]];
    
    //디바이스가 화면이 변경될 때마다 불러온다
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedFrameSize) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //스테이터스바 터치시 작동
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarHit) name:@"touchStatusBarClick" object:nil];

    
    //셀렉트바 사이즈 설정
    self.selectedBarWidth.constant = [UIScreen mainScreen].bounds.size.width / 2;
    
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //프레임사이즈 변경
    [self changedFrameSize];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//화면 구성을 위한 기초 설정
-(void) createView{
    
    //상단 메뉴뷰
    self.menuView.backgroundColor = THEMA_BG_COLOR;
    //탭버튼 뷰
    self.tabAreaView.backgroundColor = [UIColor whiteColor];
    //표현 될 부분
    self.placeholderView.backgroundColor = [UIColor whiteColor];
    //스크롤뷰
    self.pageScrollView.backgroundColor = [UIColor clearColor];
}


//탭바를 위한 셋팅
-(void) settingFoTabbarButton{
    
    self.availableIdentifiers = @[@"mostCommented", @"MyTags"];
    self.tabBarButtons = @[self.mostCommentedButton, self.myTagsButton];
    
}



//페이지컨트롤러를 위한 설정
-(void) initPageControllerSetting{
    
    //보여줄 페이지 맥시멈 갯수
    NSInteger numbersOfPage = 2;
    
    //보여준 녀석의 초기화
    self.arrayForPages = [[NSMutableArray alloc]init];
    
    //값을 일단 null로 넣는다.
    for(NSInteger i=0; i<numbersOfPage; i++){
        [self.arrayForPages addObject:[NSNull null]];
    }
    
    //페이지별 스트리보드 indentifier ID
    self.pageNames = @[@"MOST_COMMENTED", @"MY_TAGS"].mutableCopy;
    
    //NSLog(@"%ld, %@",self.arrayForPages.count,self.pageNames);
    
    // 스크롤 뷰의 컨텐츠 사이즈를 미리 만들어둡니다.
    CGSize contentSize = self.pageScrollView.frame.size;
    contentSize.width = self.pageScrollView.frame.size.width * numbersOfPage;
    
    // 스크롤 뷰의 컨텐츠 사이즈를 설정합니다.
    [self.pageScrollView setContentSize:contentSize];
    
    //페이징을 위한 설정
    [self.pageScrollView setDelegate:self];//Delegate
    [self.pageScrollView setPagingEnabled:YES]; //페이징여부
    [self.pageScrollView setBounces:NO];//바운스금지
    [self.pageScrollView setScrollsToTop:NO];//스크롤뷰 상하스크롤금지
    [self.pageScrollView setScrollEnabled:YES];//스크롤 가능하도록 설정
    
    //스크롤바 안보이게 설정
    self.pageScrollView.showsVerticalScrollIndicator = NO;
    self.pageScrollView.showsHorizontalScrollIndicator = NO;
    
    [self.pageControl setNumberOfPages:numbersOfPage];
    [self.pageControl setCurrentPage:0];
    
    //표현할 뷰어들 설정
    [self loadScrollViewDataSourceWithPage:0];
    [self loadScrollViewDataSourceWithPage:1];
    
}

//스크롤뷰 표시할 뷰들에 대한 설정 및 미리 로드
- (void)loadScrollViewDataSourceWithPage:(NSInteger)page{

    // 스크롤뷰에서 표시할 뷰를 미리 로드합니다.
    
    // 페이지가 범위를 벗어나면 로드하지않습니다.
    if(page >= self.arrayForPages.count){
        return;
    }
    
    // 페이지의 뷰컨트롤러를 배열에서 읽어옵니다.
    UICollectionViewController *controller = [self.arrayForPages objectAtIndex:page];
    
    // 현재 컨트롤러가 비어있다면, 컨트롤러를 초기화해줍니다.
    if((NSNull *)controller == [NSNull null]){
        NSLog(@"Page %ld Controller Init..",page);
    
        
        NSString *name = self.pageNames[(page>=self.pageNames.count) ? 0 : page];
        
        // 현재 스토리보드에서 SinglePageView라는 StoryboardIdentifier를 가진 뷰를 읽어옵니다.
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        controller = [storyBoard instantiateViewControllerWithIdentifier:name];
        
        // 현재 컨트롤러와 배열에 들어있는 객체를 교체합니다.
        [self.arrayForPages replaceObjectAtIndex:page withObject:controller];
    }
    
    // 현재 컨트롤러의 뷰가 superview를 가지지 못했을 경우(현재 스크롤뷰의 서브뷰가 아닌 경우)
    // 스크롤 뷰의 서브뷰로 추가해줍니다.
    if(controller.view.superview == nil){
        NSLog(@"Page %ld Controller Add On ScrollView..",page);
        
        // 현재 컨트롤러의 뷰가 위치할 frame을 잡아줍니다.
        // Page에 따라 Origin의 x값이 달라집니다.
        CGRect curFrame = self.pageScrollView.frame;
        curFrame.origin.x = CGRectGetWidth(curFrame) * page;
        curFrame.origin.y = 0;
        controller.view.frame = curFrame;
        
        // 컨트롤러를 현재 컨트롤러의 ChildViewController로 등록하고 컨트롤러의 뷰를 스크롤뷰에 Subview로 추가해줍니다.
        [self addChildViewController:controller];
        [self.pageScrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
 
}

//스테이터스바 탭시 탑으로 스크롤된다.
-(void)statusBarHit{
    
    UICollectionViewController *controller = [self.arrayForPages objectAtIndex:self.targetButton.tag];
    [controller.collectionView setContentOffset:CGPointZero animated:YES];
    
}

#pragma mark - UIScrollDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.selectedBarLeftMargin.constant = scrollView.contentOffset.x / 2;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat pageWidth = CGRectGetWidth(self.pageScrollView.frame);
    // 현재 페이지를 구합니다. floor는 소수점 자리를 버리는 함수입니다
    NSUInteger page = floor((self.pageScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    // 현재 페이지를 계산된 페이지로 설정해줍니다.
    self.pageControl.currentPage = page;
    
    // 보여줄 페이지들을 미리 로드합니다.
    
    //현재 선택된 버튼을 선택해제
    self.targetButton.selected = NO;
   
    //페이지 선택에 따른 구현부
    if(page == 0){
        [self loadScrollViewDataSourceWithPage:page];
        [self loadScrollViewDataSourceWithPage:page + 1];
        
        self.mostCommentedButton.selected = YES;
        self.targetButton = self.mostCommentedButton;
    }else{
        [self loadScrollViewDataSourceWithPage:page - 1];
        [self loadScrollViewDataSourceWithPage:page];
        
        self.myTagsButton.selected = YES;
        self.targetButton = self.myTagsButton;
    }
    
}

    // 스크롤을 임의로 원하는 페이지로 이동시킵니다.
- (void)gotoPage:(BOOL)animated AtPage:(NSInteger)page{
    NSLog(@"gotoPage : %ld",page);
    
    
    // 페이지 컨트롤의 현재 페이지를 넘겨받은 페이지로 설정합니다.
    [self.pageControl setCurrentPage:page];
    
    // 미리 뷰를 로드합니다.
    if(page == 0){
        [self loadScrollViewDataSourceWithPage:page];
        [self loadScrollViewDataSourceWithPage:page + 1];
    }else{
        [self loadScrollViewDataSourceWithPage:page - 1];
        [self loadScrollViewDataSourceWithPage:page];
    }
    
    
    
    // 보여줄 스크롤뷰의 ContentOffset을 설정합니다.
    // 스크롤 뷰의 Width * Page입니다.
    CGRect bounds = self.pageScrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    
    // 정해진 부분으로 스크롤뷰를 스크롤합니다.
    [self.pageScrollView scrollRectToVisible:bounds animated:animated];
    
}

//각 화면들에 대한 프레임크기 재설정
-(void) changedFrameSize{
//    self.selectedBarLeftMargin.constant = [UIScreen mainScreen].bounds.size.width / 2;
    self.selectedBarWidth.constant = [UIScreen mainScreen].bounds.size.width / 2;
//    [self.view layoutIfNeeded];
    
    // 스크롤 뷰의 컨텐츠 사이즈를 미리 만들어둡니다.
    CGSize contentSize = self.pageScrollView.frame.size;
    contentSize.width = self.pageScrollView.frame.size.width * self.pageNames.count;
    
    // 스크롤 뷰의 컨텐츠 사이즈를 설정합니다.
    [self.pageScrollView setContentSize:contentSize];
    
    //콜렉션뷰 객체 초기화
    UICollectionViewController *controller = nil;
    
    //배열에 저장 된 객체들을 불러와 화면에 맞도록 조정한다.
    for(NSInteger i=0; i<self.arrayForPages.count ; i++){
        controller = [self.arrayForPages objectAtIndex:i];
        if(controller.view.superview != nil){
            CGRect curFrame = self.placeholderView.frame;
            curFrame.origin.x = CGRectGetWidth(curFrame) * i;
            curFrame.origin.y = 0;
            controller.view.frame = curFrame;
            
       }
    }
    
    //현재 선택된 버튼의 따른 보여주기 처리를 한다.
    //이처리를 안할경우 화면이 정상적으로 보여지지 않는다.
    if(self.targetButton.tag == 0) {
        [self gotoPage:NO AtPage:0];
        self.selectedBarLeftMargin.constant = 0;
    }
    
    if(self.targetButton.tag == 1){
        [self gotoPage:NO AtPage:1];
        self.selectedBarLeftMargin.constant = [UIScreen mainScreen].bounds.size.width / 2;
    }


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
//포스트 버튼
- (IBAction)clickedAddPostBtn:(UIButton *)sender {
    NSLog(@"Clicked");
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
    WritePostViewController *writePostVC = [stb instantiateViewControllerWithIdentifier:@"WritePostViewController"];
    [self presentViewController:writePostVC animated:YES completion:nil];
}

//어린이뷰를 꺼버린다~~
-(void) dissmissButton{
    UIViewController *vc = [self.childViewControllers lastObject];
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}



/* 사용 안함 (강준)
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
 */

//탭버튼 선택에 따른 화면 설정
-(IBAction)clickedTabButton:(UIButton *)sender{
    NSLog(@"clickedTabButton %ld",sender.tag);
    [self.targetButton setSelected:NO];
    
    //가장많이 본 글
    if(sender.tag == 0) {
        self.targetButton = sender;
        [self.targetButton setSelected:YES];
        [self gotoPage:YES AtPage:0];
    }
    
    //내태그
    if(sender.tag == 1){
        self.targetButton = sender;
        [self.targetButton setSelected:YES];
        [self gotoPage:YES AtPage:1];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//사용안함 (강준)
//    if([self.availableIdentifiers containsObject: segue.identifier]){
//        for(UIButton *selected in self.tabBarButtons){
//            if(sender != nil && ![selected isEqual: sender]) {
//                [selected setSelected: NO];
//                //[self removeSelectedLine:selected];
//            } else if(sender != nil) {
//                [selected setSelected: YES];
//                //[self selectedButton:selected];
//                self.targetButton = selected;
//            }
//        }
//    }
}


@end
