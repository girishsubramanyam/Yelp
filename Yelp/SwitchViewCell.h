//
//  SwitchViewCell.h
//  Yelp
//
//  Created by Girish Subramanyam on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchViewCell;
@protocol SwitchCellViewDelegate <NSObject>

- (void)switchCellView:(SwitchViewCell*) cell valueDidChange:(BOOL) on;

@end

@interface SwitchViewCell : UITableViewCell

@property (nonatomic, assign) BOOL on;
@property (nonatomic, weak)id<SwitchCellViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
