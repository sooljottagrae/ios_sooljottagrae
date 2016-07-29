//
//  WritePostViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 13..
//  Copyright © 2016년 alcoholic. All rights reserved.
//


#import "WritePostViewController.h"
#import "RequestObject.h"
#import "UserObject.h"
#import "CommentsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@import ImageIO;
@import AssetsLibrary;


@interface WritePostViewController ()

@property (nonatomic) NSDictionary *tags;

@property (nonatomic, weak) IBOutlet UIView *textBorderView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextView *inputTextView;
@property (nonatomic) NSDictionary *outputData;

@property (nonatomic, strong) UIView *pickerSuperView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic) NSString *selectedBtnTitle;

@property (nonatomic) NSString *selectedTag;
@property (nonatomic, weak) IBOutlet UILabel *selectedAlcoholTag;
@property (nonatomic, weak) IBOutlet UILabel *selectedFoodTag;
@property (nonatomic, weak) IBOutlet UILabel *selectedLocationTag;


@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (nonatomic, weak) IBOutlet UILabel *adressLabel;

@property (nonatomic, weak) IBOutlet UIView *tapView;


//fileName
@property (strong, nonatomic) NSString *pickedFileName;

@property (strong, nonatomic) IBOutlet UIButton *exitBtn;

@property (strong, nonatomic) NSString *postedUserId;

@property NSInteger commentsCount;


@property (strong, nonatomic) IBOutlet UIButton *alcoholBtn;

@property (strong, nonatomic) IBOutlet UIButton *foodBtn;
@property (strong, nonatomic) IBOutlet UIButton *locationBtn;

@property (strong, nonatomic) UIButton *postBtn;


@property (strong, nonatomic) NSMutableArray *commentList;

@end

