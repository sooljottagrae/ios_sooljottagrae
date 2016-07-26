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
#import "RFQuiltLayout.h"
#import "UIButton+indexPath.h"

/**************************************************
 * Cell Custom
 **************************************************/

@interface MostCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;  //Cell 이미지 뷰어
@property (strong, nonatomic) IBOutlet UIView *infoView;        //하단 표기 섹션
@property (strong, nonatomic) IBOutlet UILabel *commentsCount;  //하단 표기 섹션 라벨
@property (strong, nonatomic) IBOutlet UIButton *moreButton;

@end

@implementation MostCell

@end

/**************************************************
 * Controller Implementation
 **************************************************/

@interface MostCommentedCollectionViewController () <RFQuiltLayoutDelegate>
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

static NSString * const reuseIdentifier = @"Cell";  //셀재사용식별자

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    
    
    
    //리스트 로드 노티피
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshList)
                                                 name:MostCommentdListLoadSuccess
                                               object:nil];

    [self setttingDataList];
    
    [self initCustomRefreshControl];
    
    
    ///gm
    RFQuiltLayout *layout = (id)[self.collectionView collectionViewLayout];
    layout.delegate = self;
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2, 1);
    //
}


#pragma mark – RFQuiltLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize blockSizeForItem = CGSizeZero;
    
    blockSizeForItem.width = 1;
    
    CGFloat r = indexPath.item % 4;
    
    CGFloat height = 200;

    if (r < 1 ) {
        height = 100;
    } else if (r < 2) {
        height = 160;
    } else if (r < 3) {
        height = 190;
    }
    
    blockSizeForItem.height = height;
    
