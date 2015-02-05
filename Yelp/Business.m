//
//  Business.m
//  Yelp
//
//  Created by Girish Subramanyam on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (Business*) initWithBusiness:(NSDictionary*) business {
    self = [super init];
    if (self) {
        NSArray* categories = business[@"categories"];
        NSMutableArray* categoryNames = [NSMutableArray array];
        if (categories) {
            [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [categoryNames addObject:obj[0]];
            }];
        }
        self.categories = [categoryNames componentsJoinedByString:@", "];
        self.ratingImageUrl = business[@"rating_img_url"];
        self.imageUrl = business[@"image_url"];
        self.name = business[@"name"];
        self.numberReviews = [business[@"review_count"] integerValue];
        
        NSArray *address = [business valueForKeyPath:@"location.address"];
        NSString *street = (address.count > 0) ? address[0] : @"";
        NSString *city = [business valueForKeyPath:@"location.city"];
        self.address = [NSString stringWithFormat:@"%@, %@", street, city];
        
        self.distance = [business[@"distance"] floatValue]*0.000621371;
    }
    return self;
}

+ (NSArray*) getBusinesses:(NSArray*) dictionaries {
    NSMutableArray* businesses = [[NSMutableArray alloc] init];
    for (NSDictionary* dictionary in dictionaries) {
        Business* business = [[Business alloc] initWithBusiness:dictionary];
        [businesses addObject:business];
    }
    return businesses;
}
@end
