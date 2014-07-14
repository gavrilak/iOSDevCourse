//
//  TTDetailCollectionViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/8/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTDetailCollectionViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TTServerManager.h"
#import "TTPhoto.h"

@interface TTDetailCollectionViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) NSMutableArray *photosArray;
@property (strong,nonatomic) UIRefreshControl *refresh;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation TTDetailCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.photosArray = [NSMutableArray array];
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refresh];
    
    UIBarButtonItem* add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto:)];
    
    
    self.navigationItem.rightBarButtonItem = add;
}

- (void)addPhoto:(UIBarButtonItem *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    [[TTServerManager sharedManager]postImageInAlbumsIds:self.album.albumid image:chosenImage onSuccess:^(id responseObject) {
        
        [self refreshWall];
        
    } onFailure:^(NSError *error) {
        
    }];
     
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshWall {
    
        [[TTServerManager sharedManager]getPhotosFromAlbumID:self.album.albumid ownerID:[[TTServerManager sharedManager] group].group_id count:15 offset:0 onSuccess:^(NSArray *arrayWithPhotos) {
            
            if ([arrayWithPhotos count] > 0) {
                
                [self.photosArray removeAllObjects];
                
                [self.photosArray addObjectsFromArray:arrayWithPhotos];
                
                NSMutableArray* newPaths = [NSMutableArray array];
                for (int i = (int)[self.photosArray count] - (int)[arrayWithPhotos count]; i < [self.photosArray count]; i++) {
                    [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                [self.collectionView reloadData];
                [self.refresh endRefreshing];
                self.loadingData = NO;
            }
            
            
        } onFailure:^(NSError *error) {
            [self.refresh endRefreshing];
        }];
    
}

- (void) getPhotosFromServer {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getPhotosFromAlbumID:self.album.albumid ownerID:[[TTServerManager sharedManager] group].group_id count:15 offset:[self.photosArray count] onSuccess:^(NSArray *arrayWithPhotos) {
            
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
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photosArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *collectionCellIdentifier = @"collectionCellIdentifier";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    [cell.contentView addSubview:imageView];
    
    TTPhoto *photo = [self.photosArray objectAtIndex:indexPath.row];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:photo.photo_130]];
    
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
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.collectionView.contentSize.height - scrollView.frame.size.height/2) {
        if (!self.loadingData) {
            [self getPhotosFromServer];
        }
    }
}

- (void)dealloc {
    
    [self.collectionView setDelegate:nil];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
