//
//  MyTagsCollectionViewController.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "RequestObject.h"
#import "MyTagsCollectionViewController.h"

/**************************************************
 * Cell Custom
 **************************************************/

@interface MyTagCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;  //이미지
@property (strong, nonatomic) IBOutlet UIView *infoView;        //하단뷰
@property (strong, nonatomic) IBOutlet UILabel *commentsCount;  //코멘트갯수

@end

@implementation MyTagCell

@end



/**************************************************
 * ViewController
 **************************************************/
@interface MyTagsCollectionViewController (){
    UIRefreshControl *refreshControl;
}

@property (strong, nonatomic) NSMutableArray *tagDataList;


// UIRefreshControl 배경
@property (strong, nonatomic) UIView *refreshColorView;
// 로딩이미지의 투명배경
@property (strong, nonatomic) UIView *refreshLoadingView;
// 로딩이미지
@property (strong, nonatomic) UIImageView *loadingImg;
// 리프레싱 하고 있는지 여부
@property (assign) BOOL isRefreshAnimating;


@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;


@end

@implementation MyTagsCollectionViewController

static NSString * const reuseIdentifier = @"Cell1";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //화면 기초 설정
    [self createView];
    
    //데이터 초기 불러오기
    [self dataList];
    
    //리프레시컨트롤러 초기셋팅
    [self initCustomRefreshControl];
    
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//화면기초설정
-(void) createView{
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

//데이터 초기 불러오기 설정
-(void) dataList{
    self.tagDataList = [NSMutableArray arrayWithObjects:
                        @{@"pk":@(1), @"image":@"http://m.modoonews.com/data/image/jjalbang/20160422/jjalbang_mn_1461268951_62.jpg", @"comments_number":@(1000)},
                        @{@"pk":@(2), @"image":@"http://cfile1.uf.tistory.com/image/232C2B3556E1686F2478D7", @"comments_number":@(1000)},
                        @{@"pk":@(3), @"image":@"http://res.heraldm.com/content/image/2016/01/15/20160115000217_0.jpg", @"comments_number":@(1000)},
                        @{@"pk":@(4), @"image":@"https://4.bp.blogspot.com/-acnIluVb--U/VuQBvUBctXI/AAAAAAAAAhk/nW-fS45EY4MUsku6ty6W5pvLrxLcpmzUQ/s1600/5.jpg", @"comments_number":@(1000)},
                        @{@"pk":@(5), @"image":@"https://4.bp.blogspot.com/--yCBnaJYbs0/VuQBtd6NV8I/AAAAAAAAAhA/akTgcpMUxz0omgSqQbZZvWzH6-Kqpf1PQ/s1600/11.jpg", @"comments_count":@(1000)},
                        @{@"pk":@(6), @"image":@"http://cfile25.uf.tistory.com/image/2246F24856E648D62CA343", @"comments_number":@(1000)},
                        @{@"pk":@(7), @"image":@"http://cdnweb01.wikitree.co.kr/webdata/editor/201601/25/img_20160125132327_7546820a.jpg", @"comments_number":@(1000)},
                        @{@"pk":@(8), @"image":@"https://i.ytimg.com/vi/rnm-6-J-Cqs/maxresdefault.jpg", @"comments_number":@(1000)},
                        @{@"pk":@(9), @"image":@"http://cfile29.uf.tistory.com/image/213C6A4E56DD78F0230478", @"comments_number":@(1000)},
                        @{@"pk":@(10), @"image":@"http://thumbnail.egloos.net/600x0/http://pds27.egloos.com/pds/201606/05/47/b0041247_57541177121ae.jpeg", @"comments_number":@(1000)},
                        @{@"post_id":@(11), @"image":@"https://ncache.ilbe.com/files/attach/new/20160323/377678/7722287414/7751417684/3046848873ccc4dafe3772154d966bca.png", @"comments_number":@(1000)},
                        @{@"pk":@(12), @"image":@"http://cfile4.uf.tistory.com/image/24213C3B56D03E95452B2A", @"comments_number":@(1000)},
                        @{@"pk":@(13), @"image":@"http://cfile27.uf.tistory.com/image/2641B83A56F3E1B5108765", @"comments_number":@(1000)},
                        @{@"pk":@(14), @"image":@"http://pds.joins.com/news/component/newsen/201604/11/201604111048292810_1.jpg", @"comments_number":@(1000)},
                        @{@"pk":@(15), @"image":@"https://pbs.twimg.com/media/Cfj7uddUMAA003p.jpg", @"comments_number":@(1000)},
                        @{@"pk":@(16), @"image":@"http://i2.imgtong.com/1605/e18725d3ef3169a54ac51aa6cfcea3fe_ijjEolJ1CouHYESD.jpg", @"comments_number":@(1000)},
                        @{@"pk":@(17), @"image":@"http://cfile8.uf.tistory.com/image/2570A63A5786E2B00F3F8E", @"comments_number":@(1000)},
                        @{@"pk":@(18), @"image":@"http://cfile29.uf.tistory.com/image/2255344056F509E6336A78", @"comments_number":@(1000)},
                        nil];
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
    self.loadingImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh.png"]];
    
    [self.refreshLoadingView addSubview:self.loadingImg];
    self.refreshLoadingView.clipsToBounds = YES;
    
    // 기존 로딩이미지 icon 숨기기
    refreshControl.tintColor = [UIColor clearColor];
    
    
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
    
    
    //3초뒤 리프레싱 끝내도록 설정
    double delayInSeconds = 0.8f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
        [refreshControl endRefreshing];
    });
    
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
//        NSLog(@"Call");
//        NSLog(@"%lf, %lf",refreshControl.frame.origin.y, refreshBounds.size.height);
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