@implementation WritePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tags = @{@"술" : @[@"소주", @"맥주", @"양주", @"소맥", @"칵테일", @"6", @"7", @"8"],
                  @"안주" : @[@"치킨", @"족발", @"국밥", @"마른안주", @"감자탕", @"삼겹살", @"회"],
                  @"장소" : @[@"강남", @"여의도", @"동대문", @"이태원", @"가로수길", @"압구정로데오", @"신촌", @"홍대", @"삼성"]};
    
    [[self.textBorderView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.textBorderView layer] setBorderWidth:1];
    [[self.textBorderView layer] setCornerRadius:15];
    
    [self.imageView setImage:[UIImage imageNamed:@"imageSampleInput"]];
    
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapped:)];
    //tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:tapGesture];
    
    self.pickerSuperView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2)];
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    [self.pickerSuperView addSubview:self.pickerView];
    self.toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [self.toolbar setBackgroundColor:THEMA_BG_COLOR];
    [self.pickerSuperView addSubview:self.toolbar];
    self.doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 0, 60, 40)];
    [self.doneBtn setTitle:@"완료" forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(doneBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerSuperView addSubview:self.doneBtn];

    
    
    UITapGestureRecognizer *dismissKeyBoard;
    dismissKeyBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard:)];
    //tapGesture.delegate = self;
    dismissKeyBoard.numberOfTapsRequired = 1;
    
    
    ////////////////////////////////////////////////////////////////////////
    //강준
    ////////////////////////////////////////////////////////////////////////
    
    //페이크 네비게이션을 바를 준다.
    UIView *fakeNaviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    fakeNaviView.backgroundColor = THEMA_BG_COLOR;
    
    //백버튼
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(8, 22, 60, 30)];
    [backButton setTitle:@"< Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [fakeNaviView addSubview:backButton];
    
    
    //포스팅 버튼
    UIButton *postButton = [[UIButton alloc]initWithFrame:CGRectMake(fakeNaviView.frame.size.width-38, 22, 30, 30)];
    UIImage *penImage = [UIImage imageNamed:@"write-icon"];
    [postButton setImage:penImage forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(exitBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.postBtn = postButton;
    [fakeNaviView addSubview:postButton];
    [self.view addSubview:fakeNaviView];
    
    self.exitBtn.hidden=YES;
    
    //태그 데이터 수정
    [self loadTagList];
    
    //서버에서 포스팅 정보를 불러온다.
    if(self.url != nil && [self.url length] > 0){
        
        [self loadDataFromServer];
    }
    
    
    
    ////////////////////////////////////////////////////////////////////////
    
    [self.tapView setFrame:CGRectMake(0, 60, self.view.frame.size.width, self.tapView.frame.size.height)];
    [self.tapView addGestureRecognizer:dismissKeyBoard];
    

    
    
    // Do any additional setup after loading the view.
}
/////////////////////////////////////////////////////////////////////////////////
// 강준
////////////////////////////////////////////////////////////////////////////////
-(IBAction) clickedBackButton:(id) sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//서버에서 부터 포스팅 정보를 불러온다
-(void) loadDataFromServer{
    [[RequestObject sharedInstance] sendToServer:self.url option:@"GET" parameters:nil success:^(NSURLResponse *response, id responseObject, NSError *error) {
        //성공시
        if(responseObject != nil){
            [self settingLoad:responseObject];
        }
    } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
        //실패시
    } useAuth:YES];
}

//불러온 정보를 화면에 셋팅한다.(단, 수정 가능한 사람인지 체크 후
-(void) settingLoad:(id) object{
    NSDictionary *dictForUser = [object objectForKey:@"user"];
    self.postedUserId = [dictForUser objectForKey:@"email"];
    
    self.commentList = [NSMutableArray arrayWithArray:[[object objectForKey:@"comments"] copy]];
    
    self.commentsCount = self.commentList.count;
    
    //image 셋팅
    NSString *url = [object objectForKey:@"image"];
    
    if([url isKindOfClass:NSString.class] && [url length] > 0){
        
    
        NSURL *imageUrl = [NSURL URLWithString:url];
        __weak UIImageView *weakImageView = self.imageView;
        
        [self.imageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage new] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    }else{
        self.imageView.image = [UIImage imageNamed:@"No_Image_Available.png"];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    //태그셋팅
    NSMutableDictionary *alcoholTag, *foodTag, *placeTag;
    NSString *alcoholName, *foodName, *placeName;
    
    if([[object objectForKey:@"alcohol_tag"] count] > 0){
        alcoholTag  = [object objectForKey:@"alcohol_tag"][0];
    }
    if([[object objectForKey:@"food_tag"] count] > 0){
        foodTag     = [object objectForKey:@"food_tag"][0];
    }
    
    if([[object objectForKey:@"place_tag"] count] > 0){
        placeTag    = [object objectForKey:@"place_tag"][0];
    }
    
    
    if([[alcoholTag objectForKey:@"alcohol_name"] length] > 0){
        alcoholName = [alcoholTag objectForKey:@"alcohol_name"];
    }
    if([[foodTag objectForKey:@"food_name"] length] > 0){
        foodName    = [foodTag objectForKey:@"food_name"];
    }
    if([[placeTag objectForKey:@"place_name"] length] > 0){
            placeName   = [placeTag objectForKey:@"place_name"];
    }
    
    self.selectedAlcoholTag.text = alcoholName;
    self.selectedFoodTag.text = foodName;
    self.selectedLocationTag.text = placeName;
    
    
    //글 셋팅
    self.inputTextView.text = [object objectForKey:@"content"];
    
    
    if([[UserObject sharedInstance].userEmail isEqualToString:self.postedUserId]){
        [self.postBtn addTarget:self action:@selector(editPost:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }else{
        self.postBtn.enabled = NO;
        self.postBtn.imageView.alpha = 0;
        self.alcoholBtn.hidden = YES;
        self.foodBtn.hidden = YES;
        self.locationBtn.hidden = YES;
        self.inputTextView.editable = NO;
        self.imageView.userInteractionEnabled = NO;
    }
    


    [self commentsViewLoad];
    
    

}

-(void) commentsViewLoad{
    UIView *commentsView = [[UIView alloc]initWithFrame:CGRectMake(0, 60+self.tapView.frame.size.height, self.view.frame.size.width, 80)];
    
    UILabel *showLabel = [[UILabel alloc]initWithFrame:CGRectMake(18, 0, 200, 80)];
    
    
    [showLabel setText:[NSString stringWithFormat:@"코멘트 갯수 : %ld",self.commentsCount]];
    
    UIButton *showCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(commentsView.frame.size.width-90, 0, 90, 80)];
    [showCommentButton addTarget:self action:@selector(showCommentsView:) forControlEvents:UIControlEventTouchUpInside];
    [showCommentButton setTitle:@"댓글 보기" forState:UIControlStateNormal];
    [showCommentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [commentsView addSubview:showLabel];
    [commentsView addSubview:showCommentButton];
    
    [self.view addSubview:commentsView];

}

-(void) loadTagList{
//    [[RequestObject sharedInstance] sendToServer:@"/api/tags/alchol/"
//                                          option:@"GET"
//                                      parameters:nil
//     
//                                         success:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                             
//                                         }
//                                            fail:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                                
//                                            } useAuth:NO];
//    
//    
//    [[RequestObject sharedInstance] sendToServer:@"/api/tags/food/"
//                                          option:@"GET"
//                                      parameters:nil
//     
//                                         success:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                             
//                                         }
//                                            fail:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                                
//                                            } useAuth:NO];
//    
//    [[RequestObject sharedInstance] sendToServer:@"/api/tags/place/"
//                                          option:@"GET"
//                                      parameters:nil
//     
//                                         success:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                             
//                                         }
//                                            fail:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                                
//                                            } useAuth:NO];
    
    NSArray *alcholTag, *foodTag, *placeTag;
    
    alcholTag = @[
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/1/",
                      @"id": @(1),
                      @"alcohol_name": @"소주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/2/",
                      @"id": @(2),
                      @"alcohol_name": @"참이슬"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/3/",
                      @"id": @(3),
                      @"alcohol_name": @"처음처럼"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/4/",
                      @"id": @(4),
                      @"alcohol_name": @"참이슬레드"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/5/",
                      @"id": @(5),
                      @"alcohol_name": @"맥주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/6/",
                      @"id": @(6),
                      @"alcohol_name": @"카스"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/7/",
                      @"id": @(7),
                      @"alcohol_name": @"하이트"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/8/",
                      @"id": @(8),
                      @"alcohol_name": @"맥스"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/9/",
                      @"id": @(9),
                      @"alcohol_name": @"클라우드"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/10/",
                      @"id": @(10),
                      @"alcohol_name": @"호가든"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/11/",
                      @"id": @(11),
                      @"alcohol_name": @"칭따오"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/12/",
                      @"id": @(12),
                      @"alcohol_name": @"레벤브로이"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/13/",
                      @"id": @(13),
                      @"alcohol_name": @"기네스"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/14/",
                      @"id": @(14),
                      @"alcohol_name": @"하이네켄"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/15/",
                      @"id": @(15),
                      @"alcohol_name": @"버드와이저"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/16/",
                      @"id": @(16),
                      @"alcohol_name": @"밀러"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/17/",
                      @"id": @(17),
                      @"alcohol_name": @"아사히"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/18/",
                      @"id": @(18),
                      @"alcohol_name": @"산토리"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/19/",
                      @"id": @(19),
                      @"alcohol_name": @"기린"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/20/",
                      @"id": @(20),
                      @"alcohol_name": @"수제맥주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/21/",
                      @"id": @(21),
                      @"alcohol_name": @"양주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/22/",
                      @"id": @(22),
                      @"alcohol_name": @"칵테일"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/23/",
                      @"id": @(23),
                      @"alcohol_name": @"탁주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/24/",
                      @"id": @(24),
                      @"alcohol_name": @"청주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/25/",
                      @"id": @(25),
                      @"alcohol_name": @"과실주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/26/",
                      @"id": @(26),
                      @"alcohol_name": @"와인"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/27/",
                      @"id": @(27),
                      @"alcohol_name": @"사케"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/28/",
                      @"id": @(28),
                      @"alcohol_name": @"소맥"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/29/",
                      @"id": @(29),
                      @"alcohol_name": @"막걸리"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/30/",
                      @"id": @(30),
                      @"alcohol_name": @"보드카"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/31/",
                      @"id": @(31),
                      @"alcohol_name": @"위스키"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/32/",
                      @"id": @(32),
                      @"alcohol_name": @"럼"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/33/",
                      @"id": @(33),
                      @"alcohol_name": @"진"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/34/",
                      @"id": @(34),
                      @"alcohol_name": @"산그리아"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/35/",
                      @"id": @(35),
                      @"alcohol_name": @"소막사"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/36/",
                      @"id": @(36),
                      @"alcohol_name": @"동동주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/37/",
                      @"id": @(37),
                      @"alcohol_name": @"백세주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/38/",
                      @"id": @(38),
                      @"alcohol_name": @"예거밤"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/39/",
                      @"id": @(39),
                      @"alcohol_name": @"산미구엘"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/40/",
                      @"id": @(40),
                      @"alcohol_name": @"끌라라"
                      }
                  ];
    foodTag = @[
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/2/",
                    @"id": @(2),
                    @"food_name": @"전"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/3/",
                    @"id": @(3),
                    @"food_name": @"대창"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/4/",
                    @"id": @(4),
                    @"food_name": @"곱창"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/5/",
                    @"id": @(5),
                    @"food_name": @"족발"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/6/",
                    @"id": @(6),
                    @"food_name": @"파전"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/7/",
                    @"id": @(7),
                    @"food_name": @"골뱅이무침"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/8/",
                    @"id": @(8),
                    @"food_name": @"치킨"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/9/",
                    @"id": @(9),
                    @"food_name": @"오징어회"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/10/",
                    @"id": @(10),
                    @"food_name": @"피자"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/11/",
                    @"id": @(11),
                    @"food_name": @"육회"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/12/",
                    @"id": @(12),
                    @"food_name": @"육사시미"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/13/",
                    @"id": @(13),
                    @"food_name": @"삼겹살"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/14/",
                    @"id": @(14),
                    @"food_name": @"와규"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/15/",
                    @"id": @(15),
                    @"food_name": @"감자칩"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/16/",
                    @"id": @(16),
                    @"food_name": @"육포"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/17/",
                    @"id": @(17),
                    @"food_name": @"쥐포"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/18/",
                    @"id": @(18),
                    @"food_name": @"김치찌개"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/19/",
                    @"id": @(19),
                    @"food_name": @"부대찌개"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/20/",
                    @"id": @(20),
                    @"food_name": @"라면"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/21/",
                    @"id": @(21),
                    @"food_name": @"소세지"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/22/",
                    @"id": @(22),
                    @"food_name": @"계란찜"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/23/",
                    @"id": @(23),
                    @"food_name": @"타코"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/24/",
                    @"id": @(24),
                    @"food_name": @"양념치킨"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/25/",
                    @"id": @(25),
                    @"food_name": @"후라이드"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/26/",
                    @"id": @(26),
                    @"food_name": @"간장치킨"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/27/",
                    @"id": @(27),
                    @"food_name": @"마늘치킨"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/28/",
                    @"id": @(28),
                    @"food_name": @"랍스터"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/29/",
                    @"id": @(29),
                    @"food_name": @"치즈"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/30/",
                    @"id": @(30),
                    @"food_name": @"모짜렐라"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/31/",
                    @"id": @(31),
                    @"food_name": @"오징어"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/32/",
                    @"id": @(32),
                    @"food_name": @"파스타"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/33/",
                    @"id": @(33),
                    @"food_name": @"알리올리오"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/34/",
                    @"id": @(34),
                    @"food_name": @"골뱅이소면"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/35/",
                    @"id": @(35),
                    @"food_name": @"닭꼬치"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/36/",
                    @"id": @(36),
                    @"food_name": @"양꼬치"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/37/",
                    @"id": @(37),
                    @"food_name": @"참치"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/38/",
                    @"id": @(38),
                    @"food_name": @"샐러드"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/39/",
                    @"id": @(39),
                    @"food_name": @"물회"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/40/",
                    @"id": @(40),
                    @"food_name": @"초밥"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/41/",
                    @"id": @(41),
                    @"food_name": @"토리야끼"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/42/",
                    @"id": @(42),
                    @"food_name": @"타코야끼"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/43/",
                    @"id": @(43),
                    @"food_name": @"가라아케"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/44/",
                    @"id": @(44),
                    @"food_name": @"오꼬노미야끼"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/45/",
                    @"id": @(45),
                    @"food_name": @"조개구이"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/46/",
                    @"id": @(46),
                    @"food_name": @"꼬막"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/47/",
                    @"id": @(47),
                    @"food_name": @"튀김"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/48/",
                    @"id": @(48),
                    @"food_name": @"떡볶이"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/49/",
                    @"id": @(49),
                    @"food_name": @"순대"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/50/",
                    @"id": @(50),
                    @"food_name": @"백합"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/51/",
                    @"id": @(51),
                    @"food_name": @"나쵸"
                    }
                ];
    placeTag = @[
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/1/",
                     @"id": @(1),
                     @"place_name": @"강남역"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/3/",
                     @"id": @(3),
                     @"place_name": @"가로수길"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/4/",
                     @"id": @(4),
                     @"place_name": @"신사"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/5/",
                     @"id": @(5),
                     @"place_name": @"압구정"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/6/",
                     @"id": @(6),
                     @"place_name": @"청담동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/7/",
                     @"id": @(7),
                     @"place_name": @"신천"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/8/",
                     @"id": @(8),
                     @"place_name": @"잠실"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/9/",
                     @"id": @(9),
                     @"place_name": @"여의도"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/10/",
                     @"id": @(10),
                     @"place_name": @"역삼"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/11/",
                     @"id": @(11),
                     @"place_name": @"선릉"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/12/",
                     @"id": @(12),
                     @"place_name": @"교대"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/13/",
                     @"id": @(13),
                     @"place_name": @"서초"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/14/",
                     @"id": @(14),
                     @"place_name": @"삼성동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/15/",
                     @"id": @(15),
                     @"place_name": @"논현동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/16/",
                     @"id": @(16),
                     @"place_name": @"서래마을"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/17/",
                     @"id": @(17),
                     @"place_name": @"동작"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/18/",
                     @"id": @(18),
                     @"place_name": @"사당"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/19/",
                     @"id": @(19),
                     @"place_name": @"방배"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/20/",
                     @"id": @(20),
                     @"place_name": @"반포"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/21/",
                     @"id": @(21),
                     @"place_name": @"잠원"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/22/",
                     @"id": @(22),
                     @"place_name": @"관악구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/23/",
                     @"id": @(23),
                     @"place_name": @"영등포구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/24/",
                     @"id": @(24),
                     @"place_name": @"송파"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/25/",
                     @"id": @(25),
                     @"place_name": @"가락"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/26/",
                     @"id": @(26),
                     @"place_name": @"대치동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/27/",
                     @"id": @(27),
                     @"place_name": @"강남"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/28/",
                     @"id": @(28),
                     @"place_name": @"도곡동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/29/",
                     @"id": @(29),
                     @"place_name": @"양재동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/30/",
                     @"id": @(30),
                     @"place_name": @"구로구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/31/",
                     @"id": @(31),
                     @"place_name": @"목동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/32/",
                     @"id": @(32),
                     @"place_name": @"양천"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/33/",
                     @"id": @(33),
                     @"place_name": @"방이동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/34/",
                     @"id": @(34),
                     @"place_name": @"강동구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/35/",
                     @"id": @(35),
                     @"place_name": @"개포"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/36/",
                     @"id": @(36),
                     @"place_name": @"강서"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/37/",
                     @"id": @(37),
                     @"place_name": @"금천구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/38/",
                     @"id": @(38),
                     @"place_name": @"홍대"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/39/",
                     @"id": @(39),
                     @"place_name": @"이태원"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/40/",
                     @"id": @(40),
                     @"place_name": @"광화문"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/41/",
                     @"id": @(41),
                     @"place_name": @"신촌"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/42/",
                     @"id": @(42),
                     @"place_name": @"마포"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/43/",
                     @"id": @(43),
                     @"place_name": @"종로"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/44/",
                     @"id": @(44),
                     @"place_name": @"혜화"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/45/",
                     @"id": @(45),
                     @"place_name": @"건대"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/46/",
                     @"id": @(46),
                     @"place_name": @"명동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/47/",
                     @"id": @(47),
                     @"place_name": @"인사동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/48/",
                     @"id": @(48),
                     @"place_name": @"중구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/49/",
                     @"id": @(49),
                     @"place_name": @"시청"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/50/",
                     @"id": @(50),
                     @"place_name": @"왕십리"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/51/",
                     @"id": @(51),
                     @"place_name": @"강북"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/52/",
                     @"id": @(52),
                     @"place_name": @"용산"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/53/",
                     @"id": @(53),
                     @"place_name": @"노원"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/54/",
                     @"id": @(54),
                     @"place_name": @"수유"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/55/",
                     @"id": @(55),
                     @"place_name": @"동대문구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/56/",
                     @"id": @(56),
                     @"place_name": @"은평구"
                     }                 ];
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    NSInteger idx = 0;
    for(NSDictionary *item in alcholTag){
        NSString *name = [item objectForKey:@"alcohol_name"];
        if([name isKindOfClass:NSString.class] && [name length] > 0){
            [tempArray addObject:name];
        }
    }
    [tempDict setObject:tempArray.copy forKey:@"술"];
    tempArray = [[NSMutableArray alloc]init];
    
    idx = 0;
    for(NSDictionary *item in foodTag){
        NSString *name = [item objectForKey:@"food_name"];
        if([name isKindOfClass:NSString.class] && [name length] > 0){
            [tempArray addObject:name];
        }
    }
    
    [tempDict setObject:tempArray.copy forKey:@"안주"];
    tempArray = [[NSMutableArray alloc]init];
    
    idx = 0;
    for(NSDictionary *item in placeTag){
        NSString *name = [item objectForKey:@"place_name"];
        if([name isKindOfClass:NSString.class] && [name length] > 0){
            [tempArray addObject:name];
        }
    }
    
    [tempDict setObject:tempArray.copy forKey:@"장소"];
    tempArray = nil;
    
    NSLog(@"%@",tempDict);
    
    self.tags = tempDict.mutableCopy;
}

-(NSNumber *) getTagId:(NSString *)name tag:(NSString *)tagName{
    NSArray *alcholTag, *foodTag, *placeTag;
    
    alcholTag = @[
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/1/",
                      @"id": @(1),
                      @"alcohol_name": @"소주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/2/",
                      @"id": @(2),
                      @"alcohol_name": @"참이슬"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/3/",
                      @"id": @(3),
                      @"alcohol_name": @"처음처럼"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/4/",
                      @"id": @(4),
                      @"alcohol_name": @"참이슬레드"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/5/",
                      @"id": @(5),
                      @"alcohol_name": @"맥주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/6/",
                      @"id": @(6),
                      @"alcohol_name": @"카스"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/7/",
                      @"id": @(7),
                      @"alcohol_name": @"하이트"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/8/",
                      @"id": @(8),
                      @"alcohol_name": @"맥스"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/9/",
                      @"id": @(9),
                      @"alcohol_name": @"클라우드"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/10/",
                      @"id": @(10),
                      @"alcohol_name": @"호가든"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/11/",
                      @"id": @(11),
                      @"alcohol_name": @"칭따오"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/12/",
                      @"id": @(12),
                      @"alcohol_name": @"레벤브로이"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/13/",
                      @"id": @(13),
                      @"alcohol_name": @"기네스"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/14/",
                      @"id": @(14),
                      @"alcohol_name": @"하이네켄"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/15/",
                      @"id": @(15),
                      @"alcohol_name": @"버드와이저"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/16/",
                      @"id": @(16),
                      @"alcohol_name": @"밀러"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/17/",
                      @"id": @(17),
                      @"alcohol_name": @"아사히"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/18/",
                      @"id": @(18),
                      @"alcohol_name": @"산토리"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/19/",
                      @"id": @(19),
                      @"alcohol_name": @"기린"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/20/",
                      @"id": @(20),
                      @"alcohol_name": @"수제맥주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/21/",
                      @"id": @(21),
                      @"alcohol_name": @"양주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/22/",
                      @"id": @(22),
                      @"alcohol_name": @"칵테일"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/23/",
                      @"id": @(23),
                      @"alcohol_name": @"탁주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/24/",
                      @"id": @(24),
                      @"alcohol_name": @"청주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/25/",
                      @"id": @(25),
                      @"alcohol_name": @"과실주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/26/",
                      @"id": @(26),
                      @"alcohol_name": @"와인"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/27/",
                      @"id": @(27),
                      @"alcohol_name": @"사케"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/28/",
                      @"id": @(28),
                      @"alcohol_name": @"소맥"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/29/",
                      @"id": @(29),
                      @"alcohol_name": @"막걸리"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/30/",
                      @"id": @(30),
                      @"alcohol_name": @"보드카"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/31/",
                      @"id": @(31),
                      @"alcohol_name": @"위스키"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/32/",
                      @"id": @(32),
                      @"alcohol_name": @"럼"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/33/",
                      @"id": @(33),
                      @"alcohol_name": @"진"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/34/",
                      @"id": @(34),
                      @"alcohol_name": @"산그리아"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/35/",
                      @"id": @(35),
                      @"alcohol_name": @"소막사"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/36/",
                      @"id": @(36),
                      @"alcohol_name": @"동동주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/37/",
                      @"id": @(37),
                      @"alcohol_name": @"백세주"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/38/",
                      @"id": @(38),
                      @"alcohol_name": @"예거밤"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/39/",
                      @"id": @(39),
                      @"alcohol_name": @"산미구엘"
                      },
                  @{
                      @"url": @"https://sooljotta.com/api/tags/alcohol/40/",
                      @"id": @(40),
                      @"alcohol_name": @"끌라라"
                      }
                ];
    foodTag = @[
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/2/",
                    @"id": @(2),
                    @"food_name": @"전"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/3/",
                    @"id": @(3),
                    @"food_name": @"대창"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/4/",
                    @"id": @(4),
                    @"food_name": @"곱창"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/5/",
                    @"id": @(5),
                    @"food_name": @"족발"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/6/",
                    @"id": @(6),
                    @"food_name": @"파전"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/7/",
                    @"id": @(7),
                    @"food_name": @"골뱅이무침"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/8/",
                    @"id": @(8),
                    @"food_name": @"치킨"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/9/",
                    @"id": @(9),
                    @"food_name": @"오징어회"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/10/",
                    @"id": @(10),
                    @"food_name": @"피자"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/11/",
                    @"id": @(11),
                    @"food_name": @"육회"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/12/",
                    @"id": @(12),
                    @"food_name": @"육사시미"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/13/",
                    @"id": @(13),
                    @"food_name": @"삼겹살"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/14/",
                    @"id": @(14),
                    @"food_name": @"와규"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/15/",
                    @"id": @(15),
                    @"food_name": @"감자칩"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/16/",
                    @"id": @(16),
                    @"food_name": @"육포"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/17/",
                    @"id": @(17),
                    @"food_name": @"쥐포"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/18/",
                    @"id": @(18),
                    @"food_name": @"김치찌개"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/19/",
                    @"id": @(19),
                    @"food_name": @"부대찌개"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/20/",
                    @"id": @(20),
                    @"food_name": @"라면"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/21/",
                    @"id": @(21),
                    @"food_name": @"소세지"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/22/",
                    @"id": @(22),
                    @"food_name": @"계란찜"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/23/",
                    @"id": @(23),
                    @"food_name": @"타코"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/24/",
                    @"id": @(24),
                    @"food_name": @"양념치킨"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/25/",
                    @"id": @(25),
                    @"food_name": @"후라이드"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/26/",
                    @"id": @(26),
                    @"food_name": @"간장치킨"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/27/",
                    @"id": @(27),
                    @"food_name": @"마늘치킨"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/28/",
                    @"id": @(28),
                    @"food_name": @"랍스터"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/29/",
                    @"id": @(29),
                    @"food_name": @"치즈"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/30/",
                    @"id": @(30),
                    @"food_name": @"모짜렐라"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/31/",
                    @"id": @(31),
                    @"food_name": @"오징어"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/32/",
                    @"id": @(32),
                    @"food_name": @"파스타"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/33/",
                    @"id": @(33),
                    @"food_name": @"알리올리오"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/34/",
                    @"id": @(34),
                    @"food_name": @"골뱅이소면"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/35/",
                    @"id": @(35),
                    @"food_name": @"닭꼬치"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/36/",
                    @"id": @(36),
                    @"food_name": @"양꼬치"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/37/",
                    @"id": @(37),
                    @"food_name": @"참치"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/38/",
                    @"id": @(38),
                    @"food_name": @"샐러드"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/39/",
                    @"id": @(39),
                    @"food_name": @"물회"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/40/",
                    @"id": @(40),
                    @"food_name": @"초밥"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/41/",
                    @"id": @(41),
                    @"food_name": @"토리야끼"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/42/",
                    @"id": @(42),
                    @"food_name": @"타코야끼"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/43/",
                    @"id": @(43),
                    @"food_name": @"가라아케"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/44/",
                    @"id": @(44),
                    @"food_name": @"오꼬노미야끼"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/45/",
                    @"id": @(45),
                    @"food_name": @"조개구이"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/46/",
                    @"id": @(46),
                    @"food_name": @"꼬막"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/47/",
                    @"id": @(47),
                    @"food_name": @"튀김"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/48/",
                    @"id": @(48),
                    @"food_name": @"떡볶이"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/49/",
                    @"id": @(49),
                    @"food_name": @"순대"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/50/",
                    @"id": @(50),
                    @"food_name": @"백합"
                    },
                @{
                    @"url": @"https://sooljotta.com/api/tags/food/51/",
                    @"id": @(51),
                    @"food_name": @"나쵸"
                }
                ];
    placeTag = @[
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/1/",
                     @"id": @(1),
                     @"place_name": @"강남역"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/3/",
                     @"id": @(3),
                     @"place_name": @"가로수길"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/4/",
                     @"id": @(4),
                     @"place_name": @"신사"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/5/",
                     @"id": @(5),
                     @"place_name": @"압구정"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/6/",
                     @"id": @(6),
                     @"place_name": @"청담동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/7/",
                     @"id": @(7),
                     @"place_name": @"신천"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/8/",
                     @"id": @(8),
                     @"place_name": @"잠실"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/9/",
                     @"id": @(9),
                     @"place_name": @"여의도"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/10/",
                     @"id": @(10),
                     @"place_name": @"역삼"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/11/",
                     @"id": @(11),
                     @"place_name": @"선릉"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/12/",
                     @"id": @(12),
                     @"place_name": @"교대"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/13/",
                     @"id": @(13),
                     @"place_name": @"서초"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/14/",
                     @"id": @(14),
                     @"place_name": @"삼성동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/15/",
                     @"id": @(15),
                     @"place_name": @"논현동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/16/",
                     @"id": @(16),
                     @"place_name": @"서래마을"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/17/",
                     @"id": @(17),
                     @"place_name": @"동작"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/18/",
                     @"id": @(18),
                     @"place_name": @"사당"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/19/",
                     @"id": @(19),
                     @"place_name": @"방배"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/20/",
                     @"id": @(20),
                     @"place_name": @"반포"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/21/",
                     @"id": @(21),
                     @"place_name": @"잠원"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/22/",
                     @"id": @(22),
                     @"place_name": @"관악구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/23/",
                     @"id": @(23),
                     @"place_name": @"영등포구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/24/",
                     @"id": @(24),
                     @"place_name": @"송파"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/25/",
                     @"id": @(25),
                     @"place_name": @"가락"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/26/",
                     @"id": @(26),
                     @"place_name": @"대치동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/27/",
                     @"id": @(27),
                     @"place_name": @"강남"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/28/",
                     @"id": @(28),
                     @"place_name": @"도곡동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/29/",
                     @"id": @(29),
                     @"place_name": @"양재동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/30/",
                     @"id": @(30),
                     @"place_name": @"구로구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/31/",
                     @"id": @(31),
                     @"place_name": @"목동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/32/",
                     @"id": @(32),
                     @"place_name": @"양천"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/33/",
                     @"id": @(33),
                     @"place_name": @"방이동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/34/",
                     @"id": @(34),
                     @"place_name": @"강동구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/35/",
                     @"id": @(35),
                     @"place_name": @"개포"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/36/",
                     @"id": @(36),
                     @"place_name": @"강서"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/37/",
                     @"id": @(37),
                     @"place_name": @"금천구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/38/",
                     @"id": @(38),
                     @"place_name": @"홍대"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/39/",
                     @"id": @(39),
                     @"place_name": @"이태원"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/40/",
                     @"id": @(40),
                     @"place_name": @"광화문"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/41/",
                     @"id": @(41),
                     @"place_name": @"신촌"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/42/",
                     @"id": @(42),
                     @"place_name": @"마포"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/43/",
                     @"id": @(43),
                     @"place_name": @"종로"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/44/",
                     @"id": @(44),
                     @"place_name": @"혜화"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/45/",
                     @"id": @(45),
                     @"place_name": @"건대"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/46/",
                     @"id": @(46),
                     @"place_name": @"명동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/47/",
                     @"id": @(47),
                     @"place_name": @"인사동"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/48/",
                     @"id": @(48),
                     @"place_name": @"중구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/49/",
                     @"id": @(49),
                     @"place_name": @"시청"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/50/",
                     @"id": @(50),
                     @"place_name": @"왕십리"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/51/",
                     @"id": @(51),
                     @"place_name": @"강북"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/52/",
                     @"id": @(52),
                     @"place_name": @"용산"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/53/",
                     @"id": @(53),
                     @"place_name": @"노원"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/54/",
                     @"id": @(54),
                     @"place_name": @"수유"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/55/",
                     @"id": @(55),
                     @"place_name": @"동대문구"
                     },
                 @{
                     @"url": @"https://sooljotta.com/api/tags/place/56/",
                     @"id": @(56),
                     @"place_name": @"은평구"
                     }                 ];
    
 
    
    
    if([tagName isEqualToString:@"alchol"]){
        for(NSDictionary *item in alcholTag){
            if([[item objectForKey:@"alcohol_name"] isEqualToString:name]){
                return [item objectForKey:@"id"];
            }
        }
    }
    
    
    if([tagName isEqualToString:@"food"]){
        for(NSDictionary *item in foodTag){
            if([[item objectForKey:@"food_name"] isEqualToString:name]){
                return [item objectForKey:@"id"];
            }
        }
    }
    

    if([tagName isEqualToString:@"place"]){
        for(NSDictionary *item in placeTag){
            if([[item objectForKey:@"place_name"] isEqualToString:name]){
                return [item objectForKey:@"id"];
            }
        }
    }
    
    return @(0);
}

