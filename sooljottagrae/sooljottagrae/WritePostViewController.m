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
                      @"id": @(2),
                      @"alcohol_name": @"소주"
                      },
                  @{
                      @"id": @(3),
                      @"alcohol_name": @"맥주"
                      },
                  @{
                      @"id": @(4),
                      @"alcohol_name": @"막걸리"
                      },
                  @{
                      @"id": @(5),
                      @"alcohol_name": @"진"
                      },
                  @{
                      @"id": @(6),
                      @"alcohol_name": @"럼"
                      },
                  @{
                      @"id": @(7),
                      @"alcohol_name": @"소맥"
                      },
                  @{
                      @"id": @(8),
                      @"alcohol_name": @"보드카"
                      },
                  @{
                      @"id": @(9),
                      @"alcohol_name": @"칵테일"
                      },
                  @{
                      @"id": @(10),
                      @"alcohol_name": @"동동주"
                      }
                  ];
    foodTag = @[
                @{
                    @"id": @(1),
                    @"food_name": @"치킨"
                    },
                @{
                    @"id": @(2),
                    @"food_name": @"파전"
                    },
                @{
                    @"id": @(3),
                    @"food_name": @"삼겹살"
                    },
                @{
                    @"id": @(4),
                    @"food_name": @"고기"
                    },
                @{
                    @"id": @(5),
                    @"food_name": @"소고기"
                    },
                @{
                    @"id": @(6),
                    @"food_name": @"치킨"
                    },
                @{
                    @"id": @(7),
                    @"food_name": @"돼지곱창"
                    },
                @{
                    @"id": @(8),
                    @"food_name": @"소곱창"
                    },
                @{
                    @"id": @(9),
                    @"food_name": @"닭갈비"
                    },
                @{
                    @"id": @(10),
                    @"food_name": @"족발"
                    },
                @{
                    @"id": @(11),
                    @"food_name": @"짜장면"
                    },
                @{
                    @"id": @(12),
                    @"food_name": @"탕수육"
                    },
                @{
                    @"id": @(13),
                    @"food_name": @"또띠야"
                    },
                @{
                    @"id": @(14),
                    @"food_name": @"라자냐"
                    }
                ];
    placeTag = @[
                 @{
                     @"id": @(1),
                     @"place_name": @"신사역"
                     },
                 @{
                     @"id": @(2),
                     @"place_name": @"신사"
                     },
                 @{
                     @"id": @(3),
                     @"place_name": @"강남"
                     },
                 @{
                     @"id": @(4),
                     @"place_name": @"건대"
                     },
                 @{
                     @"id": @(5),
                     @"place_name": @"양재"
                     },
                 @{
                     @"id": @(6),
                     @"place_name": @"성수"
                     },
                 @{
                     @"id": @(7),
                     @"place_name": @"홍대"
                     },
                 @{
                     @"id": @(8),
                     @"place_name": @"합정"
                     },
                 @{
                     @"id": @(9),
                     @"place_name": @"서촌"
                     },
                 @{
                     @"id": @(10),
                     @"place_name": @"상암"
                     },
                 @{
                     @"id": @(11),
                     @"place_name": @"미아"
                     },
                 @{
                     @"id": @(12),
                     @"place_name": @"성신여대"
                     },
                 @{
                     @"id": @(13),
                     @"place_name": @"고대"
                     },
                 @{
                     @"id": @(14),
                     @"place_name": @"건대"
                     },
                 @{
                     @"id": @(15),
                     @"place_name": @"구로"
                     },
                 @{
                     @"id": @(16),
                     @"place_name": @"서울"
                     },
                 @{
                     @"id": @(17),
                     @"place_name": @"대구"
                     },
                 @{
                     @"id": @(18),
                     @"place_name": @"부산"
                     },
                 @{
                     @"id": @(19),
                     @"place_name": @"광주"
                     },
                 @{
                     @"id": @(20),
                     @"place_name": @"강릉"
                     },
                 @{
                     @"id": @(21),
                     @"place_name": @"울산"
                     },
                 @{
                     @"id": @(22),
                     @"place_name": @"인천"
                     }
                 ];
    
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
                      @"id": @(2),
                      @"alcohol_name": @"소주"
                  },
                  @{
                      @"id": @(3),
                      @"alcohol_name": @"맥주"
                  },
                  @{
                      @"id": @(4),
                      @"alcohol_name": @"막걸리"
                  },
                  @{
                      @"id": @(5),
                      @"alcohol_name": @"진"
                  },
                  @{
                      @"id": @(6),
                      @"alcohol_name": @"럼"
                  },
                  @{
                      @"id": @(7),
                      @"alcohol_name": @"소맥"
                  },
                  @{
                      @"id": @(8),
                      @"alcohol_name": @"보드카"
                  },
                  @{
                      @"id": @(9),
                      @"alcohol_name": @"칵테일"
                  },
                  @{
                      @"id": @(10),
                      @"alcohol_name": @"동동주"
                  }
                ];
    foodTag = @[
                @{
                    @"id": @(1),
                    @"food_name": @"치킨"
                },
                @{
                    @"id": @(2),
                    @"food_name": @"파전"
                },
                @{
                    @"id": @(3),
                    @"food_name": @"삼겹살"
                },
                @{
                    @"id": @(4),
                    @"food_name": @"고기"
                },
                @{
                    @"id": @(5),
                    @"food_name": @"소고기"
                },
                @{
                    @"id": @(6),
                    @"food_name": @"치킨"
                },
                @{
                    @"id": @(7),
                    @"food_name": @"돼지곱창"
                },
                @{
                    @"id": @(8),
                    @"food_name": @"소곱창"
                },
                @{
                    @"id": @(9),
                    @"food_name": @"닭갈비"
                },
                @{
                    @"id": @(10),
                    @"food_name": @"족발"
                },
                @{
                    @"id": @(11),
                    @"food_name": @"짜장면"
                },
                @{
                    @"id": @(12),
                    @"food_name": @"탕수육"
                },
                @{
                    @"id": @(13),
                    @"food_name": @"또띠야"
                },
                @{
                    @"id": @(14),
                    @"food_name": @"라자냐"
                }
                ];
    placeTag = @[
                 @{
                     @"id": @(1),
                     @"place_name": @"신사역"
                     },
                 @{
                     @"id": @(2),
                     @"place_name": @"신사"
                     },
                 @{
                     @"id": @(3),
                     @"place_name": @"강남"
                     },
                 @{
                     @"id": @(4),
                     @"place_name": @"건대"
                     },
                 @{
                     @"id": @(5),
                     @"place_name": @"양재"
                     },
                 @{
                     @"id": @(6),
                     @"place_name": @"성수"
                     },
                 @{
                     @"id": @(7),
                     @"place_name": @"홍대"
                     },
                 @{
                     @"id": @(8),
                     @"place_name": @"합정"
                     },
                 @{
                     @"id": @(9),
                     @"place_name": @"서촌"
                     },
                 @{
                     @"id": @(10),
                     @"place_name": @"상암"
                     },
                 @{
                     @"id": @(11),
                     @"place_name": @"미아"
                     },
                 @{
                     @"id": @(12),
                     @"place_name": @"성신여대"
                     },
                 @{
                     @"id": @(13),
                     @"place_name": @"고대"
                     },
                 @{
                     @"id": @(14),
                     @"place_name": @"건대"
                     },
                 @{
                     @"id": @(15),
                     @"place_name": @"구로"
                     },
                 @{
                     @"id": @(16),
                     @"place_name": @"서울"
                     },
                 @{
                         @"id": @(17),
                         @"place_name": @"대구"
                     },
                 @{
                     @"id": @(18),
                     @"place_name": @"부산"
                     },
                 @{
                     @"id": @(19),
                     @"place_name": @"광주"
                     },
                 @{
                     @"id": @(20),
                     @"place_name": @"강릉"
                     },
                 @{
                     @"id": @(21),
                     @"place_name": @"울산"
                     },
                 @{
                     @"id": @(22),
                     @"place_name": @"인천"
                     }
                 ];
    
 
    
    
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
        
        [[RequestObject sharedInstance] sendToServer:apiUrl option:@"POST" parameters:parameters image:self.imageView.image fileName:fileName success:^(NSURLResponse *response, id responseObject, NSError *error) {
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
