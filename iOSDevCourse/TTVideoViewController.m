//
//  TTVideoViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/10/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTVideoViewController.h"
#import "TTDetailVideoTableViewCell.h"
#import "TTServerManager.h"
#import "UIImageView+AFNetworking.h"
#import "TTPostTableViewCell.h"
#import "TTComment.h"
#import "TTAddPostViewController.h"
#import "TTImageViewGallery.h"
#import "TTPhoto.h"

static CGSize CGSizeResizeToHeight(CGSize size, CGFloat height) {
    size.width *= height / size.height;
    size.height = height;
    return size;
}

@interface TTVideoViewController () <UITableViewDataSource,UITableViewDelegate,YTPlayerViewDelegate,UIScrollViewDelegate,UITextViewDelegate,TTAddPostDelegete>

@property (assign,nonatomic) BOOL loadingData;
@property (strong,nonatomic) NSMutableArray *commentArray;
@property (strong,nonatomic) UITextView *textView;
@property (strong,nonatomic) UIToolbar *toolBar;
@property (assign,nonatomic) CGRect keyboardBounds;
@property (strong,nonatomic) NSMutableArray *imageViewSize;

@end

@implementation TTVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageViewSize = [[NSMutableArray alloc]init];
    self.navigationItem.title = @"Video";
    self.view.backgroundColor = [UIColor whiteColor];
    self.commentArray = [NSMutableArray array];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addComment:)];
    
    self.navigationItem.rightBarButtonItem = addItem;
    
    
    
    [self getCommentsFromServer];
}

#pragma mark - TTAddPostDelegete

- (void)updateData {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getVideoComment:self.video.owner_id videoid:self.video.videoid count:20 offset:0 onSuccess:^(NSArray *videoCommentArray) {
            
            if ([videoCommentArray count] > 0) {
                
                [self.commentArray removeAllObjects];
                [self.imageViewSize removeAllObjects];
                
                [self.commentArray addObjectsFromArray:videoCommentArray];
                
                for (int i = (int)[self.commentArray count] - (int)[videoCommentArray count]; i < [self.commentArray count]; i++) {
                    
                    CGSize newSize = [self setFramesToImageViews:nil imageFrames:[[self.commentArray objectAtIndex:i] attachment] toFitSize:CGSizeMake(302, 400)];
                    
                    [self.imageViewSize addObject:[NSNumber numberWithFloat:roundf(newSize.height)]];
                }
                
                [self.tableView reloadData];
                
                self.loadingData = NO;
            }
            
            
        } onFailure:^(NSError *error) {
            
        }];
    }
    
}

- (void)addComment:(UIBarButtonItem *)sender {
    
    TTAddPostViewController *vc = [[TTAddPostViewController alloc]initWithTypePost:TTPostTypeVideo];
    vc.delegate = self;
    vc.data = self.video;
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nv animated:YES completion:nil];
    
}

