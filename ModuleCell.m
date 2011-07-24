//
//  ModuleCell.m
//  NUS Mod
//
//  Created by Steven Zhang on 14/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "ModuleCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Random.h"
#import "ModuleListViewController.h"
#import "UIColor+Random.h"

@implementation ModuleCell
@synthesize codeLabel;
@synthesize titleLabel;
@synthesize examLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = CGRectInset(self.bounds, 2.0, 2.0);
}

- (void)awakeFromNib {
    
    self.backgroundView.layer.cornerRadius = 10.0;
    self.backgroundView.layer.borderWidth = 1.0;
    self.backgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIColor *)tintColor {
    CGFloat r, g, b, a;
    [self.backgroundView.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    return color;
}

- (IBAction)handleEnableButton:(id)sender {
}

- (IBAction)handleRemoveButton:(id)sender {
    NSLog(@"remove");
    [moduleListViewController removeButtonTappedOnCell: self];
}

- (void)setTintColor:(UIColor *)color {
    //    tintColor = color;
    codeLabel.textColor = [color darkerColor];
    titleLabel.textColor = [color darkerColor];
    examLabel.textColor = [color darkerColor];
    
    
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:0.8];
        self.backgroundView.layer.borderColor = [color darkerColor].CGColor;
}


@end