//    ZZalListItemModel *item = [self getListItemModelAtIndexPath:indexPath];
//    
//    if (self.columnType == NWZZalColumnOne) {
//        blockSizeForItem = [NWZZalOneColumnCell blockSizeForItemModel:item];
//        UIEdgeInsets insetsForItem = [NWZZalOneColumnCell cellInsetsForItemAtIndex:indexPath.item];
//        blockSizeForItem.height += (insetsForItem.top + insetsForItem.bottom) / [UIScreen mainScreen].scale;
//    } else if (self.columnType == NWZZalColumnTwo) {
//        blockSizeForItem = [NWZZalTwoColumnCell blockSizeForItemModel:item];
//    }
//    
//    if ([item isService] != YES) {
//        blockSizeForItem.height = 0;
//    }
    
    return blockSizeForItem;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetsForItemAtIndexPath:(NSIndexPath *)indexPath column:(NSInteger)column
{
    UIEdgeInsets insetsForItem = UIEdgeInsetsZero;
    
//    if (self.columnType == NWZZalColumnOne) {
//        insetsForItem = [NWZZalOneColumnCell cellInsetsForItemAtIndex:indexPath.item];
//    } else if (self.columnType == NWZZalColumnTwo) {
//        insetsForItem = [NWZZalTwoColumnCell cellInsetsForItemAtColumn:column];
//    }
    
    return insetsForItem;
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
        [self setttingDataList];
    
       // [refreshControl endRefreshing];
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
        //NSLog(@"Call");
        //NSLog(@"%lf, %lf",refreshControl.frame.origin.y, refreshBounds.size.height);
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




//Data List Setting
-(void) setttingDataList{
    
    self.dataList = [[NSMutableArray alloc]initWithObjects:
                    @{@"pk":@"1", @"image":@"http:i.imgur.com/fmckBDO.jpg", @"comments_number":@(2000)},
                    @{@"pk":@"2", @"image":@"http:fansta.net/data/editor/1510/3732507908_562f410b7e18b_14459374195165", @"comments_number":@(250)},
                    @{@"pk":@"3", @"image":@"http:photo.jtbc.joins.com/news/2015/12/30/201512301208328789.jpg",@"comments_number":@(200)},
                    @{@"pk":@"4", @"image":@"http:file2.instiz.net/data/file2/2016/01/18/c/0/7/c07e8aa653757d742d2f3b043b559592.jpg",@"comments_number":@(230)},
                    @{@"pk":@"5", @"image":@"https:pbs.twimg.com/profile_images/683106307985903616/_DfSOjZt.jpg",@"comments_number":@(220)},
                    @{@"pk":@"6", @"image":@"http:file2.instiz.net/data/cached_img/upload/2015/11/12/15/f7ae4cf4ce49c5141e0506b6650812d7.jpg",@"comments_number":@(220)},
                    @{@"pk":@"7", @"image":@"http:img.danawa.com/images/descFiles/4/23/3022192_1444312249911.jpeg",@"comments_number":@(220)},
                    @{@"pk":@"8", @"image":@"http:file2.instiz.net/data/cached_img/upload/2015/11/10/18/c0f386660df03e9e1866d7db92ec2a79.jpg",@"comments_number":@(220)},
                    @{@"pk":@"11", @"image":@"https:encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcRPXFMknbeBzqje0Y5SgQSaEaOLIN5oqvcVMhep5XZz9EfmjHbF4w",@"comments_number":@(220)},
                    @{@"pk":@"111", @"image":@"http:cfile28.uf.tistory.com/image/2721EC3F562795F6312CFB",@"comments_number":@(220)},
                    nil];
    
//    [[RequestObject sharedInstance] sendToServer:@"/api/posts/" option:@"GET" parameters:nil success:^(NSURLResponse *response, id responseObject, NSError *error) {
//        
//        if(responseObject != nil){
//            NSLog(@"%@",responseObject);
//            [self initDataList:[responseObject objectForKey:@"results"]];
//            [[NSNotificationCenter defaultCenter] postNotificationName:MostCommentdListLoadSuccess object:nil];
//            
//        }
//        
//        
//    } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
//        
//    } useAuth:NO];
//    

}

-(void) initDataList:(id)object{
    NSMutableArray *temp = object;
    self.dataList = temp.mutableCopy;
}


-(void) didLoadDataList{
    //[[RequestObject sharedInstance] mostCommentedList:self.pageCount++ listCount:30];
}

-(void) refreshList{
    //[self.dataList addObjectsFromArray: [RequestObject sharedInstance].mostCommentedList];
    if(refreshControl.isRefreshing){
        [refreshControl endRefreshing];
    }
    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

//콜렉션뷰 섹션갯수
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

//섹션당 표현할 갯수
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.dataList.count;
}


//콜렉션뷰 셀 데이터표현
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MostCell *cell = (MostCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell

    NSString *urlString = self.dataList[indexPath.row][@"image"];
    //url Null처리
    
    if([urlString isKindOfClass:NSString.class] && urlString.length > 0){
        NSURL *imageUrl = [NSURL URLWithString:self.dataList[indexPath.row][@"image"]];
        __weak UIImageView *weakImageView = cell.imageView;
        
        [cell.imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage new] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
    }else{
        cell.imageView.image = nil;
    }
    [cell.commentsCount setText:[NSString stringWithFormat:@"%@",self.dataList[indexPath.row][@"comments_number"]]];
    cell.moreButton.section = indexPath.section;
    cell.moreButton.item = indexPath.item;
    
    if (cell.moreButton.allTargets.count == 0) {
        [cell.moreButton addTarget:self action:@selector(onTapMore:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)onTapMore:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:button.item inSection:button.section];
 
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"차단" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.dataList removeObjectAtIndex:button.item];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];

        [[NSNotificationCenter defaultCenter] postNotificationName:MostCommentdListLoadSuccess object:nil];
        
        [alert dismissViewControllerAnimated:YES completion:^{
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:^{
            //s
        }];
        
    }];
    
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    
    
    
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

//셀 사이즈 설정
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((self.view.frame.size.width/2)-5, 130);
}


#pragma mark <UICollectionViewDelegate>
//셀선택시 보여준다.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    UIViewController *contorller = [stroyBoard instantiateViewControllerWithIdentifier:@""];
    
    NSDictionary *contents = self.dataList[indexPath.row];
    
    NSString *apiPath = [NSString stringWithFormat:@"%@%@",@"/api/posts/",contents[@"pk"]];
    
    //controller.url = apiPath;
    
    NSLog(@"apiPath : %@",apiPath);
}

-(void) dissmissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIScrollView<UIScrollViewDelegate>

//셀이 움직이 멈췄을때
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //샐 가장 하단시 호출
   

    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >= scrollView.contentSize.height ) {
        NSLog(@"추가적으로 내용을 더 넣습니다");
        NSArray *tempList = [[NSArray alloc] initWithArray:_dataList.copy];
        [_dataList addObjectsFromArray:tempList];
       // [self refreshList];
    
        /*
        [[RequestObject sharedInstance] sendToServer:@"/api/post/list/"
                                              option:@"POST"
                                          parameters:parameters
                                             success:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                 
                                             }
                                                fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                    
                                                }];
        
        */
        
        NSLog(@"--------------------------------");
    }
    
    
}


@end
