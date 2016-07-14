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
}

- (IBAction)alcoholBtn:(id)sender {
    self.selectedBtnTitle = @"술";
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    
    [UIView transitionWithView:self.view duration:0.5
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^ { [self.view addSubview:self.pickerView]; }
                    completion:nil];
    
    [self.view addSubview:self.toolbar];
    //[self.view addSubview:self.pickerView];
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

@end
