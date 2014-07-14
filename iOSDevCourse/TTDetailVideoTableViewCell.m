//
//  TTDetailVideoTableViewCell.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/10/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTDetailVideoTableViewCell.h"

@implementation TTDetailVideoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    _youTubeView = nil;
}

@end
