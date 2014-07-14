//
//  TTPhotosTableViewCell.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/8/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTPhotosTableViewCell.h"
#import "TTServerManager.h"
#import "TTPhoto.h"
#import "UIImageView+AFNetworking.h"

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface TTPhotosTableViewCell ()

@property (strong,nonatomic) NSMutableArray *photosArray;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation TTPhotosTableViewCell 

- (id)initWithStyle:(UITableViewCellStyle)style album:(TTAlbum *)album reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    self.photosArray = [NSMutableArray array];
    
    self.backgroundColor = [UIColor colorWithRed:0.082 green:0.082 blue:0.082 alpha:1.000];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 0);
    layout.itemSize = CGSizeMake(46, 46);
    layout.minimumInteritemSpacing = 5.f;
    layout.minimumLineSpacing = 2.f;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[TTIndexedCollectionView alloc] initWithFrame:CGRectMake(0, 50, 320, 50) collectionViewLayout:layout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithRed:0.082 green:0.082 blue:0.082 alpha:1.000];
    self.albumNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 231, 21)];
    self.albumNameLabel.font = [UIFont systemFontOfSize:15.f];
    self.albumNameLabel.textColor = [UIColor whiteColor];
    
    [self addSubview:self.albumNameLabel];
    
    self.albumPhotosCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 29, 231, 21)];
    self.albumPhotosCountLabel.font = [UIFont systemFontOfSize:13.f];
    self.albumPhotosCountLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:self.albumPhotosCountLabel];
    
    [self.contentView addSubview:self.collectionView];
    
    self.album = album;
    self.loadingData = YES;
    [self getPhotosFromServer];
    return self;
}

- (void) getPhotosFromServer {
    
    [[TTServerManager sharedManager]getPhotosFromAlbumID:self.album.albumid ownerID:[[TTServerManager sharedManager] group].group_id count:10 offset:[self.photosArray count] onSuccess:^(NSArray *arrayWithPhotos) {
        
        if ([arrayWithPhotos count] > 0) {
            
            [self.photosArray addObjectsFromArray:arrayWithPhotos];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.photosArray count] - (int)[arrayWithPhotos count]; i < [self.photosArray count]; i++) {
                [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }

            [self.collectionView reloadData];
            self.loadingData = NO;
        }
        
        
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(TTIndexedCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photosArray count];
}

- (UICollectionViewCell *)collectionView:(TTIndexedCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];

    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 46, 46)];

    [cell.contentView addSubview:imageView];

    TTPhoto *photo = [self.photosArray objectAtIndex:indexPath.row];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:photo.photo_75]];
    
    __weak UIImageView *weakimageView = imageView;
    
    [imageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              
                                              [UIView transitionWithView:weakimageView
                                                                duration:0.3f
                                                                 options:UIViewAnimationOptionTransitionCrossDissolve
                                                              animations:^{
                                                                  weakimageView.image = image;
                                                                  
                                                              } completion:NULL];
                                              
                                              
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                              
                                          }];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegete collectionCellPressedAtIndex:indexPath];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getPhotosFromServer];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = CGRectMake(0, 50, 320, 50);
}


@end
