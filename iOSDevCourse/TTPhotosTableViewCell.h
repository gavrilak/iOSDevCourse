//
//  TTPhotosTableViewCell.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/8/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTIndexedCollectionView.h"
#import "TTAlbum.h"

@protocol TTPhotosDelegete;

@interface TTPhotosTableViewCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UILabel *albumNameLabel;
@property (strong, nonatomic) UILabel *albumPhotosCountLabel;
@property (strong, nonatomic) TTAlbum *album;
@property (weak,nonatomic) id <TTPhotosDelegete> delegete;
@property (nonatomic, strong) TTIndexedCollectionView *collectionView;

- (id)initWithStyle:(UITableViewCellStyle)style album:(TTAlbum *)album reuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol TTPhotosDelegete <NSObject>

- (void)collectionCellPressedAtIndex:(NSIndexPath *)indexPath;

@end