-(IBAction)editPost:(id)sender{
    NSDictionary *parameters = @{@"content": self.inputTextView.text,
                                 @"alcohol_tag": [self getTagId:self.selectedAlcoholTag.text tag:@"alchol"],
                                 @"food_tag": [self getTagId:self.selectedFoodTag.text tag:@"food"],
                                 @"place_tag": [self getTagId:self.selectedLocationTag.text tag:@"place"]
                                 };
    
    NSString *fileName = @"edit.jpg";
    
    
    if([self checkNull] == YES){
        
        NSString *apiUrl = [NSString stringWithFormat:@"/api/posts/%@/edit/",self.postId];
        
        [[RequestObject sharedInstance] sendToServer:apiUrl option:@"PUT" parameters:parameters image:self.imageView.image fileName:fileName success:^(NSURLResponse *response, id responseObject, NSError *error) {
            //성공시
            [self popAlertTitle:@"알림창" message:@"수정 되었습니다."];
            [self dismissViewControllerAnimated:YES completion:nil];
        } progress:^(NSProgress *uploadProgress) {
            //현재 업로드 상태
        } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
            //실패시
            if([[responseObject objectForKey:@"content"] isEqualToString:@"This field may not be blank."]){
                [self popAlertTitle:@"에러메세지" message:@"입력되지 않는 항목이 있습니다. 다시 확인하여 주십시오."];
            }
            
        } useAuth:YES];
    }else{
        [self popAlertTitle:@"에러메세지" message:@"입력되지 않는 항목이 있습니다. 다시 확인하여 주십시오."];
    }

}

