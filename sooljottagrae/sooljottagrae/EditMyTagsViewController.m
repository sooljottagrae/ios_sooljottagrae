//
//  EditMyTagsViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 12..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "EditMyTagsViewController.h"

@interface EditMyTagsViewController ()

@property (nonatomic) NSDictionary *tags;
@property (nonatomic) NSString *selectedBtnTitle;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic) NSString *selectedTag;
@property (nonatomic) NSMutableArray *followingTags;

@end

@implementation EditMyTagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tags = @{@"술" : @[@"소주", @"맥주", @"양주", @"소맥", @"칵테일", @"6", @"7", @"8"],
                  @"안주" : @[@"치킨", @"족발", @"국밥", @"마른안주", @"감자탕", @"삼겹살", @"회"],
                  @"장소" : @[@"강남", @"여의도", @"동대문", @"이태원", @"가로수길", @"압구정로데오", @"신촌", @"홍대", @"삼성"]};
    self.followingTags = [[NSMutableArray alloc] init];
    
    //[self.imageView setImage:[UIImage imageNamed:@"soyu.jpg"]];
    
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2)];
    
    self.toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 40)];
    [self.toolbar setBackgroundColor:[UIColor blueColor]];
    
    self.doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height/2, 60, 40)];
    [self.doneBtn setTitle:@"완료" forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(doneBtn:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.


    //강준
    [self tempSeetingPickerItem];
}



- (IBAction)alcoholBtn:(id)sender {
    self.selectedBtnTitle = @"술";
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.pickerView];
    [self.view addSubview:self.doneBtn];
}
- (IBAction)foodBtn:(id)sender {
    self.selectedBtnTitle = @"안주";
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.pickerView];
    [self.view addSubview:self.doneBtn];
}
- (IBAction)locationBtn:(id)sender {
    self.selectedBtnTitle = @"장소";
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.pickerView];
    [self.view addSubview:self.doneBtn];
}

- (IBAction)doneBtn:(id)sender {
    self.selectedTag=[self.tags objectForKey:self.selectedBtnTitle][[self.pickerView selectedRowInComponent:0]];
    
    [self.followingTags addObject:self.selectedTag];
    NSLog(@"%@",self.followingTags);
    
    [self.pickerView removeFromSuperview];
    [self.doneBtn removeFromSuperview];
    [self.toolbar removeFromSuperview];
    
    [self.tableView reloadData];
    
}

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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.followingTags.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"팔로우중인 태그";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //섹션에 맞는 배열을 가져와서 줄에 출력해
    NSString *text =[self.followingTags objectAtIndex:indexPath.row];
    cell.textLabel.text =text;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}



// Override to support conditional editing of the table view.

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.followingTags removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSLog(@"%@",self.followingTags);
        
        
    }
}

- (IBAction)btn:(id)sender {
    self.view.backgroundColor = [UIColor clearColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:blurEffectView];
    
    
}

- (IBAction)exitBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

//강준
-(NSNumber *) getTagId:(NSString *)name tag:(NSString *)tagName{
    NSArray *alcholTag = [[NSArray alloc]init], *foodTag = [[NSArray alloc]init], *placeTag = [[NSArray alloc]init];
    
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


-(void) tempSeetingPickerItem{
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
    NSMutableArray *soolTags= [[NSMutableArray alloc]init], *foodTags=[[NSMutableArray alloc]init], *placeTags=[[NSMutableArray alloc]init];
    
    for(NSDictionary *dict in alcholTag){
        [soolTags addObject:[dict objectForKey:@"alcohol_name"]];
    }
    
    for(NSDictionary *dict in foodTag){
        [foodTags addObject:[dict objectForKey:@"food_name"]];
    }
    
    for(NSDictionary *dict in placeTag){
        [placeTags addObject:[dict objectForKey:@"place_name"]];
    }
    
    self.tags = @{@"술" :soolTags,
                  @"안주":foodTags,
                  @"장소":placeTags
                  };

    
    
}

@end
