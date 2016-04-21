//
//  ViewCell.h
//  TestTask
//
//  Created by apple on 18.04.16.
//  Copyright © 2016 OlegKasarin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewCell;

@protocol ActionButtonProtocol <NSObject>

//@property (nonatomic) id <ActionButtonProtocol> delegate;

- (void) startDownload: (ViewCell*) cell;

@end


@interface ViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* statusLabel;
@property (weak, nonatomic) IBOutlet UIButton* downloadButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (nonatomic) id relatedObject;

@property (weak, nonatomic) id <ActionButtonProtocol> delegate;


@end
