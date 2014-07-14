//
//  TTPhotosTableViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/8/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTPhotosTableViewController.h"
#import "TTPhotosTableViewCell.h"
#import "TTServerManager.h"
#import "TTAlbum.h"
#import "UIImageView+AFNetworking.h"
#import "TTIndexedCollectionView.h"
#import "TTDetailCollectionViewController.h"

@interface TTPhotosTableViewController () <TTPhotosDelegete>

@property (strong,nonatomic) NSMutableArray *albumArray;
@property (assign,nonatomic) BOOL loadingData;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation TTPhotosTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
    
    self.albumArray = [NSMutableArray array];
    self.navigationItem.title = @"Albums";
    self.loadingData = YES;
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self getAlbumsFromServer];
    
}

- (void)refreshWall {
    
    [[TTServerManager sharedManager]getAlbumsGrouppById:self.group.group_id count:10 offset:0 onSuccess:^(NSArray *arrayWithAlbums) {
        
        if ([arrayWithAlbums count] > 0) {
            
            [self.albumArray removeAllObjects];
            
            [self.albumArray addObjectsFromArray:arrayWithAlbums];
            
            [self.refreshControl endRefreshing];
            
            [self.tableView reloadData];
            
            self.loadingData = NO;
        }
        
        
    } onFailure:^(NSError *error) {
        
    }];
    
}

- (void)collectionCellPressedAtIndex:(NSIndexPath *)indexPath {
    
}

- (void) getAlbumsFromServer {

    [[TTServerManager sharedManager]getAlbumsGrouppById:self.group.group_id count:10 offset:[self.albumArray count] onSuccess:^(NSArray *arrayWithAlbums) {
        
        if ([arrayWithAlbums count] > 0) {
            
            [self.albumArray addObjectsFromArray:arrayWithAlbums];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.albumArray count] - (int)[arrayWithAlbums count]; i < [self.albumArray count]; i++) {
                [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            self.loadingData = NO;
        }
        
        
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.albumArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"photosCell";
    
    TTAlbum *album = [self.albumArray objectAtIndex:indexPath.row];
    
    TTPhotosTableViewCell *cell = (TTPhotosTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[TTPhotosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault album:album reuseIdentifier:cellIdentifier];
    }
    
    cell.albumNameLabel.text = album.title;
    cell.albumPhotosCountLabel.text = [NSString stringWithFormat:@"%@ photos",album.size];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"detailCollectionSegue" sender:indexPath];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"detailCollectionSegue"]) {
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        TTAlbum *album = [self.albumArray objectAtIndex:indexPath.row];
        TTDetailCollectionViewController *vc = [segue destinationViewController];
        vc.album = album;
    }
}

- (void)dealloc {
    
    [self.tableView setDelegate:nil];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
