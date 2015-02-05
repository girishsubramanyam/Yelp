//
//  YelpViewCell.m
//  Yelp
//
//  Created by Girish Subramanyam on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "YelpViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface YelpViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageview;
@property (weak, nonatomic) IBOutlet UIImageView *ratingsImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation YelpViewCell

- (void)awakeFromNib {
    // Initialization code
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    self.thumbnailImageview.layer.cornerRadius = 3;
    self.thumbnailImageview.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBusiness:(Business *)business {
    _business = business;
    [self.thumbnailImageview setImageWithURL:[NSURL URLWithString:self.business.imageUrl]];
    [self.ratingsImageView setImageWithURL:[NSURL URLWithString:self.business.ratingImageUrl]];
    self.nameLabel.text = self.business.name;
    self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f mi", self.business.distance];
    self.reviewsLabel.text = [NSString stringWithFormat:@"%ld Reviews", self.business.numberReviews];
    self.addressLabel.text = self.business.address;
    self.categoryLabel.text = self.business.categories;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
}

@end
