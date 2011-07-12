//
//  ClassView.m
//  NUS Mod
//
//  Created by Steven Zhang on 12/7/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "ClassView.h"
#import "UIColor+Random.h"
#import "WeekViewController.h"
@implementation ClassView
@synthesize classType;
@synthesize codeLabel;
@synthesize typeLabel;
@synthesize venueLabel;
@synthesize weekViewController;

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    codeLabel.text = @"Test";
//    
//    return self;
//}

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGR];
}

- (UIColor *)tintColor {
    return self.tintColor;
}

- (void)setTintColor:(UIColor *)color {
    [super setTintColor:color];
    codeLabel.textColor = [color darkerColor];
    typeLabel.textColor = [color darkerColor];
    venueLabel.textColor = [color darkerColor];
}

- (void)handleTap: (UITapGestureRecognizer *)gr {
    if (weekViewController) {
        [weekViewController classViewWasTapped: self];
    }
}

@end
