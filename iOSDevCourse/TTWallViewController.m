//
//  TTWallViewController.m
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/11/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTWallViewController.h"
#import "TTGroupInfoViewCell.h"
#import "TTCountersTableViewCell.h"
#import "TTAddPostTableViewCell.h"
#import "TTPostTableViewCell.h"
#import "TTGroup.h"
#import "TTWall.h"
#import "TTVideo.h"
#import "TTPhoto.h"
#import "UIImageView+AFNetworking.h"
#import "TTServerManager.h"
#import "TTImageViewGallery.h"
#import "TTVideosViewController.h"
#import "TTDocViewController.h"
#import "TTTopicsViewController.h"
#import "TTMembersViewController.h"
#import "TTAddPostViewController.h"
#import "TTVideoViewController.h"
#import "TTPostViewController.h"
#import "TTPhotosTableViewController.h"

static CGSize CGSizeResizeToHeight(CGSize size, CGFloat height) {
    size.width *= height / size.height;
    size.height = height;
    return size;
}

@interface TTWallViewController () <UITableViewDataSource,UITableViewDelegate,TTCountersDelegete,TTAddPostDelegete,TTImageViewGalleryDelegete>

@property (strong,nonatomic) TTGroup *group;
@property (strong,nonatomic) NSMutableArray *wallPostsArray;
@property (assign,nonatomic) BOOL loadingData;
@property (assign, nonatomic) BOOL firstTimeAppear;
@property (strong,nonatomic) UIRefreshControl *refresh;
@property (strong,nonatomic) NSMutableArray *imageViewSize;

@end

@implementation TTWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wallPostsArray = [[NSMutableArray alloc]init];
    self.imageViewSize = [[NSMutableArray alloc]init];
    self.tableView.alpha = 0.f;
    self.loadingData = YES;
    self.firstTimeAppear = YES;
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh addTarget:self action:@selector(refreshWall:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.333 green:0.584 blue:0.820 alpha:1.000];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [[TTServerManager sharedManager] authorizeUser:^(TTUser *user) {
        
        [[TTServerManager sharedManager]getGroupById:iOSDevCourseGroupID onSuccess:^(TTGroup *group) {
            self.group = group;
            self.navigationItem.title = group.name;
            [self.tableView reloadData];
            self.loadingData = NO;
            [self getWallPostFromServer];
            
            [UIView animateWithDuration:0.8f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                self.tableView.alpha = 1.f;
                
            } completion:^(BOOL finished) {
                
            }];
            
        } onFailure:^(NSError *error) {
            
        }];
        
    }];
    
}

#pragma mark - ServerRequest

- (void)getWallPostFromServer {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getWallPostGroup:self.group.group_id count:50 offset:[self.wallPostsArray count] onSuccess:^(NSArray *wallPost) {
            
            if ([wallPost count] > 0) {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    
                    [self.wallPostsArray addObjectsFromArray:wallPost];
                    
                    NSMutableArray *newPaths = [NSMutableArray array];
                    for (int i = (int)[self.wallPostsArray count] - (int)[wallPost count]; i < [self.wallPostsArray count]; i++) {
                        [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:4]];
                    }
                    
                    for (int i = (int)[self.wallPostsArray count] - (int)[wallPost count]; i < [self.wallPostsArray count]; i++) {
                        
                        CGSize newSize = [self setFramesToImageViews:nil imageFrames:[[self.wallPostsArray objectAtIndex:i] attachment] toFitSize:CGSizeMake(302, 400)];
                        
                        [self.imageViewSize addObject:[NSNumber numberWithFloat:roundf(newSize.height)]];
                    }
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        [self.tableView beginUpdates];
                        [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                        self.loadingData = NO;

                    });
                });
            }
            
        } onFailure:^(NSError *error) {
            
        }];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.tableView.contentSize.height - scrollView.frame.size.height) {
        if (self.loadingData != YES) {
            [self getWallPostFromServer];
        }
    }
}

#pragma mark - TextImageConfigure

