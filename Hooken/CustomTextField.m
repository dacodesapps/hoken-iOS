//
//  CustomTextField.m
//  Blizky
//
//  Created by Carlos Vela on 29/11/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.offsetX, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, self.offsetX, 10);
}

// placeholder text color
- (void) drawPlaceholderInRect:(CGRect)rect {
    [[self placeholder] drawInRect:rect withAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f],NSForegroundColorAttributeName:[UIColor colorWithRed:48.0/255.0 green:46.0/255.0 blue:47.0/255.0 alpha:1.0]}];
}

@end