-(IBAction) showCommentsView:(id)sender{
    NSLog(@"clicked showCommentView");
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
                        
    
    CommentsViewController * controller = [stb instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    
    controller.commentList = self.commentList;
    controller.url = self.url;
    
    [self presentViewController:controller animated:YES completion:nil];
    
}


////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *arr;
    arr=[self.tags objectForKey:self.selectedBtnTitle];
    return arr.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.tags objectForKey:self.selectedBtnTitle][row];
}

- (IBAction)alcoholBtn:(id)sender {
    self.selectedBtnTitle = @"술";
    [self addPickerView];
    
}
- (IBAction)foodBtn:(id)sender {
    self.selectedBtnTitle = @"안주";
    [self addPickerView];
}
- (IBAction)locationBtn:(id)sender {
    self.selectedBtnTitle = @"장소";
    [self addPickerView];
}

- (void) doneBtn:(UIGestureRecognizer *)sender {
    self.selectedTag=[self.tags objectForKey:self.selectedBtnTitle][[self.pickerView selectedRowInComponent:0]];
    
    if ([self.selectedBtnTitle  isEqual: @"술"])
        self.selectedAlcoholTag.text=self.selectedTag;
    else if ([self.selectedBtnTitle  isEqual: @"안주"])
        self.selectedFoodTag.text=self.selectedTag;
    else if ([self.selectedBtnTitle  isEqual: @"장소"])
        self.selectedLocationTag.text=self.selectedTag;
    
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.pickerSuperView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2);
                     }
                     completion:^(BOOL finished){
                         [self.pickerSuperView removeFromSuperview];
                     }];
    //self.pickerSuperView.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2);

}