- (CGSize)setFramesToImageViews:(NSArray *)imageViews imageFrames:(NSArray *)imageFrames toFitSize:(CGSize)frameSize {

    int N = (int)imageFrames.count;
    CGRect newFrames[N];
    
    float ideal_height = MAX(frameSize.height, frameSize.width) / N;
    float seq[N];
    float total_width = 0;
    for (int i = 0; i < [imageFrames count]; i++) {
        
        if ([[imageFrames objectAtIndex:i] isKindOfClass:[TTPhoto class]]) {
            TTPhoto *image = [imageFrames objectAtIndex:i];
             CGSize size = CGSizeMake(image.width, image.height);
            CGSize newSize = CGSizeResizeToHeight(size, ideal_height);
            newFrames[i] = (CGRect) {{0, 0}, newSize};
            seq[i] = newSize.width;
            total_width += seq[i];
            
        } else if ([[imageFrames objectAtIndex:i] isKindOfClass:[TTVideo class]]) {
            
            CGSize size = CGSizeMake(320, 240);
            CGSize newSize = CGSizeResizeToHeight(size, ideal_height);
            newFrames[i] = (CGRect) {{0, 0}, newSize};
            seq[i] = newSize.width;
            total_width += seq[i];
        }
        

    }
    
    int K = (int)roundf(total_width / frameSize.width);
    
    float M[N][K];
    float D[N][K];
    
    for (int i = 0 ; i < N; i++)
        for (int j = 0; j < K; j++)
            D[i][j] = 0;
    
    for (int i = 0; i < K; i++)
        M[0][i] = seq[0];
    
    for (int i = 0; i < N; i++)
        M[i][0] = seq[i] + (i ? M[i-1][0] : 0);
    
    float cost;
    for (int i = 1; i < N; i++) {
        for (int j = 1; j < K; j++) {
            M[i][j] = INT_MAX;
            
            for (int k = 0; k < i; k++) {
                cost = MAX(M[k][j-1], M[i][0]-M[k][0]);
                if (M[i][j] > cost) {
                    M[i][j] = cost;
                    D[i][j] = k;
                }
            }
        }
    }
    
    int k1 = K-1;
    int n1 = N-1;
    int ranges[N][2];
    while (k1 >= 0) {
        ranges[k1][0] = D[n1][k1]+1;
        ranges[k1][1] = n1;
        
        n1 = D[n1][k1];
        k1--;
    }
    ranges[0][0] = 0;
    
    float cellDistance = 5;
    float heightOffset = cellDistance, widthOffset;
    float frameWidth;
    for (int i = 0; i < K; i++) {
        float rowWidth = 0;
        frameWidth = frameSize.width - ((ranges[i][1] - ranges[i][0]) + 2) * cellDistance;
        
        for (int j = ranges[i][0]; j <= ranges[i][1]; j++) {
            rowWidth += newFrames[j].size.width;
        }
        
        float ratio = frameWidth / rowWidth;
        widthOffset = 0;
        
        for (int j = ranges[i][0]; j <= ranges[i][1]; j++) {
            newFrames[j].size.width *= ratio;
            newFrames[j].size.height *= ratio;
            newFrames[j].origin.x = widthOffset + (j - (ranges[i][0]) + 1) * cellDistance;
            newFrames[j].origin.y = heightOffset;
            
            widthOffset += newFrames[j].size.width;
        }
        heightOffset += newFrames[ranges[i][0]].size.height + cellDistance;
    }
    
    return CGSizeMake(frameSize.width, heightOffset);
}

- (CGRect)heightTextView:(UITextView *)view {

    CGFloat fixedWidth = view.frame.size.width;
    CGSize newSize = [view sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = view.frame;
    if (newSize.height > 200) {
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth),150);
    } else {
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    }
    
    return newFrame;
}

- (CGFloat)heightLabelOfTextForString:(NSString *)aString fontSize:(CGFloat)fontSize widthLabel:(CGFloat)width {
    
    UIFont* font = [UIFont systemFontOfSize:fontSize];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowBlurRadius = 0;
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentLeft];
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, paragraph, NSParagraphStyleAttributeName,shadow, NSShadowAttributeName, nil];
    
    CGRect rect = [aString boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attributes
                                        context:nil];
    
    return rect.size.height;
}

#pragma mark - Action

- (void)refreshWall:(UIRefreshControl *)sender {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getWallPostGroup:self.group.group_id count:50 offset:0 onSuccess:^(NSArray *wallPost) {
            
            if ([wallPost count] > 0) {
                [self.wallPostsArray removeAllObjects];
                [self.imageViewSize removeAllObjects];
                [self.wallPostsArray addObjectsFromArray:wallPost];
                
                for (int i = (int)[self.wallPostsArray count] - (int)[wallPost count]; i < [self.wallPostsArray count]; i++) {
                    
                    CGSize newSize = [self setFramesToImageViews:nil imageFrames:[[self.wallPostsArray objectAtIndex:i] attachment] toFitSize:CGSizeMake(306, 400)];
                    
                    [self.imageViewSize addObject:[NSNumber numberWithFloat:roundf(newSize.height)]];
                }
                
                [self.tableView reloadData];
                [self.refresh endRefreshing];
                self.loadingData = NO;
            }
            
        } onFailure:^(NSError *error) {
            
        }];
    }
    
}

