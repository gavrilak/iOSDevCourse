//
//  TTCountersTableViewCell.m
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/5/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTCountersTableViewCell.h"

@interface TTCountersTableViewCell () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *colectionView;

@end

@implementation TTCountersTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        //layout.minimumInteritemSpacing = 2.f;
        layout.minimumLineSpacing = 4.f;
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 2, 0, 2);
        [layout setSectionInset:insets];
        self.colectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
        [self.colectionView setDataSource:self];
        [self.colectionView setDelegate:self];
        [self.colectionView setShowsHorizontalScrollIndicator:NO];
        [self.colectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"colectionCell"];
        [self.colectionView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:self.colectionView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *counerCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"colectionCell" forIndexPath:indexPath];
    
    counerCell.backgroundColor=[UIColor clearColor];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, 60, 15)];
    UILabel *countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 60, 15)];
    
    nameLabel.tag = 10;
    countLabel.tag = 11;
    
    if ([counerCell viewWithTag:10]) [[counerCell viewWithTag:10] removeFromSuperview];
    if ([counerCell viewWithTag:11]) [[counerCell viewWithTag:11] removeFromSuperview];
    
    nameLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.textAlignment = NSTextAlignmentCenter;
    
    nameLabel.font = [UIFont systemFontOfSize:12.f];
    countLabel.font = [UIFont systemFontOfSize:12.f];
    
    if (nameLabel) [nameLabel removeFromSuperview];
    
    [counerCell addSubview:nameLabel];
    [counerCell addSubview:countLabel];
    
    nameLabel.text = nil;
    
    if (self.group != nil) {
        if (indexPath.row == 0) {
            nameLabel.text = @"members";
            countLabel.text = self.group.members_count;
        } else if (indexPath.row == 1) {
            nameLabel.text = @"topics";
            countLabel.text = self.group.topics;
        } else if (indexPath.row == 2) {
            nameLabel.text = @"videos";
            countLabel.text = self.group.videos;
        } else if (indexPath.row == 3) {
            nameLabel.text = @"photos";
            countLabel.text = self.group.photos;
        } else if (indexPath.row == 4) {
            nameLabel.text = @"docs";
            countLabel.text = self.group.docs;
        } else if (indexPath.row == 5) {
            nameLabel.text = @"albums";
            countLabel.text = self.group.albums;
        }
    }

    return counerCell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 44);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegete collectionCellPressedAtIndex:indexPath];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
