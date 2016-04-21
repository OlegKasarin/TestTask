//
//  ViewCell.m
//  TestTask
//
//  Created by apple on 18.04.16.
//  Copyright © 2016 OlegKasarin. All rights reserved.
//

#import "ViewCell.h"

@implementation ViewCell

- (IBAction)downloadButtonAction:(id)sender {
    [self.delegate startDownload:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
