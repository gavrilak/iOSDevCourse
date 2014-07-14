//
//  TTTopicsTableViewCell.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTTopicsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleTopicLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameProfileLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastCommentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLastCommentLabel;

@end
