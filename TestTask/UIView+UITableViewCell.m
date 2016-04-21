//
//  UIView+UITableViewCell.m
//  TestTask
//
//  Created by apple on 18.04.16.
//  Copyright © 2016 OlegKasarin. All rights reserved.
//

#import "UIView+UITableViewCell.h"

@implementation UIView (UITableViewCell)

- (UITableViewCell*) superCell {
    if (!self.superview) {
        return nil;
    }
    
    if ([self.superview isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell *)self.superview;
    }
    
    return [self.superview superCell];
}


@end
