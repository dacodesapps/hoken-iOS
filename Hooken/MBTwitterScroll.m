//
//  MBTwitterScroll.m
//  TwitterScroll
//
//  Created by Martin Blampied on 07/02/2015.
//  Copyright (c) 2015 MartinBlampied. All rights reserved.
//

#import "MBTwitterScroll.h"
#import "UIScrollView+TwitterCover.h"

CGFloat const offset_HeaderStop = 143.0;
//CGFloat const offset_B_LabelHeader = 195.0;
CGFloat const offset_B_LabelHeader = 11111500;
CGFloat const distance_W_LabelHeader = 35.0;

@implementation MBTwitterScroll

- (MBTwitterScroll *)initScrollViewWithBackgound:(UIImage*)backgroundImage avatarImage:(UIImage *)avatarImage titleString:(NSString *)titleString subtitleString:(NSString *)subtitleString buttonTitle:(NSString *)buttonTitle contentHeight:(CGFloat)height rating:(NSInteger)rating userType:(NSString*)userType{
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self = [[MBTwitterScroll alloc] initWithFrame:bounds];
    [self setupView:backgroundImage avatarImage:avatarImage titleString:titleString subtitleString:subtitleString buttonTitle:buttonTitle scrollHeight:height type:MBScroll rating:rating userType:userType];
    
    return self;
}

- (MBTwitterScroll *)initTableViewWithBackgound:(UIImage*)backgroundImage avatarImage:(UIImage *)avatarImage titleString:(NSString *)titleString subtitleString:(NSString *)subtitleString buttonTitle:(NSString *)buttonTitle rating:(NSInteger)rating userType:(NSString*)userType{
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self = [[MBTwitterScroll alloc] initWithFrame:bounds];
    
    [self setupView:backgroundImage avatarImage:avatarImage titleString:titleString subtitleString:subtitleString buttonTitle:buttonTitle scrollHeight:0 type:MBTable rating:rating userType:userType];
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    return self;
    
}

