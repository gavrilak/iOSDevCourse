//
//  TTPostTableViewCell.h
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 5/30/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTPostTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *addComentBtn;
@property (weak, nonatomic) IBOutlet UIButton *addLikeBtn;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *repostBtn;

@end