- (void)addPickerView {
    [self.pickerView setDelegate:self];
    [self.view addSubview:self.pickerSuperView];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.pickerSuperView.frame=CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2);
                     }
                     completion:nil];
}



- (void) gestureTapped:(UIGestureRecognizer *)sender {
    NSLog(@"tapped");
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)dismissKeyBoard:(UIGestureRecognizer *)sender {
    NSLog(@"dismissKeyBoard");
    [self.view endEditing:YES];
    
}

- (void)setPostingImage {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    /*
    NSData *postingImageData = UIImagePNGRepresentation(self.imageView.image);
    CGImageSourceRef source = CGImageSourceCreateWithData((CFMutableDataRef)postingImageData, NULL);
    NSDictionary *metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,NULL));

    NSLog(@"image data %@", metadata);
    */
    NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    if(referenceURL) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            NSDictionary *metadata = rep.metadata;
            self.latitude = [[[metadata objectForKey:@"{GPS}"] objectForKey:@"Latitude"] floatValue];
            self.longitude = [[[metadata objectForKey:@"{GPS}"] objectForKey:@"Longitude"] floatValue];
           
            //파일이름 셋팅
            self.pickedFileName = [rep filename];
            
            [self printAdress];
            
            NSLog(@"%@", [metadata objectForKey:@"{GPS}"]);
            
        } failureBlock:^(NSError *error) {
            // error handling
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)exitBtn:(id)sender {
    NSData *postingImageData = UIImagePNGRepresentation(self.imageView.image);
    /*
    self.outputData = [[NSDictionary alloc] initWithObjectsAndKeys:
                       //postingImageData, @"postingImage",
                       self.inputTextView.text, @"postingText",
                       self.selectedAlcoholTag.text, @"alcoholtag",
                       self.selectedFoodTag.text, @"foodtag",
                       self.selectedLocationTag.text, @"locationtag",  nil];
     */
    
//    self.outputData = [[NSDictionary alloc] initWithObjectsAndKeys:self.inputTextView.text, @"content", @"Hi", @"title", nil];
//    NSLog(@"%@", self.outputData);
    
//    [[RequestObject sharedInstance] sendToServer:@"/api/posts/create/"
//     
//                                      parameters:self.outputData
//                                           image:self.imageView.image
//                                        fileName:@"filename"
//                                         success:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                            NSLog(@"%@",response);
//                                         }
//                                        progress:^(NSProgress * _Nonnull uploadProgress) {
//                                            NSLog(@"sending...");
//                                        }
//                                            fail:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                            NSLog(@"%@",response);
//                                            } useAuth:YES];
    NSDictionary *parameters = @{@"content": self.inputTextView.text,
                                 @"alcohol_tag": [self getTagId:self.selectedAlcoholTag.text tag:@"alchol"],
                                 @"food_tag": [self getTagId:self.selectedFoodTag.text tag:@"food"],
                                 @"place_tag": [self getTagId:self.selectedLocationTag.text tag:@"place"]
                                 };
    
    NSString *fileName = self.pickedFileName == nil ? @"edit.jpg" : self.pickedFileName;
    
    NSString *url = @"/api/posts/create/";
    NSString *option = @"POST";
    
    if([self.postId isKindOfClass:NSString.class] && [self.postId length] > 0){
        url = [NSString stringWithFormat:@"/api/posts/%@/edit/",self.postId];
        option = @"PUT";
    }
    
    if([self checkNull] == YES){
        
        [[RequestObject sharedInstance] sendToServer:url option:option parameters:parameters image:self.imageView.image fileName:fileName success:^(NSURLResponse *response, id responseObject, NSError *error) {
            //성공시
            [self dismissViewControllerAnimated:YES completion:nil];
        } progress:^(NSProgress *uploadProgress) {
            //현재 업로드 상태
        } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
            //실패시
            if([[responseObject objectForKey:@"content"] isEqualToString:@"This field may not be blank."]){
                [self popAlertTitle:@"에러메세지" message:@"입력되지 않는 항목이 있습니다. 다시 확인하여 주십시오."];
            }
            if(responseObject == nil){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSInteger returnCode = httpResponse.statusCode;
                
                [self popAlertTitle:@"에러메세지" message:[NSString stringWithFormat:@"오류 : %ld\n잠시후 다시 시도하십시오.",returnCode]];
            }
            
        } useAuth:YES];
    }else{
        [self popAlertTitle:@"에러메세지" message:@"입력되지 않는 항목이 있습니다. 다시 확인하여 주십시오."];
    }

    
    //[self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL) checkNull{
    
    if(self.imageView.image == nil){
        return NO;
    }
    
    if([self.selectedAlcoholTag.text length] == 0 || [self.selectedAlcoholTag.text isEqualToString:@"태그 선택"]){
        return NO;
    }
    
    if([self.selectedFoodTag.text length] == 0 || [self.selectedFoodTag.text isEqualToString:@"태그 선택"]){
        return NO;
    }
    
    if([self.selectedLocationTag.text length] == 0 || [self.selectedLocationTag.text isEqualToString:@"태그 선택"]){
        return NO;
    }
    
    return YES;
}

