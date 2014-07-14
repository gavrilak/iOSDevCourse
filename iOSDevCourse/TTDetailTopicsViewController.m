//
//  TTDetailTopicsViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTDetailTopicsViewController.h"
#import "TTPostTableViewCell.h"
#import "TTServerManager.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "TTComment.h"
#import "TTPhoto.h"
#import "TTVideo.h"
#import "TTImageViewGallery.h"
#import "TTAddPostViewController.h"


#define DELTA_LABEL 49

static CGSize CGSizeResizeToHeight(CGSize size, CGFloat height) {
    size.width *= height / size.height;
    size.height = height;
    return size;
}

@interface TTDetailTopicsViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,TTImageViewGalleryDelegete,TTAddPostDelegete>

@property (assign,nonatomic) BOOL loadingData;
@property (strong,nonatomic) NSMutableArray *comentTopicsArray;
@property (strong,nonatomic) NSMutableArray *imageViewSize;

@end

@implementation TTDetailTopicsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.comentTopicsArray = [NSMutableArray array];
    self.imageViewSize = [NSMutableArray array];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addComment:)];
    
    self.navigationItem.rightBarButtonItem = addItem;
    
    [self getTopicsCommentFromServer];
    
}

- (void)updateData {

    [[TTServerManager sharedManager]getCommentTopicById:self.topics.topicsid ownerID:[[TTServerManager sharedManager] group].group_id count:MAX(10, [self.comentTopicsArray count]) offset:0 onSuccess:^(NSArray *wallComment) {

        if ([wallComment count] > 0) {
            
            [self.comentTopicsArray removeAllObjects];
            [self.imageViewSize removeAllObjects];
            [self.comentTopicsArray addObjectsFromArray:wallComment];
            
            for (int i = (int)[self.comentTopicsArray count] - (int)[wallComment count]; i < [self.comentTopicsArray count]; i++) {
                
                CGSize newSize = [self setFramesToImageViews:nil imageFrames:[[self.comentTopicsArray objectAtIndex:i] attachment] toFitSize:CGSizeMake(302, 400)];
                
                [self.imageViewSize addObject:[NSNumber numberWithFloat:roundf(newSize.height)]];
            }
            
            [self.tableView reloadData];
        }
        
    } onFailure:^(NSError *error) {
        
    }];
    
}

- (void)getTopicsCommentFromServer {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getCommentTopicById:self.topics.topicsid ownerID:[[TTServerManager sharedManager] group].group_id count:10 offset:[self.comentTopicsArray count] onSuccess:^(NSArray *wallComment) {
            
            if ([wallComment count] > 0) {
                
                [self.comentTopicsArray addObjectsFromArray:wallComment];
                
                NSMutableArray* newPaths = [NSMutableArray array];
                for (int i = (int)[self.comentTopicsArray count] - (int)[wallComment count]; i < [self.comentTopicsArray count]; i++) {
                    [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                for (int i = (int)[self.comentTopicsArray count] - (int)[wallComment count]; i < [self.comentTopicsArray count]; i++) {
                    
                    CGSize newSize = [self setFramesToImageViews:nil imageFrames:[[self.comentTopicsArray objectAtIndex:i] attachment] toFitSize:CGSizeMake(302, 400)];
                    
                    [self.imageViewSize addObject:[NSNumber numberWithFloat:roundf(newSize.height)]];
                }
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                self.loadingData = NO;
            }
            
        } onFailure:^(NSError *error) {
            
        }];
    }
}

- (void)openVideo:(TTVideo *)video {
    
    [self performSegueWithIdentifier:@"videoWallSegue" sender:video];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.tableView.contentSize.height - scrollView.frame.size.height) {
        if (!self.loadingData)
        {
            [self getTopicsCommentFromServer];
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

- (void)addLike:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    TTComment *comment = [self.comentTopicsArray objectAtIndex:indexPath.row];
    
    if (comment.can_like) {
        [[TTServerManager sharedManager]postLikeOnWall:iOSDevCourseGroupID inPost:comment.coment_id type:@"topic_comment" onSuccess:^(NSDictionary *result) {
            
            NSDictionary *objects = [result objectForKey:@"response"];
            
            comment.can_like = NO;
            comment.like_count = [[objects objectForKey:@"likes"] stringValue];
            
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"%@",error);
        }];
        
    } else {
        
        [[TTServerManager sharedManager]postDeleteLikeOnWall:iOSDevCourseGroupID inPost:comment.coment_id  type:@"topic_comment" onSuccess:^(NSDictionary *result) {
            
            NSDictionary *objects = [result objectForKey:@"response"];
            comment.can_like = YES;
            comment.like_count = [[objects objectForKey:@"likes"] stringValue];
            
            [self.tableView reloadData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"%@",error);
        }];
        
    }
}

