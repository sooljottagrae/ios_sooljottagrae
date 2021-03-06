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
#import "RequestObject.h"
#import "UserObject.h"

@interface CommentsViewController () <UITextFieldDelegate, TableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *comments;
@property (nonatomic, weak) IBOutlet UIView *topBarView;
@property (nonatomic, weak) IBOutlet UIButton *backBtn;

@property (nonatomic) CircleImageView *profileThumbnailView;
@property NSInteger cellIndex;

@property (nonatomic, weak) IBOutlet UITextField *inputComment;
@property (nonatomic, weak) IBOutlet UIView *inputCommentView;

@property (strong, nonatomic) NSDictionary *selectedCommentInfo; //선택된 코멘트 id;

@end


typedef NS_ENUM(NSInteger, CustomAlertType){
    CustomAlertTypeEdit,
    CustomAlertTypeConfirm,
    CustomAlertTypeCancel,
    CustomAlertTypeConfirmCancel
};

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
    //self.comments = @[comment1, comment2, comment3, comment4, comment5, comment6, comment7];
    
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
    
    
    //강준
    self.navigationController.view.hidden  = YES;
    
    [self.tableView setFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60)];
    
    UIView *naviView = [[UIView alloc]initWithFrame:CGRectMake(-10, 0, self.view.frame.size.width+10, 60)];
    naviView.backgroundColor = THEMA_BG_COLOR;
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(8, 20, 100, 40)];
    [backButton setTitle:@"< Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [backButton addTarget:self action:@selector(clickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [naviView addSubview:backButton];
    
    [self.view addSubview:naviView];
    
    if(self.commentList.count > 0) {
        self.comments = self.commentList;
    }
    
    
    
    /*
    self.profileThumbnailView = [[CircleImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.profileThumbnailView.image = [UIImage imageNamed:@"Profile1"];
    [self.view addSubview:self.profileThumbnailView];
    */
    //UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showEditAndDeleteBtn:)];
}

//강준

-(IBAction)clickedBackButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    if(self.commentList.count == 0)
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text             = @"검색 된 데이터가 없습니다.";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    //섹션에 맞는 배열을 가져와서 줄에 출력해
    NSString *text = [self.comments[indexPath.row] objectForKey:@"content"];
    NSString *nick = [self.comments[indexPath.row] objectForKey:@"user"];
    cell.textLabel.text = nick;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
    
    cell.detailTextLabel.text = text;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    cell.detailTextLabel.numberOfLines = 0;
    self.profileThumbnailView = [[CircleImageView alloc] initWithFrame:CGRectMake(4, 4, 36, 36)];
    self.profileThumbnailView.image = [UIImage imageNamed:@"profileSample.jpeg"];
    self.profileThumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.image =[UIImage imageNamed:@"background"];
    
    //강준 - Delegate 연결
    cell.delegate = self;
    
    cell.cellInfo = self.comments[indexPath.row];
    
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
    
    NSDictionary *dict = self.comments[indexPath.row];
    
    self.selectedCommentInfo = dict;
    
    //NSLog(@"%@", dict);
    
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

/////// 강준

#define kOFFSET_FOR_KEYBOARD 320.0

-(void)keyboardWillShow {
     CGFloat height = self.view.frame.size.height - self.inputCommentView.frame.size.height;
    // Animate the current view out of the way
    if (self.inputCommentView.frame.origin.y >= height)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < height)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    CGFloat height = self.view.frame.size.height - self.inputCommentView.frame.size.height;
    if (self.inputCommentView.frame.origin.y >= height)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.inputCommentView.frame.origin.y < height)
    {
        [self setViewMovedUp:NO];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:self.inputComment])
    {
        
        //move the main view, so that the keyboard does not hide it.
        CGFloat heigth = self.view.frame.size.height - self.inputCommentView.frame.size.height;
        if  (self.inputCommentView.frame.origin.y >= heigth)
        {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.inputCommentView.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    [self.inputCommentView setFrame:rect];
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


-(void) showMessageTitle:(NSString *)title message:(NSString *)msg data:(id)object type:(CustomAlertType)type handler:(void (^)(NSInteger object))handler completion:(void (^)())block{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    if(object != nil){
        dict = [NSDictionary dictionaryWithDictionary:object].mutableCopy;
        
    }
    
    
    UIAlertAction *edit = [UIAlertAction actionWithTitle:@"수정" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *inputText = alertController.textFields.lastObject;
        if([inputText.text length] != 0){
            [dict setObject:inputText.text forKey:@"newcontent"];
            [self editCommentsToServer:dict];
        }else{
            [self showMessageTitle:@"알림창" message:@"새로운 내용이 입력되지 않았습니다. 다시 입력해주세요" data:nil type:CustomAlertTypeEdit handler:nil completion:^{
                [self showMessageTitle:title message:msg data:object type:CustomAlertTypeEdit handler:nil completion:block];
            }];
        }
        
        //실행완료 블럭
        handler(CustomAlertTypeEdit);
    }];
    
    UIAlertAction *confrim = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //실행완료 블럭
        //handler(CustomAlertTypeConfirm);
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //실행완료 블럭
        handler(CustomAlertTypeCancel);
    }];
    
    //수정창 혹은 알림창
    if(type == CustomAlertTypeEdit){
        [alertController addAction:edit];
        [alertController addAction:cancel];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            NSString *content = [object objectForKey:@"content"];
            if([content isKindOfClass:NSString.class] && [content length] > 0 ){
                textField.text = content;
            }
            textField.placeholder = @"댓글 입력...";
        }];
    }else if(type == CustomAlertTypeConfirm){
        [alertController addAction:confrim];
    }else if(type == CustomAlertTypeConfirmCancel){
        [alertController addAction:confrim];
        [alertController addAction:cancel];
    }
    
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

