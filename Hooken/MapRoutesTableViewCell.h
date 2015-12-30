//
//  MapRoutesTableViewCell.h
//  Hooken
//
//  Created by Dacodes on 19/10/15.
//  Copyright © 2015 Dacodes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapRoutesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *destination;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UISwitch *availableSwitch;
@property (weak, nonatomic) IBOutlet UILabel *available;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
