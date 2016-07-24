//
//  CircleImageView.m
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 12..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "CircleImageView.h"

@implementation CircleImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //NSLog(@"change!!");
    
    self.layer.cornerRadius = self.frame.size.height/2;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    
}

@end
