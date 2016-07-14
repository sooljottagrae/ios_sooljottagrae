//
//  MostCommentedCollectionViewController.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MostCommentedCollectionViewController.h"
#import "RequestObject.h"

/**************************************************
 * Cell Custom
 **************************************************/

@interface MostCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MostCell

@end

/**************************************************
 * Controller Implementation
 **************************************************/

@interface MostCommentedCollectionViewController ()
{
    BOOL isCustom;
    NSArray *array;
    UIRefreshControl *refreshControl;
}

@property (strong, nonatomic) NSMutableArray *dataList;

@property NSInteger pageCount;


// UIRefreshControl 배경
@property (strong, nonatomic) UIView *refreshColorView;
// 로딩이미지의 투명배경
@property (strong, nonatomic) UIView *refreshLoadingView;
// 로딩이미지
@property (strong, nonatomic) UIImageView *loadingImg;
// 리프레싱 하고 있는지 여부
@property (assign) BOOL isRefreshAnimating;


@end

@implementation MostCommentedCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    
    
    
    //리스트 로드 노티피
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addCellData)
                                                 name:MostCommentdListLoadSuccess
                                               object:nil];

    [self setttingDataList];
    
    [self initCustomRefreshControl];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self.collectionView sendSubviewToBack:refreshControl];
}
/**
 * Custom RefreshControl 초기화
 */
- (void)initCustomRefreshControl {
    refreshControl = [[UIRefreshControl alloc] init];
    
    // UIRefreshControl 배경
    self.refreshColorView = [[UIView alloc] initWithFrame:refreshControl.bounds];
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.alpha = 0.30;
    
    // 로딩이미지의 투명배경
    self.refreshLoadingView = [[UIView alloc] initWithFrame:refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // 로딩 이미지
    //self.loadingImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cocktail-icon1.png"]];
    
    [self.refreshLoadingView addSubview:self.loadingImg];
    self.refreshLoadingView.clipsToBounds = YES;
    
    // 기존 로딩이미지 icon 숨기기
    //refreshControl.tintColor = [UIColor clearColor];
    
    [refreshControl addSubview:self.refreshColorView];
    [refreshControl addSubview:self.refreshLoadingView];
    
    self.isRefreshAnimating = NO;
    
    // 리프레시 이벤트 연결
    [refreshControl addTarget:self action:@selector(handleRefreshForCustom:) forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView addSubview:refreshControl];
}

/**
 * 리프레시 이벤트 for Custom
 */
- (void)handleRefreshForCustom:(UIRefreshControl *)sender {
    
    // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
    // This is where you'll make requests to an API, reload data, or process information
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // When done requesting/reloading/processing invoke endRefreshing, to close the control
        [refreshControl endRefreshing];
    });
    // -- FINISHED SOMETHING AWESOME, WOO! --
}

/**
 * 테이블뷰 스크롤시 이벤트
 * 로딩이미지 위치 계산
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // RefreshControl 크기
    CGRect refreshBounds = refreshControl.bounds;
    
    // 테이블뷰 당겨진 거리 >= 0
    CGFloat pullDistance = MAX(0.0, - refreshControl.frame.origin.y);
    
    // 테이블뷰이 Width의 중간
    CGFloat midX = self.collectionView.frame.size.width / 2.0;
    
    // 로딩이미지 RefreshControl의 중간에 위치하도록 계산
    CGFloat loadingImgHeight = self.loadingImg.bounds.size.height;
    CGFloat loadingImgHeightHalf = loadingImgHeight / 2.0;
    
    CGFloat loadingImgWidth = self.loadingImg.bounds.size.width;
    CGFloat loadingImgWidthHalf = loadingImgWidth / 2.0;
    
    CGFloat loadingImgY = pullDistance / 2.0 - loadingImgHeightHalf;
    CGFloat loadingImgX = midX - loadingImgWidthHalf;
    
    CGRect loadingImgFrame = self.loadingImg.frame;
    loadingImgFrame.origin.x = loadingImgX;
    loadingImgFrame.origin.y = loadingImgY;
    
    self.loadingImg.frame = loadingImgFrame;
    
    refreshBounds.size.height = pullDistance;
    
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;
    
    
    
    if (refreshControl.isRefreshing && !self.isRefreshAnimating) {
        NSLog(@"Call");
        NSLog(@"%lf, %lf",refreshControl.frame.origin.y, refreshBounds.size.height);
        [self animateRefreshView];
    }
    
   // NSLog(@"scrollViewDidScroll");
}

/**
 * 애니메이션
 * 로딩이미지 회전
 */