- (CGSize)setFramesToImageViews:(NSArray *)imageViews imageFrames:(NSArray *)imageFrames toFitSize:(CGSize)frameSize {
    
    int N = (int)imageFrames.count;
    CGRect newFrames[N];
    
    float ideal_height = MAX(frameSize.height, frameSize.width) / N;
    float seq[N];
    float total_width = 0;
    for (int i = 0; i < [imageFrames count]; i++) {
        TTPhoto *image = [imageFrames objectAtIndex:i];
        CGSize size = CGSizeMake(image.width, image.height);
        
        CGSize newSize = CGSizeResizeToHeight(size, ideal_height);
        newFrames[i] = (CGRect) {{0, 0}, newSize};
        seq[i] = newSize.width;
        total_width += seq[i];
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


- (void)getCommentsFromServer {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getVideo:self.video.owner_id videoid:self.video.videoid onSuccess:^(TTVideo *video) {
            
            self.video = video;
            
            [self.tableView reloadData];
            
            [[TTServerManager sharedManager]getVideoComment:self.video.owner_id videoid:self.video.videoid count:20 offset:[self.commentArray count] onSuccess:^(NSArray *videoCommentArray) {
                
                if ([videoCommentArray count] > 0) {
                    
                    [self.commentArray addObjectsFromArray:videoCommentArray];
                    
                    NSMutableArray* newPaths = [NSMutableArray array];
                    for (int i = (int)[self.commentArray count] - (int)[videoCommentArray count]; i < [self.commentArray count]; i++) {
                        [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
                    }
                    
                    for (int i = (int)[self.commentArray count] - (int)[videoCommentArray count]; i < [self.commentArray count]; i++) {
                        
                        CGSize newSize = [self setFramesToImageViews:nil imageFrames:[[self.commentArray objectAtIndex:i] attachment] toFitSize:CGSizeMake(302, 400)];
                        
                        [self.imageViewSize addObject:[NSNumber numberWithFloat:roundf(newSize.height)]];
                    }
                    
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                    self.loadingData = NO;
                }
                
                
            } onFailure:^(NSError *error) {
                
            }];
            
            
        } onFailure:^(NSError *error) {
            
        }];
        
    }
    
}

#pragma mark - ActionButton

- (void)addLikeToVideo:(UIButton *)sender {
    
    if (!self.video.can_like) {
        
        [[TTServerManager sharedManager]postLikeOnWall:self.video.owner_id inPost:self.video.videoid type:@"video" onSuccess:^(NSDictionary *result) {
            
            NSDictionary *objects = [result objectForKey:@"response"];
            self.video.can_like = YES;
            self.video.like_count = [[objects objectForKey:@"likes"] stringValue];
            
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    } else {
        
        [[TTServerManager sharedManager]postDeleteLikeOnWall:self.video.owner_id inPost:self.video.videoid type:@"video" onSuccess:^(NSDictionary *result) {
            
            NSDictionary *objects = [result objectForKey:@"response"];
            self.video.can_like = NO;
            self.video.like_count = [[objects objectForKey:@"likes"] stringValue];
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    }
    
    
}

- (void)addLikeToComment:(UIButton *)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    TTComment *comment = [self.commentArray objectAtIndex:indexPath.row];

    
    
    if (comment.can_like) {
        [[TTServerManager sharedManager]postLikeOnWall:self.video.owner_id inPost:comment.coment_id type:@"video_comment" onSuccess:^(NSDictionary *result) {
            
            NSDictionary *objects = [result objectForKey:@"response"];
            comment.can_like = NO;
            comment.like_count = [[objects objectForKey:@"likes"] stringValue];
            
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"%@",error);
        }];
        
    } else {
        
        [[TTServerManager sharedManager]postDeleteLikeOnWall:self.video.owner_id  inPost:comment.coment_id  type:@"video_comment" onSuccess:^(NSDictionary *result) {
            
            NSDictionary *objects = [result objectForKey:@"response"];
            comment.can_like = YES;
            comment.like_count = [[objects objectForKey:@"likes"] stringValue];
            
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"%@",error);
        }];
        
    }
    
    
}

#pragma mark - TextCalculate

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

- (CGFloat)heightTextViewOfTextForString:(NSString *)aString fontSize:(CGFloat)fontSize {
    
    UIFont* font = [UIFont systemFontOfSize:fontSize];
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, nil];
    
    CGRect rect = [[self stringByStrippingHTML:aString] boundingRectWithSize:CGSizeMake(320, CGFLOAT_MAX)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                  attributes:attributes
                                                                     context:nil];
    
    return rect.size.height;
}

- (NSString *) stringByStrippingHTML:(NSString *)string {
    
    NSRange r;
    while ((r = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        
        string = [string stringByReplacingCharactersInRange:r withString:@""];
    }
    
    return string;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else {
    
        return [self.commentArray count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"detailVideoCell";
    static NSString *postCellIdentifier = @"postcell";
    
    if (indexPath.section == 0) {
        
        TTDetailVideoTableViewCell *cell = (TTDetailVideoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        NSDictionary *playerVars = @{ @"playsinline":@1, @"showinfo":@0 };
        
        if (self.video.playerURl != nil) {
            [cell.youTubeView loadWithVideoId:[self.video.playerURl lastPathComponent] playerVars:playerVars];
        }
        
        cell.groupNameLabel.text = [[[TTServerManager sharedManager] group] name];
        cell.dateUploadLabel.text = self.video.date;
        
        cell.nameVideoLabel.frame = CGRectMake(CGRectGetMinX(cell.nameVideoLabel.frame),
                                               CGRectGetMinY(cell.nameVideoLabel.frame),
                                               CGRectGetWidth(cell.nameVideoLabel.frame),
                                               [self heightLabelOfTextForString:self.video.title fontSize:14 widthLabel:CGRectGetWidth(cell.nameVideoLabel.frame)]);
        
        cell.nameVideoLabel.text = self.video.title;
        
        cell.viewsLabel.frame = CGRectMake(CGRectGetMinX(cell.viewsLabel.frame),
                                           CGRectGetMaxY(cell.nameVideoLabel.frame),
                                           CGRectGetWidth(cell.viewsLabel.frame),
                                           CGRectGetHeight(cell.viewsLabel.frame));
        
        cell.durationLabel.frame = CGRectMake(CGRectGetMinX(cell.durationLabel.frame),
                                           CGRectGetMaxY(cell.nameVideoLabel.frame),
                                           CGRectGetWidth(cell.durationLabel.frame),
                                           CGRectGetHeight(cell.durationLabel.frame));
        
        
        cell.viewsLabel.text = [NSString stringWithFormat:@"%@ views",self.video.views];
        cell.durationLabel.text = self.video.duration;
        
        cell.descriptionTextView.frame = CGRectMake(CGRectGetMinX(cell.descriptionTextView.frame),
                                                    CGRectGetMaxY(cell.viewsLabel.frame) - 5,
                                                    CGRectGetWidth(cell.descriptionTextView.frame),
                                                    [self heightTextViewOfTextForString:self.video.description fontSize:11] + 20);
        
        cell.descriptionTextView.text = [self stringByStrippingHTML:self.video.description];
        
        cell.likeBtn.frame = CGRectMake(CGRectGetMinX(cell.likeBtn.frame),
                                        CGRectGetMaxY(cell.descriptionTextView.frame),
                                        CGRectGetWidth(cell.likeBtn.frame),
                                        CGRectGetHeight(cell.likeBtn.frame));
        
        [cell.likeBtn setTitle:self.video.like_count forState:UIControlStateNormal];
        CALayer *imageLayerLike = cell.likeBtn.layer;
        [imageLayerLike setCornerRadius:3];
        [imageLayerLike setMasksToBounds:YES];
        
        [cell.likeBtn addTarget:self action:@selector(addLikeToVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[[[TTServerManager sharedManager] group] photo_200]]];
        
        __weak TTDetailVideoTableViewCell *weakCell = cell;
        
        [cell.groupImageView setImageWithURLRequest:request
                                   placeholderImage:nil
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                
                                                [UIView transitionWithView:weakCell.groupImageView
                                                                  duration:0.1f
                                                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                                                animations:^{
                                                                    weakCell.groupImageView.image = image;
                                                                    CALayer *imageLayer = weakCell.groupImageView.layer;
                                                                    [imageLayer setCornerRadius:20];
                                                                    [imageLayer setBorderWidth:3];
                                                                    [imageLayer setBorderColor:[UIColor whiteColor].CGColor];
                                                                    [imageLayer setMasksToBounds:YES];
                                                                    
                                                                } completion:NULL];
                                                
                                                
                                            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                
                                            }];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        
        TTPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:postCellIdentifier];
        
        if (!cell) {
            cell = [[TTPostTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postCellIdentifier];
        }
        
        TTComment *comment = [self.commentArray objectAtIndex:indexPath.row];
        
        
        
        cell.dateLabel.text = comment.date;
        
        if ([comment.text isEqualToString:@""]) {
            cell.postTextLabel.text = comment.url;
        } else {
            cell.postTextLabel.text = comment.text;
        }
        
        CGRect rect = cell.postTextLabel.frame;
        rect.size.height = [self heightLabelOfTextForString:comment.text fontSize:11.f widthLabel:CGRectGetWidth(rect)];
        cell.postTextLabel.frame = rect;
        
        [cell.addLikeBtn setTitle:comment.like_count forState:UIControlStateNormal];
        [cell.addLikeBtn addTarget:self action:@selector(addLikeToComment:) forControlEvents:UIControlEventTouchUpInside];
        NSURLRequest *request = nil;
        
        if (comment.from_user != nil) {
            request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:comment.from_user.photo_100]];
            cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",comment.from_user.first_name,comment.from_user.last_name];
            
        } else if (comment.from_group != nil) {
            request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:comment.from_group.photo_200]];
            cell.userNameLabel.text = [NSString stringWithFormat:@"%@",comment.from_group.name];
        }
        
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
    
        if ([comment.attachment count] > 0) {
            
            CGPoint point = CGPointZero;
            
            if (![comment.text isEqualToString:@""]) {
                point = CGPointMake(CGRectGetMinX(cell.postTextLabel.frame),CGRectGetMaxY(cell.postTextLabel.frame));
            } else {
                point = CGPointMake(CGRectGetMinX(cell.userImageView.frame),CGRectGetMaxY(cell.userImageView.frame));
            }
            
            TTImageViewGallery *galery = [[TTImageViewGallery alloc]initWithImageArray:comment.attachment startPoint:point];
            galery.tag = 11;
            
            [cell addSubview:galery];
            
            cell.addLikeBtn.frame = CGRectMake(CGRectGetMinX(cell.addLikeBtn.frame),
                                               CGRectGetMaxY(galery.frame),
                                               CGRectGetWidth(cell.addLikeBtn.frame),
                                               CGRectGetHeight(cell.addLikeBtn.frame));
            
        } else {
            cell.addLikeBtn.frame = CGRectMake(CGRectGetMinX(cell.addLikeBtn.frame),
                                               CGRectGetMaxY(cell.postTextLabel.frame),
                                               CGRectGetWidth(cell.addLikeBtn.frame),
                                               CGRectGetHeight(cell.addLikeBtn.frame));
        }
        
        
        
        return cell;
        
    }

    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        
        return 288 + [self heightLabelOfTextForString:self.video.title fontSize:14 widthLabel:307] + 14 + [self heightTextViewOfTextForString:self.video.description fontSize:11] + 25 + 20;

    } else {
        
        TTComment *comment = [self.commentArray objectAtIndex:indexPath.row];
        
        float height = 0;
        
        if (![comment.text isEqualToString:@""]) {
            height = height + (int)[self heightLabelOfTextForString:comment.text fontSize:11.f widthLabel:300];
        }
        
        if ([comment.attachment count] > 0) {
            
            height = height + [[self.imageViewSize objectAtIndex:indexPath.row]floatValue];
        }
        
        return height + 50 + 10 + 20;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - YTPlayerViewDelegate

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [playerView playVideo];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [_tableView setDelegate:nil];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

@end
