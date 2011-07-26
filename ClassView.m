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
#import <QuartzCore/QuartzCore.h>
@implementation ClassView
@synthesize classType;
@synthesize codeLabel;
@synthesize typeLabel;
@synthesize venueLabel;
@synthesize weekViewController;
@synthesize classDetail;

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    codeLabel.text = @"Test";
//    
//    return self;
//}

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGR];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (UIColor *)tintColor {
    return self.tintColor;
}

- (void)layoutSubviews {
    NSString *text = typeLabel.text;
    CGSize size = [text sizeWithFont:typeLabel.font constrainedToSize:CGSizeMake(typeLabel.frame.size.width, 1000) lineBreakMode:UILineBreakModeWordWrap];
        
    CGRect frame = typeLabel.frame;
    //NSLog(@"frame: %@", NSStringFromCGRect(frame));
    frame.size = CGSizeMake(frame.size.width, size.height);
    typeLabel.frame = frame;
    typeLabel.adjustsFontSizeToFitWidth = YES;
    typeLabel.numberOfLines = 0;
    
    CGRect rect1 = typeLabel.frame;
    CGRect rect2 = venueLabel.frame;
    rect2 = CGRectMake(rect1.origin.x, rect1.origin.y + rect1.size.height, rect2.size.width, rect2.size.height);
    venueLabel.frame = rect2;
}

- (void)setTintColor:(UIColor *)color {
    [super setTintColor:color];
    codeLabel.textColor = [color darkerColor];
    typeLabel.textColor = [color darkerColor];
    venueLabel.textColor = [color darkerColor];
    self.layer.borderColor = [color darkerColor].CGColor;
}

- (void)handleTap: (UITapGestureRecognizer *)gr {
    if (weekViewController) {
        [weekViewController classViewWasTapped: self];
    }
}

@end