//메세지 출력
-(void)popAlertTitle:(NSString *)title message:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:nil];
    
    
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}



- (void) printAdress {
    MKReverseGeocoder *reverseGeocoder;
    CLLocationCoordinate2D cordInfo = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:cordInfo];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"MKReverseGeocoder has failed.");
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    MKPlacemark * myPlacemark = placemark;
    NSString *city = myPlacemark.thoroughfare;
    NSString *subThrough=myPlacemark.subThoroughfare;
    NSString *locality=myPlacemark.locality;
    NSString *subLocality=myPlacemark.subLocality;
    NSString *adminisArea=myPlacemark.administrativeArea;
    NSString *subAdminArea=myPlacemark.subAdministrativeArea;
    NSString *postalCode=myPlacemark.postalCode;
    NSString *country=myPlacemark.country;
    NSString *countryCode=myPlacemark.countryCode;
//    NSLog(@"city%@",city);
//    NSLog(@"subThrough%@",subThrough);
//    NSLog(@"locality%@",locality);
//    NSLog(@"subLocality%@",subLocality);
//    NSLog(@"adminisArea%@",adminisArea);
//    NSLog(@"subAdminArea%@",subAdminArea);
//    NSLog(@"postalCode%@",postalCode);
//    NSLog(@"country%@",country);
//    NSLog(@"countryCode%@",countryCode);
    
    NSString *adress = [NSString stringWithFormat:@"%@ %@ %@", adminisArea, locality, subLocality];
    self.adressLabel.text = adress;
    NSLog(@"%@", adress);
    
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
