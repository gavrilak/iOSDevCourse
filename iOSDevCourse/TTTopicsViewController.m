//
//  TTTopicsViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTTopicsViewController.h"
#import "TTServerManager.h"
#import "TTTopicsTableViewCell.h"
#import "TTUser.h"
#import "TTTopics.h"
#import "UIImageView+AFNetworking.h"
#import "TTDetailTopicsViewController.h"

@interface TTTopicsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) NSMutableArray *topicsArray;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation TTTopicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Topics";
    self.topicsArray = [NSMutableArray array];
    [self getTopicsFromServer];
    
    
}

- (void)getTopicsFromServer {
    
    if (self.loadingData != YES) {
        
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getTopicsGroup:self.group.group_id count:50 offset:[self.topicsArray count] onSuccess:^(NSArray *topicsGroupArray) {
            
            if ([topicsGroupArray count] > 0) {
                
                [self.topicsArray addObjectsFromArray:topicsGroupArray];
                
                NSMutableArray* newPaths = [NSMutableArray array];
                for (int i = (int)[self.topicsArray count] - (int)[topicsGroupArray count]; i < [self.topicsArray count]; i++) {
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.tableView.contentSize.height - scrollView.frame.size.height/2) {
        if (!self.loadingData) {
            [self getTopicsFromServer];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.topicsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"topicsCell";
    
    TTTopicsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TTTopicsTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    TTTopics *topics = [self.topicsArray objectAtIndex:indexPath.row];
    
    cell.titleTopicLabel.text = topics.title;
    cell.commentsCountLabel.text = topics.comments;
    
    cell.lastCommentLabel.text = topics.last_comment;
    
    cell.dateLastCommentLabel.text = topics.updated;
    cell.nameProfileLabel.text = [NSString stringWithFormat:@"%@ %@",topics.user.first_name,topics.user.last_name];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:topics.user.photo_100]];
    
    __weak TTTopicsTableViewCell *weakCell = cell;
    
    [cell.profileImageView setImageWithURLRequest:request
                               placeholderImage:nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {

                                            weakCell.profileImageView.image = image;
                                            CALayer *imageLayer = weakCell.profileImageView.layer;
                                            [imageLayer setCornerRadius:20];
                                            [imageLayer setBorderWidth:3];
                                            [imageLayer setBorderColor:[UIColor whiteColor].CGColor];
                                            [imageLayer setMasksToBounds:YES];

                                        }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            
                                        }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self performSegueWithIdentifier:@"detailTopicsSegue" sender:indexPath];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"detailTopicsSegue"]) {
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        TTTopics *topics = [self.topicsArray objectAtIndex:indexPath.row];
        TTDetailTopicsViewController *dest = [segue destinationViewController];
        dest.topics = topics;
        
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
