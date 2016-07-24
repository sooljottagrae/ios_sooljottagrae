//
//  TableViewCell.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 23..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell()

@property NSInteger addCount;
@property (nonatomic, strong) UIView *deleteView;

@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.addCount = 0;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.imageView.frame;
    rect.size.width=44;
    rect.size.height=44;
    rect.origin.y = (self.contentView.frame.size.height-44)/2;
    rect.origin.x = 10;
    self.imageView.frame=rect;
    
    
    self.separatorInset = UIEdgeInsetsMake(0, 60, 0, 10);
    
    rect = self.textLabel.frame;
    rect.origin.x=65;
    rect.origin.y-=2;
    self.textLabel.frame=rect;
    
    rect = self.detailTextLabel.frame;
    rect.origin.x=65;
    rect.origin.y+=2;
    rect.size.width=self.contentView.frame.size.width-80;
    self.detailTextLabel.frame=rect;
    
    
    for (UIView *subview in self.subviews) {
        for(UIView *childView in subview.subviews){
            if ([childView isKindOfClass:[UIButton class]]) {
                self.deleteView = childView.superview;
                [self.deleteView setBackgroundColor:[UIColor whiteColor]];
                [childView removeFromSuperview];
                //NSLog(@"버튼 찾았다!");
            }
        }
    }
    
    //NSLog(@"%f", self.deleteView.frame.size.width);
    
    
    for (UIView *imgView in self.deleteView.subviews) {
        if ([imgView isKindOfClass:[UIImageView class]]) {
            self.addCount+=1;
        }
    }
    
    
    
    if (self.addCount < 1 ) {
        self.editImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 41.25, 44)];
        self.editImageView.image = [UIImage imageNamed:@"editButton"];
        self.editImageView.contentMode = UIViewContentModeScaleToFill;
        self.editImageView.backgroundColor = THEMA_BG_COLOR;
        self.editImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *editGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBtn:)];
        editGesture.numberOfTapsRequired = 1;
        
        
        [self.editImageView addGestureRecognizer:editGesture];
        
        self.deleteBtnView = [[UIView alloc] initWithFrame:CGRectMake(41.25, 0, 41.25, 44)];
        self.deleteBtnView.backgroundColor = THEMA_BG_DARK_COLOR;
        UITapGestureRecognizer *deleteGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteBtn:)];
        deleteGesture.numberOfTapsRequired = 1;
        
        [self.deleteBtnView addGestureRecognizer:deleteGesture];
        
        UIImageView *deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 27.25, 30)];
        deleteImageView.image = [UIImage imageNamed:@"delete1"];
        deleteImageView.contentMode = UIViewContentModeScaleToFill;
        deleteImageView.backgroundColor = [UIColor clearColor];
        
        
        [self.deleteView addSubview:self.editImageView];
        [self.deleteBtnView addSubview:deleteImageView];
        [self.deleteView addSubview:self.deleteBtnView];
        
        
        //self.addCount += 1;
    }
    
    
    if (self.deleteView.frame.size.width == 0) {
        self.addCount = 0;
    }
    
}

- (IBAction)editBtn:(id)sender {
    NSLog(@"Tap Edit Button");
}

- (IBAction)deleteBtn:(id)sender {
    NSLog(@"Tap Delete Button");
}



/*
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([[touches anyObject] view] == self.editImageView)
        self.editImageView.alpha = 0.5;
    
    else if ([[touches anyObject] view] == self.deleteBtnView)
        NSLog(@"2");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([[touches anyObject] view] == self.editImageView)
        self.editImageView.alpha = 1.0;
    
    else if ([[touches anyObject] view] == self.deleteBtnView)
        NSLog(@"4");

}
 */





@end
