//
//  UIButton+indexPath.m
//  sooljottagrae
//
//  Created by David June Kang on 2016. 7. 25..
//  Copyright © 2016년 alcoholic. All rights reserved.
//

#import "UIButton+indexPath.h"
#import <objc/runtime.h>

static void *gzSection;
static void *gzitem;

@implementation UIButton (indexPath)

- (NSInteger)section
{
    return [objc_getAssociatedObject(self, &gzSection) integerValue];
}

- (void)setSection:(NSInteger)section
{
    objc_setAssociatedObject(self, &gzSection, @(section), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)item
{
    return [objc_getAssociatedObject(self, &gzitem) integerValue];
}

- (void)setItem:(NSInteger)item
{
    objc_setAssociatedObject(self, &gzitem, @(item), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
