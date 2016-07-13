//
//  WritePostViewController.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 13..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "WritePostViewController.h"

@interface WritePostViewController ()

@property (nonatomic, weak) IBOutlet UIView *textBorderView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation WritePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self.textBorderView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.textBorderView layer] setBorderWidth:2.3];
    [[self.textBorderView layer] setCornerRadius:15];
    
    [self.imageView setImage:[UIImage imageNamed:@"profile1"]];
    
    
    
    
    // Do any additional setup after loading the view.
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