#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.tagDataList.count;
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    // 요청된 Supplementary View가 헤더인지 확인
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        // 재사용 큐에서 뷰를 가져온다
        UICollectionReusableView* view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        
        NSArray* titles = [[NSArray alloc] initWithObjects:@"Grils", @"Cars", @"Movies", nil];
        
        UILabel* lbl = (UILabel*)[view viewWithTag:100];
        if (lbl) lbl.text = titles[indexPath.section];
        
        return view;
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyTagCell *cell = (MyTagCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString *urlString = self.tagDataList[indexPath.row][@"image"];
    //url Null처리
    
    if([urlString isKindOfClass:NSString.class] && urlString.length > 0){
        NSURL *imageUrl = [NSURL URLWithString:self.tagDataList[indexPath.row][@"image"]];
        __weak UIImageView *weakImageView = cell.imageView;
        
        [cell.imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage new] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //이미지캐싱이 안되있을경우에 대한 애니메이션 셋티
            if (weakImageView != nil && cacheType == SDImageCacheTypeNone) {
                __strong UIImageView *strongImageView = weakImageView;
                strongImageView.alpha = 0;
                
                [UIView animateWithDuration:0.2f animations:^{
                    strongImageView.alpha = 1;
                } completion:^(BOOL finished) {
                    strongImageView.alpha = 1;
                }];
            }
        }];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"NoImageAvailable"];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }

    //셀 코멘트 갯수
    cell.commentsCount.text = [NSString stringWithFormat:@"%@", self.tagDataList[indexPath.row][@"comments_number"]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


//셀 사이즈 설정
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width/2)-3, 130);
}


#pragma mark <UICollectionViewDelegate>
//셀선택시 보여준다.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSDictionary *contents = self.tagDataList[indexPath.row];
    
    NSString *postId = contents[@"pk"];
    
    NSLog(@"/api/posts/%@",postId);
    
    
    return YES;
}

#pragma mark UIScrollView<UIScrollViewDelegate>

//셀이 움직이 멈췄을때
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //샐 가장 하단시 호출
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        //NSLog(@"ended Cell call");
        
        NSLog(@"추가적으로 내용을 더 넣습니다");
        NSArray *tempList = [[NSArray alloc] initWithArray:_tagDataList.copy];
        [_tagDataList addObjectsFromArray:tempList];
        [self.collectionView reloadData];
       // NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
//        
//        NSDictionary *parameters = @{@"email":[defualts objectForKey:@"EMAIL"],
//                                     @"auth":[defualts objectForKey:@"TOKEN"],
//                                     @"gubun":@(1),
//                                     @"list_count":@(20)};
        
        /*
         [[RequestObject sharedInstance] sendToServer:@"/api/post/list/"
         parameters:parameters
         success:^(NSURLResponse *response, id responseObject, NSError *error) {
         
         }
         fail:^(NSURLResponse *response, id responseObject, NSError *error) {
         
         }];
         
         */
        
        
    }
}


@end