- (void)addPostOnWall:(UIButton *)sender {
    
    TTAddPostViewController *vc = [[TTAddPostViewController alloc]initWithTypePost:TTPostTypeWall];
    vc.delegate = self;
    vc.data = self.group;
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nv animated:YES completion:nil];
    
}

- (void)addComment:(UIButton *)sender {

    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    TTWall *wall = [self.wallPostsArray objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"detailTopicsSegue" sender:wall];
}

- (void)addLike:(UIButton *)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    TTWall *wall = [self.wallPostsArray objectAtIndex:indexPath.row];
    
    
    
    if (wall.can_like) {
        [[TTServerManager sharedManager]postLikeOnWall:wall.owner_id inPost:wall.post_id type:@"post" onSuccess:^(NSDictionary *result) {
            
            NSDictionary *objects = [result objectForKey:@"response"];
            wall.can_like = NO;
            wall.likes_count = [[objects objectForKey:@"likes"] stringValue];
            
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"%@",error);
        }];
        
    } else {
        
        [[TTServerManager sharedManager]postDeleteLikeOnWall:wall.owner_id  inPost:wall.post_id  type:@"post" onSuccess:^(NSDictionary *result) {
            
            NSDictionary *objects = [result objectForKey:@"response"];
            wall.can_like = YES;
            wall.likes_count = [[objects objectForKey:@"likes"] stringValue];
            
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"%@",error);
        }];
        
    }
    
}

- (void)repost:(UIButton *)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    TTWall *wall = [self.wallPostsArray objectAtIndex:indexPath.row];
    
    [[TTServerManager sharedManager]repostOnMyWall:wall.owner_id inPost:wall.post_id withMessage:@"test" onSuccess:^(NSDictionary *result) {
        
        NSLog(@"%@",result);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

#pragma mark - TTAddPostDelegete

- (void)updateData {

    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getWallPostGroup:self.group.group_id count:50 offset:0 onSuccess:^(NSArray *wallPost) {
            
            if ([wallPost count] > 0) {
                [self.wallPostsArray removeAllObjects];
                [self.imageViewSize removeAllObjects];
                [self.wallPostsArray addObjectsFromArray:wallPost];
                
                for (int i = (int)[self.wallPostsArray count] - (int)[wallPost count]; i < [self.wallPostsArray count]; i++) {
                    
                    CGSize newSize = [self setFramesToImageViews:nil imageFrames:[[self.wallPostsArray objectAtIndex:i] attachment] toFitSize:CGSizeMake(306, 400)];
                    
                    [self.imageViewSize addObject:[NSNumber numberWithFloat:roundf(newSize.height)]];
                }
                
                [self.tableView reloadData];
                [self.refresh endRefreshing];
                self.loadingData = NO;
            }
            
        } onFailure:^(NSError *error) {
            
        }];
    }
    
}

#pragma mark - TTImageViewGalleryDelegete

- (void)openVideo:(TTVideo *)video {
    
    [self performSegueWithIdentifier:@"videoWallSegue" sender:video];
    
}

#pragma mark - TTCountersDelegete