- (void)animateRefreshView {
    NSArray *colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor magentaColor]];
    static int colorIndex = 0;
    
    self.isRefreshAnimating = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // 로딩이미지 회전 by M_PI_2 = PI/2 = 90 degrees
                         [self.loadingImg setTransform:CGAffineTransformRotate(self.loadingImg.transform, M_PI_2)];
                         
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished) {
                         if (refreshControl.isRefreshing) {
                             [self animateRefreshView];
                         } else {
                             [self resetAnimation];
                         }
                     }];
}

/**
 * 애니메이션 중지
 */
- (void)resetAnimation {
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
}




//Temp Data List
-(void) setttingDataList{

    self.dataList = @[@{@"postId":@"1", @"thumnail_url":@"http://i.imgur.com/fmckBDO.jpg"},
                      @{@"postId":@"2", @"thumnail_url":@"http://fansta.net/data/editor/1510/3732507908_562f410b7e18b_14459374195165"},
                      @{@"postId":@"3", @"thumnail_url":@"http://photo.jtbc.joins.com/news/2015/12/30/201512301208328789.jpg"},
                      @{@"postId":@"4", @"thumnail_url":@"http://file2.instiz.net/data/file2/2016/01/18/c/0/7/c07e8aa653757d742d2f3b043b559592.jpg"},
                      @{@"postId":@"5", @"thumnail_url":@"https://pbs.twimg.com/profile_images/683106307985903616/_DfSOjZt.jpg"},
                      @{@"postId":@"6", @"thumnail_url":@"http://file2.instiz.net/data/cached_img/upload/2015/11/12/15/f7ae4cf4ce49c5141e0506b6650812d7.jpg"},
                      @{@"postId":@"7", @"thumnail_url":@"http://img.danawa.com/images/descFiles/4/23/3022192_1444312249911.jpeg"},
                      @{@"postId":@"8", @"thumnail_url":@"http://file2.instiz.net/data/cached_img/upload/2015/11/10/18/c0f386660df03e9e1866d7db92ec2a79.jpg"},
                      @{@"postId":@"11", @"thumnail_url":@"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcRPXFMknbeBzqje0Y5SgQSaEaOLIN5oqvcVMhep5XZz9EfmjHbF4w"},
                      @{@"postId":@"111", @"thumnail_url":@"http://cfile28.uf.tistory.com/image/2721EC3F562795F6312CFB"}
                      
                      ].copy;

}




-(void) didLoadDataList{
    [[RequestObject sharedInstance] mostCommentedList:self.pageCount++ listCount:30];
}

-(void) addCellData{
    [self.dataList addObjectsFromArray: [RequestObject sharedInstance].mostCommentedList];
    [self.collectionView reloadData];
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.dataList.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MostCell *cell = (MostCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell

    NSURL *urlString = [NSURL URLWithString:self.dataList[indexPath.row][@"thumnail_url"]];
    [cell.imageView sd_setImageWithURL:urlString];
    
    return cell;
}

//Cell Size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((self.view.frame.size.width/2)-5, 130);
}


#pragma mark <UICollectionViewDelegate>


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
   
    
}

// Uncomment this method to specify if the specified item should be selected

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
   // UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSDictionary *contents = self.dataList[indexPath.row];
    
    NSString *postId = contents[@"postId"];
    
    NSLog(@"postId : %@",postId);
    
    
    return YES;
}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


#pragma mark - UIScrollView<Delegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //샐 가장 하단시 호출
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        //NSLog(@"ended Cell call");
    }
}



@end
