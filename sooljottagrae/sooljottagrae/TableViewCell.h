//
//  TableViewCell.h
//  sooljottagrae
//
//  Created by 허홍준 on 2016. 7. 23..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TableViewCellDelegate <NSObject>


@optional
- (void) editButtonTouched:(NSDictionary *)info;
- (void) deleteButtonTouched:(NSDictionary *)info;


@end

@interface TableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *deleteBtnView;
@property (nonatomic, strong) UIImageView *editImageView;

@property (nonatomic, strong) NSDictionary *cellInfo;

@property (nonatomic, weak) id<TableViewCellDelegate> delegate;
@end
