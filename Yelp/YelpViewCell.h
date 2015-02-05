//
//  YelpViewCell.h
//  Yelp
//
//  Created by Girish Subramanyam on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"

@interface YelpViewCell : UITableViewCell
@property (nonatomic, strong) Business* business;

@end
