//
//  MainViewController.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 5..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "MainViewController.h"
#import "RequestObject.h"


@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UIButton *mostCommentedButton;
@property (strong, nonatomic) IBOutlet UIButton *myTagsButton;


@property (nonatomic) NSArray *availableIdentifiers;

@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) IBOutlet UIButton *addPostButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self settingView];
    
    [self performSegueWithIdentifier:@"mostCommented" sender:self.tabBarButtons[0]];
}

-(void) settingView{
    self.availableIdentifiers = @[@"mostCommented", @"MyTags"];
    self.tabBarButtons = @[self.mostCommentedButton, self.myTagsButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickedProfileButton:(UIButton *)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main1" bundle:nil];
    
    UIViewController *profileVC = [storyBoard instantiateViewControllerWithIdentifier:@"PROFILE"];
    
    
    [self addChildViewController:profileVC];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.availableIdentifiers containsObject: segue.identifier]){
        for(UIButton *selected in self.tabBarButtons){
            if(sender != nil && ![selected isEqual: sender]) {
                [selected setSelected: NO];
                
            } else if(sender != nil) {
                [selected setSelected: YES];
                
            }
        }
    }
}


@end
