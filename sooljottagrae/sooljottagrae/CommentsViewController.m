//
//  ReplyViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 22..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "CommentsViewController.h"
#import "CircleImageView.h"
#import "TableViewCell.h"

@interface CommentsViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *comments;
@property (nonatomic, weak) IBOutlet UIView *topBarView;
@property (nonatomic, weak) IBOutlet UIButton *backBtn;

@property (nonatomic) CircleImageView *profileThumbnailView;
@property NSInteger cellIndex;

@property (nonatomic, weak) IBOutlet UITextField *inputComment;
@property (nonatomic, weak) IBOutlet UIView *inputCommentView;

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *comment1 = @{@"content" : @"하이요!"};
    NSDictionary *comment2 = @{@"content" : @"맛있어 보이네요!"};
    NSDictionary *comment3 = @{@"content" : @"강남가서 한잔 하고싶네요ㅠㅠ"};
    NSDictionary *comment4 = @{@"content" : @"아 퇴근하고싶다."};
    NSDictionary *comment5 = @{@"content" : @"비오는날엔 막걸리죠~"};
    NSDictionary *comment6 = @{@"content" : @"ㅇㅇ나도 막걸리 좋아함"};
    NSDictionary *comment7 = @{@"content" : @"머라는거냐 자아가 도대체 몇개냐 홍준아ㅡㅡ안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요"};
    self.comments = @[comment1, comment2, comment3, comment4, comment5, comment6, comment7];
    
    CALayer *border = [CALayer layer];
    border.backgroundColor = [[UIColor grayColor] CGColor];
    border.frame = CGRectMake(0, self.view.frame.size.height*0.09-0.5, self.topBarView.frame.size.width, 0.5);
    [self.topBarView.layer addSublayer:border];

    
    [self.backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.backBtn setTintColor:[UIColor blackColor]];
    self.backBtn.imageView.contentMode = UIViewContentModeScaleToFill;
    
    //cell이 없으면 seperator를 없애줌
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.inputComment.placeholder = @"댓글 달기...";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    
    

    
    /*
    self.profileThumbnailView = [[CircleImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.profileThumbnailView.image = [UIImage imageNamed:@"Profile1"];
    [self.view addSubview:self.profileThumbnailView];
    */
    //UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showEditAndDeleteBtn:)];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"%f", [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
        //CGRect rect = self.inputCommentView.frame;
        NSLog(@"%f %f %f %f", self.inputCommentView.frame.origin.x, self.inputCommentView.frame.origin.y, self.inputCommentView.frame.size.width, self.inputCommentView.frame.size.height);
        //rect.origin.y -= ([notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
        self.inputCommentView.frame = CGRectMake(0, 401, 375, 50);
    });
    
}




// Override to support conditional editing of the table view.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    //섹션에 맞는 배열을 가져와서 줄에 출력해
    NSString *text = [self.comments[indexPath.row] objectForKey:@"content"];
    cell.textLabel.text = @"Heo";
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
    
    cell.detailTextLabel.text = text;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    cell.detailTextLabel.numberOfLines = 0;
    self.profileThumbnailView = [[CircleImageView alloc] initWithFrame:CGRectMake(4, 4, 36, 36)];
    self.profileThumbnailView.image = [UIImage imageNamed:@"profileSample.jpeg"];
    self.profileThumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.image =[UIImage imageNamed:@"background"];
    
    
    
    cell.imageView.backgroundColor = [UIColor clearColor];
    
    self.profileThumbnailView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.profileThumbnailView.layer.borderWidth = 1.0;
    
    [cell.imageView addSubview:self.profileThumbnailView];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;


    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //NSLog(@"%f", [self tableView:tableView cellForRowAtIndexPath:indexPath].detailTextLabel.frame.size.height);
    
    CGFloat height = 0.0;
    
    NSString *text = [self.comments[indexPath.row] objectForKey:@"content"];
    height = [text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(self.view.frame.size.width-80,300) lineBreakMode:NSLineBreakByWordWrapping].height;
    NSInteger lineCount = height/17;
    
    //NSLog(@"%zd", lineCount);
    return 26+18*lineCount;
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"delete");
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%@",[self tableView:self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text);
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
