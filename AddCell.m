//
//  AddCell.m
//  NUS Mod
//
//  Created by Steven Zhang on 17/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "AddCell.h"

@implementation AddCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = CGRectInset(self.bounds, 2.0, 2.0);
}

@end