//댓글 수정
-(void) editCommentsToServer:(NSMutableDictionary *)dict{
    NSDictionary *parameter = @{
                                @"id":[dict objectForKey:@"id"] ,
                                @"content": [dict objectForKey:@"newcontent"]
                                };
    
    NSString *urlString = [NSString stringWithFormat:@"/api/comments/%@/edit/", [dict objectForKey:@"id"]];
    [[RequestObject sharedInstance] sendToServer:urlString option:@"PUT" parameters:parameter success:^(NSURLResponse *response, id responseObject, NSError *error) {
        //성공시
        [self showMessageTitle:@"알림창" message:@"수정 성공! 확인시 댓글창이 닫힙니다." data:nil type:CustomAlertTypeConfirm handler:nil  completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
        //실패시
        [self showMessageTitle:@"알림창" message:@"수정 실패! 다시 확인 해주세요." data:nil type:CustomAlertTypeConfirm handler:nil completion:^{
            
        }];
    } useAuth:YES];

}

#pragma mark TableVeiwCell<TableViwCellDelegate> Custom
-(void)editButtonTouched:(NSDictionary *)dict{
    NSString *commentUser = [dict objectForKey:@"user"];
    if([[UserObject sharedInstance].userName isEqualToString:commentUser]){
        [self showMessageTitle:@"수정창" message:@"내용을 수정해 주세요." data:dict type:CustomAlertTypeEdit handler:^(NSInteger object) {
            //핸들러
            if(object == CustomAlertTypeEdit){
                
            }else if(object == CustomAlertTypeCancel){
                
            }else if(object == CustomAlertTypeConfirm){
                
            }
        } completion:^{
            //완료시
        }];
    }
}

-(void)deleteButtonTouched:(NSDictionary *)dict{
    NSString *commentUser = [dict objectForKey:@"user"];
    if([[UserObject sharedInstance].userName isEqualToString:commentUser]){
        [self showMessageTitle:@"삭제 확인창" message:@"댓글 정말로 삭제 하시겠습니까?" data:nil type:CustomAlertTypeConfirmCancel handler:^(NSInteger object) {
            //핸들러
            if(object == CustomAlertTypeEdit){
                
            }else if(object == CustomAlertTypeCancel){
                
            }else if(object == CustomAlertTypeConfirm){
                NSString *apiUrl = [NSString stringWithFormat:@"/api/comments/%@/edit/",[dict objectForKey:@"id"]];
                [[RequestObject sharedInstance] sendToServer:apiUrl option:@"DELETE" parameters:dict success:^(NSURLResponse *response, id responseObject, NSError *error) {
                    //
                } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                    //
                } useAuth:YES];
            }
        } completion:^{
            //완료시
        }];
    }
}
- (IBAction)addCommentsBtn:(id)sender {
    NSLog(@"%@",self.url);
    
    if([self.inputComment.text isKindOfClass:NSString.class] && [self.inputComment.text length] > 0){
        NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
        
        [parameter setObject:self.inputComment.text forKey:@"content"];
        
        NSString *urlString = [NSString stringWithFormat:@"%@comments/create/",self.url];
        NSString *urlString2 = [NSString stringWithFormat:@"%@comments/",self.url];
        [[RequestObject sharedInstance] sendToServer:urlString option:@"POST" parameters:parameter success:^(NSURLResponse *response, id responseObject, NSError *error) {
            
            [[RequestObject sharedInstance]sendToServer:urlString2 option:@"GET" parameters:nil success:^(NSURLResponse *response, id responseObject, NSError *error) {
                if([responseObject objectForKey:@"result"]){
                    
                    self.commentList =[responseObject objectForKey:@"result"];
                }
            } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
                //
            } useAuth:YES];
        } fail:^(NSURLResponse *response, id responseObject, NSError *error) {
            //
            NSLog(@"%@, %@, %@", response, responseObject, error);
            [self showMessageTitle:@"에러메세지" message:@"잠시후에 시도해주세요" data:nil type:CustomAlertTypeConfirm handler:nil completion:nil];
        } useAuth:YES];
    }
}

@end
