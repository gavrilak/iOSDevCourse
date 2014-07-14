//
//  TTDetailVideoTableViewCell.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/10/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@interface TTDetailVideoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateUploadLabel;
@property (weak, nonatomic) IBOutlet YTPlayerView *youTubeView;
@property (weak, nonatomic) IBOutlet UILabel *nameVideoLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@end
