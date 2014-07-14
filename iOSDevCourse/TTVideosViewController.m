//
//  TTVideosViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/6/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTVideosViewController.h"
#import "TTVideoTableViewCell.h"
#import "TTServerManager.h"
#import "TTVideo.h"
#import "UIImageView+AFNetworking.h"
#import "TTVideoViewController.h"

static NSInteger videoInRequest = 20;

@interface TTVideosViewController () <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (strong,nonatomic) NSMutableArray *videosArray;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation TTVideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Videos";
    self.view.backgroundColor = [UIColor whiteColor];
    self.videosArray = [NSMutableArray array];
    
    [self getVideoFromServer];
    
}

- (void)getVideoFromServer {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getVideoGroup:self.group.group_id count:videoInRequest offset:[self.videosArray count] onSuccess:^(NSArray *videoGroupArray) {

                if ([videoGroupArray count] > 0) {
                    
                    [self.videosArray addObjectsFromArray:videoGroupArray];
                    
                    NSMutableArray* newPaths = [NSMutableArray array];
                    for (int i = (int)[self.videosArray count] - (int)[videoGroupArray count]; i < [self.videosArray count]; i++) {
                        [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    self.loadingData = NO;
                }
            
        } onFailure:^(NSError *error) {
            
        }];
    }

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.tableView.contentSize.height - scrollView.frame.size.height/2) {
        if (!self.loadingData) {
            [self getVideoFromServer];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.videosArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"videoCell";
    
    TTVideoTableViewCell *cell = (TTVideoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TTVideoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    TTVideo *video = [self.videosArray objectAtIndex:indexPath.row];
    
    cell.durationLabel.text = video.duration;
    cell.titleLabel.text = video.title;
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:video.photoURL]];
    
    __weak TTVideoTableViewCell *weakCell = cell;
    
    [cell.videoImageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       [UIView transitionWithView:weakCell.videoImageView
                                                         duration:0.3f
                                                          options:UIViewAnimationOptionTransitionCrossDissolve
                                                       animations:^{
                                                           weakCell.videoImageView.image = image;
                                                       } completion:NULL];
                                       
                                       
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       
                                   }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"detailVideoSegue" sender:indexPath];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"detailVideoSegue"]) {
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        TTVideo *video = [self.videosArray objectAtIndex:indexPath.row];
        TTVideoViewController *dest = [segue destinationViewController];
        dest.video = video;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView setDelegate:nil];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

@end
