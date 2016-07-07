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

@interface MostCommentedCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *dataList;

@end

@implementation MostCommentedCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    //로그인성공시 처리
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addCellData)
                                                 name:MostCommentdListLoadSuccess
                                               object:nil];

    [self setttingDataList];
    
}


-(void) setttingDataList{
    self.dataList = @[@"http://i.imgur.com/fmckBDO.jpg",
                      @"http://fansta.net/data/editor/1510/3732507908_562f410b7e18b_14459374195165",
                      @"http://photo.jtbc.joins.com/news/2015/12/30/201512301208328789.jpg",
                      @"http://file2.instiz.net/data/file2/2016/01/18/c/0/7/c07e8aa653757d742d2f3b043b559592.jpg",
                      @"https://pbs.twimg.com/profile_images/683106307985903616/_DfSOjZt.jpg",
                      @"http://file2.instiz.net/data/cached_img/upload/2015/11/12/15/f7ae4cf4ce49c5141e0506b6650812d7.jpg"].copy;
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell
    UIImageView *imageView = [[UIImageView alloc]init];
    NSURL *urlString = [NSURL URLWithString:self.dataList[indexPath.row]];
    [imageView sd_setImageWithURL:urlString];
    imageView.frame = cell.bounds;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:imageView];
    
    cell.backgroundColor = UIColorFromRGB(0x000000, 0.8);
    
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((self.view.frame.size.width/2)-10, 130);
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


// Uncomment this method to specify if the specified item should be selected

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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


-(void) addCellData{
    [self.dataList addObjectsFromArray: [RequestObject sharedInstance].mostCommentedList];
    [self.collectionView reloadData];
}

@end