- (void) setupView:(UIImage*)backgroundImage avatarImage:(UIImage *)avatarImage titleString:(NSString *)titleString subtitleString:(NSString *)subtitleString buttonTitle:(NSString *)buttonTitle scrollHeight:(CGFloat)height type:(MBType)type rating:(NSInteger)rating userType:(NSString*)userType{
    
    // Header
    self.blackHeader=[[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 207)];
    self.blackHeader.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.3];
    self.header = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 207)];
    [self addSubview:self.header];
    [self addSubview:self.blackHeader];
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.header.frame.size.height - 5, self.frame.size.width, 25)];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.text = titleString;
    self.headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    self.headerLabel.textColor = [UIColor whiteColor];
    [self.header addSubview:self.headerLabel];
    
    if (type == MBTable) {
        // TableView
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height-49)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.showsVerticalScrollIndicator = YES;
        
        // TableView Header
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.header.frame.size.height + 100)];
        [self addSubview:self.tableView];
        
    } else {
        
        // Scroll
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        CGSize newSize = CGSizeMake(self.frame.size.width, height);
        self.scrollView.contentSize = newSize;
        self.scrollView.delegate = self;
    }
    
    
    self.avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 149, 90, 90)];
    self.avatarImage.image = avatarImage;
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2;
    self.avatarImage.layer.borderWidth = 3;
    self.avatarImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImage.clipsToBounds = YES;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 256, 250, 25)];
    self.titleLabel.text = userType;
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 277, 250, 25)];
    self.subtitleLabel.text = subtitleString;
    self.subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    self.subtitleLabel.textColor = [UIColor lightGrayColor];
    
    UILabel*name = [[UILabel alloc] initWithFrame:CGRectMake(110, 160, 250, 25)];
    name.text = titleString;
    name.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    name.textColor = [UIColor whiteColor];
    [self.blackHeader addSubview:name];
    
    //UILabel*distance = [[UILabel alloc] initWithFrame:CGRectMake(200, 185, (120+(4*20))-self.frame.size.width-10, 25)];
    UILabel*distance = [[UILabel alloc] initWithFrame:CGRectMake(210, 185, self.frame.size.width-10-210, 15)];
    distance.text = @"1320 km";
    distance.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
    distance.textColor = [UIColor whiteColor];
    distance.textAlignment=NSTextAlignmentRight;
    [distance setTextColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0]];
    //[self.blackHeader addSubview:distance];
    
    for (int i=0; i<5; i++) {
        UIButton*star=[UIButton buttonWithType:UIButtonTypeSystem];
        star.frame=CGRectMake(110+(i*20), 185, 15, 15);
        [star setTintColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0]];
        if (i<rating) {
            [star setImage:[UIImage imageNamed:@"Star"] forState:UIControlStateNormal];
            //[star setTintColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:0.3]];
        }else{
            [star setImage:[UIImage imageNamed:@"StarOff"] forState:UIControlStateNormal];
        }
        [self.blackHeader addSubview:star];
    }

    if (buttonTitle.length > 0) {
        self.headerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.headerButton.frame = CGRectMake(self.frame.size.width - 120, 220, 100, 35);
        [self.headerButton setTitle:buttonTitle forState:UIControlStateNormal];
        [self.headerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.headerButton setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
        [self.headerButton setTintColor:[UIColor whiteColor]];
        self.headerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.headerButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
        self.headerButton.layer.borderColor = [UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0].CGColor;
        self.headerButton.layer.borderWidth = 1;
        self.headerButton.layer.cornerRadius = 8;
        [self.headerButton setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
        [self.headerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
        [self.headerButton setBackgroundColor:[UIColor colorWithRed:69.0/255.0 green:215.0/255.0 blue:38.0/255.0 alpha:1.0]];
        [self.headerButton addTarget:self action:@selector(recievedMBTwitterScrollButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (type == MBTable) {
        //[self.blackHeader addSubview:self.avatarImage];
        [self.tableView addSubview:self.avatarImage];
        [self.tableView addSubview:self.titleLabel];
        [self.tableView addSubview:self.subtitleLabel];
        if (buttonTitle.length > 0) {
            [self.tableView addSubview:self.headerButton];
        }
    } else {
        [self.scrollView addSubview:self.avatarImage];
        [self.scrollView addSubview:self.titleLabel];
        [self.scrollView addSubview:self.subtitleLabel];
        if (buttonTitle.length > 0) {
            [self.scrollView addSubview:self.headerButton];
        }
    }
    
    
    self.headerImageView = [[UIImageView alloc] initWithFrame:self.header.frame];
    self.headerImageView.image = backgroundImage;
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.header insertSubview:self.headerImageView aboveSubview:self.headerLabel];
    self.header.clipsToBounds = YES;
    
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2;;
    self.avatarImage.layer.borderWidth = 3;
    self.avatarImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.blurImages = [[NSMutableArray alloc] init];
    
    if (backgroundImage != nil) {
        [self prepareForBlurImages];
    } else {
        self.headerImageView.backgroundColor = [UIColor blackColor];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    [self animationForScroll:offset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGFloat offset = self.tableView.contentOffset.y;
    [self animationForScroll:offset];
}

- (void) animationForScroll:(CGFloat) offset {
    
    CATransform3D headerTransform = CATransform3DIdentity;
    CATransform3D avatarTransform = CATransform3DIdentity;
    
    // DOWN -----------------
    
    if (offset < 0) {
        
        CGFloat headerScaleFactor = -(offset) / self.header.bounds.size.height;
        CGFloat headerSizevariation = ((self.header.bounds.size.height * (1.0 + headerScaleFactor)) - self.header.bounds.size.height)/2.0;
        headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0);
        headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0);
        
        self.header.layer.transform = headerTransform;
        self.blackHeader.layer.transform = headerTransform;
        
        if (offset < -self.frame.size.height/3.5) {
            [self recievedMBTwitterScrollEvent];
        }
        
    }
    
    // SCROLL UP/DOWN ------------
    
    else {
        
        // Header -----------
        headerTransform = CATransform3DTranslate(headerTransform, 0, MAX(-offset_HeaderStop, -offset), 0);
        
        //  ------------ Label
        CATransform3D labelTransform = CATransform3DMakeTranslation(0, MAX(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0);
        self.headerLabel.layer.transform = labelTransform;
        self.headerLabel.layer.zPosition = 2;
        self.blackHeader.layer.transform = labelTransform;
        self.blackHeader.layer.zPosition = 2;
        
        // Avatar -----------
        CGFloat avatarScaleFactor = (MIN(offset_HeaderStop, offset)) / self.avatarImage.bounds.size.height / 4.8; // Slow down the animation
        CGFloat avatarSizeVariation = ((self.avatarImage.bounds.size.height * (1.0 + avatarScaleFactor)) - self.avatarImage.bounds.size.height) / 2.0;
        avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0);
        avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0);
        
        if (offset <= offset_HeaderStop) {
            
            if (self.avatarImage.layer.zPosition <= self.headerImageView.layer.zPosition) {
                self.header.layer.zPosition = 0;
                self.blackHeader.layer.zPosition = 0;
            }
            
        }else {
            if (self.avatarImage.layer.zPosition >= self.headerImageView.layer.zPosition) {
                self.header.layer.zPosition = 2;
                self.blackHeader.layer.zPosition = 2;
            }
        }
    }
    if (self.headerImageView.image != nil) {
        [self blurWithOffset:offset];
    }
    self.header.layer.transform = headerTransform;
    self.blackHeader.layer.transform = headerTransform;
    self.avatarImage.layer.transform = avatarTransform;
}

- (void)prepareForBlurImages
{
    CGFloat factor = 0.1;
    [self.blurImages addObject:self.headerImageView.image];
    for (NSUInteger i = 0; i < self.headerImageView.frame.size.height/10; i++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.blurImages addObject:[self.headerImageView.image boxblurImageWithBlur:factor]];
        });
        factor+=0.04;
    }
}

- (void) blurWithOffset:(float)offset {
    NSInteger index = offset / 10;
    if (index < 0) {
        index = 0;
    }
    else if(index >= self.blurImages.count) {
        index = self.blurImages.count - 1;
    }
    UIImage *image = self.blurImages[index];
    if (self.headerImageView.image != image) {
        [self.headerImageView setImage:image];
    }
}

- (void) recievedMBTwitterScrollButtonClicked {
    [self.delegate recievedMBTwitterScrollButtonClicked];
}

- (void) recievedMBTwitterScrollEvent {
    [self.delegate recievedMBTwitterScrollEvent];
}

// Function to blur the header image (used if the header image is replaced with updateHeaderImage)
-(void)resetBlurImages {
    [self.blurImages removeAllObjects];
    [self prepareForBlurImages];
}

// Function to update the header image and blur it out appropriately
-(void)updateHeaderImage:(UIImage*)newImage {
    self.headerImageView.image = newImage;
    [self resetBlurImages];
}

@end
