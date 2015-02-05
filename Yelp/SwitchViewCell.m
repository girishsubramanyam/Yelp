//
//  SwitchViewCell.m
//  Yelp
//
//  Created by Girish Subramanyam on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "SwitchViewCell.h"

@interface SwitchViewCell()

@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
- (IBAction)valueChange:(id)sender;

@end

@implementation SwitchViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    _on = on;
    [self.switchButton setOn:on animated:animated];
}

- (IBAction)valueChange:(id)sender {
    [self.delegate switchCellView:self valueDidChange:self.switchButton.on];
}
@end