- (void)addComment:(UIBarButtonItem *)sender {
    
    TTAddPostViewController *vc = [[TTAddPostViewController alloc]initWithTypePost:TTPostTypeBoardComment];
    vc.delegate = self;
    vc.data = self.topics;
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nv animated:YES completion:nil];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.comentTopicsArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *postIdentifier = @"detailTopicsCell";
    
    TTPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:postIdentifier];
    
    if (!cell) {
        cell = [[TTPostTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postIdentifier];
    }
    
    TTComment *coment = [self.comentTopicsArray objectAtIndex:indexPath.row];
    
    cell.postTextLabel.text = coment.text;
    cell.dateLabel.text = coment.date;
    
    NSURLRequest *request = nil;
    
    if (coment.from_user != nil) {
        request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:coment.from_user.photo_100]];
        cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",coment.from_user.first_name,coment.from_user.last_name];
        
    } else if (coment.from_group != nil) {
        request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:coment.from_group.photo_200]];
        cell.userNameLabel.text = [NSString stringWithFormat:@"%@",coment.from_group.name];
    }
    
    cell.dateLabel.text = coment.date;
    cell.postTextLabel.text = coment.text;
    CGRect rect = cell.postTextLabel.frame;
    rect.size.height = [self heightLabelOfTextForString:coment.text fontSize:11.f widthLabel:CGRectGetWidth(rect)];
    cell.postTextLabel.frame = rect;
    
    [cell.addLikeBtn setTitle:coment.like_count forState:UIControlStateNormal];
    
    [cell.addLikeBtn addTarget:self action:@selector(addLike:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    if ([coment.attachment count] > 0) {
        
        CGPoint point = CGPointZero;
        
        if (![coment.text isEqualToString:@""]) {
            point = CGPointMake(CGRectGetMinX(cell.postTextLabel.frame),CGRectGetMaxY(cell.postTextLabel.frame));
        } else {
            point = CGPointMake(CGRectGetMinX(cell.userImageView.frame),CGRectGetMaxY(cell.userImageView.frame));
        }
        
        TTImageViewGallery *galery = [[TTImageViewGallery alloc]initWithImageArray:coment.attachment startPoint:point];
        galery.delegate = self;
        galery.tag = 11;
        
        [cell addSubview:galery];
        
        cell.addLikeBtn.frame = CGRectMake(CGRectGetMinX(cell.addLikeBtn.frame),
                                           CGRectGetMaxY(galery.frame),
                                           CGRectGetWidth(cell.addLikeBtn.frame),
                                           CGRectGetHeight(cell.addLikeBtn.frame));
        
        cell.addComentBtn.frame = CGRectMake(CGRectGetMinX(cell.addComentBtn.frame),
                                             CGRectGetMaxY(galery.frame),
                                             CGRectGetWidth(cell.addComentBtn.frame),
                                             CGRectGetHeight(cell.addComentBtn.frame));
        
    } else {
        cell.addLikeBtn.frame = CGRectMake(CGRectGetMinX(cell.addLikeBtn.frame),
                                           CGRectGetMaxY(cell.postTextLabel.frame),
                                           CGRectGetWidth(cell.addLikeBtn.frame),
                                           CGRectGetHeight(cell.addLikeBtn.frame));
        
        cell.addComentBtn.frame = CGRectMake(CGRectGetMinX(cell.addComentBtn.frame),
                                             CGRectGetMaxY(cell.postTextLabel.frame),
                                             CGRectGetWidth(cell.addComentBtn.frame),
                                             CGRectGetHeight(cell.addComentBtn.frame));
    }
    
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TTComment *coment = [self.comentTopicsArray objectAtIndex:indexPath.row];
    
    float height = 0;
    
    if (![coment.text isEqualToString:@""]) {
        height = height + (int)[self heightLabelOfTextForString:coment.text fontSize:11.f widthLabel:300];
    }
    
    if ([coment.attachment count] > 0) {
        
        height = height + [[self.imageViewSize objectAtIndex:indexPath.row]floatValue];
    }
    
    return 46 + 10 + height + 20;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView setDelegate:nil];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