- (void)collectionCellPressedAtIndex:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"membersSegue" sender:self];
        
    } else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"topicsSegue" sender:self];
        
    } else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"videoSegue" sender:self];
        
    } else if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"photosSegue" sender:self];
        
    } else if (indexPath.row == 4) {
        [self performSegueWithIdentifier:@"documentSegue" sender:self];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return [self.wallPostsArray count];
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *infoCellIdentifier = @"groupInfoCell";
    static NSString *counterCellIdentifier = @"counterCell";
    static NSString *grayCellIdentifier = @"grayCell";
    static NSString *addPostCellIdentifier = @"addpostCell";
    static NSString *postCellIdentifier = @"postcell";
    
    if (indexPath.section == 0) {
        
        TTGroupInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
        
        if (!cell) {
            cell = [[TTGroupInfoViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoCellIdentifier];
        }
        
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.group.photo_200]];
        
        __weak TTGroupInfoViewCell *weakCell = cell;
        
        [cell.groupPhotoView setImageWithURLRequest:request
                                       placeholderImage:nil
                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                    
                                                    weakCell.groupPhotoView.image = image;
                                                    
                                                    CALayer *imageLayer = weakCell.groupPhotoView.layer;
                                                    [imageLayer setCornerRadius:40];
                                                    [imageLayer setBorderWidth:3];
                                                    [imageLayer setBorderColor:[UIColor whiteColor].CGColor];
                                                    [imageLayer setMasksToBounds:YES];
                                                    
                                                }
                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                    
                                                }];
        
        cell.groupStatusLabel.text = self.group.is_closed ? @"Closed community" : @"Open community";
        cell.descriptionLabel.text = self.group.description;
        cell.groupNameLabel.text = self.group.name;
        cell.statusLabel.text = self.group.status;
        CALayer *imageLayer = cell.joinCommunityBtn.layer;
        [imageLayer setCornerRadius:5];
        [imageLayer setMasksToBounds:YES];
        if (self.group.is_member) {
            [cell.joinCommunityBtn setTitle:@"You are a member" forState:UIControlStateNormal];
        } else {
            [cell.joinCommunityBtn setTitle:@"Follow" forState:UIControlStateNormal];
        }
        
        return cell;
        
    } else if (indexPath.section == 1) {
        
        TTCountersTableViewCell *cell = [[TTCountersTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:counterCellIdentifier];
        
        cell.group = self.group;
        cell.delegete = self;
        
        return cell;

    } else if (indexPath.section == 2) {
            
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:grayCellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:grayCellIdentifier];
        }
        
        cell.backgroundColor = [UIColor colorWithRed:0.871 green:0.882 blue:0.902 alpha:1.000];
        
        return cell;
        
    } else if (indexPath.section == 3) {
     
        TTAddPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addPostCellIdentifier];
        
        [cell.addPostButton addTarget:self action:@selector(addPostOnWall:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else if (indexPath.section == 4) {
        
        TTPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:postCellIdentifier];
        
        if (!cell) {
            cell = [[TTPostTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postCellIdentifier];
        }
        
        TTWall *wall = [self.wallPostsArray objectAtIndex:indexPath.row];
        
        NSURLRequest *request = nil;
        
        if (wall.from_user != nil) {
            request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:wall.from_user.photo_100]];
            cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",wall.from_user.first_name,wall.from_user.last_name];
            
        } else if (wall.from_group != nil) {
            request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:wall.from_group.photo_200]];
            cell.userNameLabel.text = [NSString stringWithFormat:@"%@",wall.from_group.name];
        }

        cell.dateLabel.text = wall.date;
        cell.postTextLabel.text = wall.text;
        CGRect rect = cell.postTextLabel.frame;
        rect.size.height = [self heightLabelOfTextForString:wall.text fontSize:11.f widthLabel:CGRectGetWidth(rect)];
        cell.postTextLabel.frame = rect;
        
        [cell.addLikeBtn setTitle:wall.likes_count forState:UIControlStateNormal];
        [cell.addComentBtn setTitle:wall.comments_count forState:UIControlStateNormal];
        
        [cell.addLikeBtn addTarget:self action:@selector(addLike:) forControlEvents:UIControlEventTouchUpInside];
        [cell.repostBtn addTarget:self action:@selector(repost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.addComentBtn addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
        
        __weak TTPostTableViewCell *weakCell = cell;
        
        [cell.userImageView setImageWithURLRequest:request
                                   placeholderImage:nil
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                
                                                weakCell.userImageView.image = image;
                                                CALayer *imageLayer = weakCell.userImageView.layer;
                                                [imageLayer setCornerRadius:20];
                                                [imageLayer setBorderWidth:3];
                                                [imageLayer setBorderColor:[UIColor whiteColor].CGColor];
                                                [imageLayer setMasksToBounds:YES];
                                                
                                            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                
                                            }];
        
        if ([cell viewWithTag:11]) [[cell viewWithTag:11] removeFromSuperview];
        
        if ([wall.attachment count] > 0) {
            
            CGPoint point = CGPointZero;
            
            if (![wall.text isEqualToString:@""]) {
                point = CGPointMake(CGRectGetMinX(cell.postTextLabel.frame),CGRectGetMaxY(cell.postTextLabel.frame));
            } else {
                point = CGPointMake(CGRectGetMinX(cell.userImageView.frame),CGRectGetMaxY(cell.userImageView.frame));
            }
            
            TTImageViewGallery *galery = [[TTImageViewGallery alloc]initWithImageArray:wall.attachment startPoint:point];
            galery.delegate = self;
            galery.tag = 11;
            
            [cell addSubview:galery];
            
            cell.addLikeBtn.frame = CGRectMake(CGRectGetMinX(cell.addLikeBtn.frame),
                                               CGRectGetMaxY(galery.frame),
                                               CGRectGetWidth(cell.addLikeBtn.frame),
                                               CGRectGetHeight(cell.addLikeBtn.frame));
            
            cell.repostBtn.frame = CGRectMake(CGRectGetMinX(cell.repostBtn.frame),
                                               CGRectGetMaxY(galery.frame),
                                               CGRectGetWidth(cell.repostBtn.frame),
                                               CGRectGetHeight(cell.repostBtn.frame));
            
            cell.addComentBtn.frame = CGRectMake(CGRectGetMinX(cell.addComentBtn.frame),
                                               CGRectGetMaxY(galery.frame),
                                               CGRectGetWidth(cell.addComentBtn.frame),
                                               CGRectGetHeight(cell.addComentBtn.frame));
            
        } else {
            cell.addLikeBtn.frame = CGRectMake(CGRectGetMinX(cell.addLikeBtn.frame),
                                               CGRectGetMaxY(cell.postTextLabel.frame),
                                               CGRectGetWidth(cell.addLikeBtn.frame),
                                               CGRectGetHeight(cell.addLikeBtn.frame));
            
            cell.repostBtn.frame = CGRectMake(CGRectGetMinX(cell.repostBtn.frame),
                                              CGRectGetMaxY(cell.postTextLabel.frame),
                                              CGRectGetWidth(cell.repostBtn.frame),
                                              CGRectGetHeight(cell.repostBtn.frame));
            
            cell.addComentBtn.frame = CGRectMake(CGRectGetMinX(cell.addComentBtn.frame),
                                                 CGRectGetMaxY(cell.postTextLabel.frame),
                                                 CGRectGetWidth(cell.addComentBtn.frame),
                                                 CGRectGetHeight(cell.addComentBtn.frame));
        }
        
        
        return cell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return 125;
            break;
        case 1:
            return 45;
            break;
        case 2:
            return 18;
            break;
        case 3:
            return 30;
            break;
        case 4:
            {
                
                TTWall *wall = [self.wallPostsArray objectAtIndex:indexPath.row];
                
                float height = 0;
                
                if (![wall.text isEqualToString:@""]) {
                    height = height + (int)[self heightLabelOfTextForString:wall.text fontSize:11.f widthLabel:300];
                }
                
                if ([wall.attachment count] > 0) {

                    height = height + [[self.imageViewSize objectAtIndex:indexPath.row]floatValue];
                }

                return 46 + 10 + height + 20;
        
            }
            break;
        default:
            break;
    }
    
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [_tableView setDelegate:nil];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"videoSegue"]) {
        
        TTVideosViewController *vc = [segue destinationViewController];
        vc.group = self.group;
    } else if ([[segue identifier] isEqualToString:@"documentSegue"]) {
        
        TTDocViewController *vc = [segue destinationViewController];
        vc.group = self.group;
        
    } else if ([[segue identifier] isEqualToString:@"topicsSegue"]) {
        
        TTTopicsViewController *vc = [segue destinationViewController];
        vc.group = self.group;
        
    } else if ([[segue identifier] isEqualToString:@"membersSegue"]) {
        
        TTMembersViewController *vc = [segue destinationViewController];
        vc.group = self.group;
    } else if ([[segue identifier] isEqualToString:@"videoWallSegue"]) {
        
        TTVideoViewController *vc = [segue destinationViewController];
        TTVideo *video = (TTVideo *)sender;
        vc.video = video;
    } else if ([[segue identifier] isEqualToString:@"detailTopicsSegue"]) {
        
        TTPostViewController *vc = [segue destinationViewController];
        TTWall *wall = (TTWall *)sender;
        vc.wallPost = wall;
    } else if ([[segue identifier] isEqualToString:@"photosSegue"]) {
        
        TTPhotosTableViewController *vc = [segue destinationViewController];
        vc.group = self.group;
    }
    
}

@end
