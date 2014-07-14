//
//  TTAddPostViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/5/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTAddPostViewController.h"
#import "TTServerManager.h"
#import "RBImagePickerController.h"
#import "TTVideo.h"
#import "TTWall.h"
#import "TTTopics.h"

#define MAX_IMAGE_IN_VIDEO_POST 2
#define MAX_IMAGE_IN_WALL_POST 5

@interface TTAddPostViewController () <UITextViewDelegate,RBImagePickerDataSource,RBImagePickerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong,nonatomic) RBImagePickerController *imagePicker;
@property (strong,nonatomic) UITextView *textView;
@property (strong,nonatomic) UIToolbar *toolBar;
@property (strong,nonatomic) UIImageView *atachment;
@property (strong,nonatomic) UIBarButtonItem *done;
@property (strong,nonatomic) UIBarButtonItem *addPhoto;
@property (assign,nonatomic) CGRect keyboardBounds;
@property (assign,nonatomic) TTPostType type;
@property (strong, nonatomic) UICollectionView *colectionView;
@property (strong,nonatomic) NSMutableArray *imgArray;

@end

@implementation TTAddPostViewController

- (id)initWithTypePost:(TTPostType)postType {
    
    if (self = [super init]) {
        self.type = postType;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imagePicker = [[RBImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.dataSource = self;
    self.imagePicker.selectionType = RBMultipleImageSelectionType;
    self.imagePicker.title = @"Custom Title";
    self.imagePicker.navigationController.navigationItem.leftBarButtonItem.title = @"no";
    
    self.imgArray = [NSMutableArray array];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    layout.minimumInteritemSpacing = 4.0;
    layout.minimumLineSpacing = 4.0;
    layout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
    self.colectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 25, 320, 240) collectionViewLayout:layout];
    [self.colectionView setDataSource:self];
    [self.colectionView setDelegate:self];
    [self.colectionView setShowsHorizontalScrollIndicator:NO];
    self.colectionView.scrollEnabled = NO;
    [self.colectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"colectionCell"];
    [self.colectionView setBackgroundColor:[UIColor clearColor]];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hidePostView:)];
    self.done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addPostOnWall:)];
    self.done.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.done;
    self.navigationItem.leftBarButtonItem = cancel;

    
    UITextView * txtview = [[UITextView alloc]initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];

    [txtview setDelegate:self];
    [txtview setReturnKeyType:UIReturnKeyDefault];
    [txtview setTag:1];
    txtview.scrollEnabled = NO;
    self.textView = txtview;
    [self.textView addSubview:self.colectionView];
    [self.view addSubview:self.textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.backgroundColor = [UIColor grayColor];
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    self.addPhoto = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addPhoto:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [items addObjectsFromArray:@[flexibleSpace,self.addPhoto]];
    [toolbar setItems:items animated:NO];
    
    self.toolBar = toolbar;
    [self.view addSubview:self.toolBar];
    
    [self.textView becomeFirstResponder];
    
}

- (void)keyboardWillShow: (NSNotification *)notification {
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.keyboardBounds = [(NSValue *)[[notification userInfo] objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    [self.textView setFrame:CGRectMake(0, 0, self.textView.frame.size.width, self.view.frame.size.height - self.keyboardBounds.size.height - self.toolBar.frame.size.height)];
    [self.toolBar setFrame:CGRectMake(0.0f, self.view.frame.size.height - self.keyboardBounds.size.height - self.toolBar.frame.size.height,self.toolBar.frame.size.width, self.toolBar.frame.size.height)];
    [UIView commitAnimations];
}

- (void)keyboardWillHide: (NSNotification *)notification {
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    [self.textView setFrame:CGRectMake(0, 0, self.textView.frame.size.width, self.view.frame.size.height - self.toolBar.frame.size.height)];
    [self.toolBar setFrame:CGRectMake(0.0f, self.view.frame.size.height - self.toolBar.frame.size.height,self.toolBar.frame.size.width, self.toolBar.frame.size.height)];
    [UIView commitAnimations];
    
}

- (void)addPhoto:(UIBarButtonItem *)sender {


    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) {
        self.done.enabled = NO;
    } else {
        self.done.enabled = YES;
    }
    
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.colectionView setFrame:CGRectMake(self.colectionView.frame.origin.x, newFrame.size.height, self.colectionView.frame.size.width, self.colectionView.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

#pragma mark - UICollectionViewDataSource

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.imgArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *counerCell=[collectionView dequeueReusableCellWithReuseIdentifier:@"colectionCell" forIndexPath:indexPath];
    
    
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(7, 7, 61, 61)];

    CALayer *imageLayer = imgView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setMasksToBounds:YES];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    
    [btn setImage:[UIImage imageNamed:@"close_img.png"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
    
    btn.tag = 10;
    imgView.tag = 11;
    
    if ([counerCell viewWithTag:11]) [[counerCell viewWithTag:11] removeFromSuperview];
    if ([counerCell viewWithTag:10]) [[counerCell viewWithTag:10] removeFromSuperview];
    
    if (imgView) [imgView removeFromSuperview];
    if (btn) [btn removeFromSuperview];
    
    imgView.image = [self.imgArray objectAtIndex:indexPath.row];
    
    
    [counerCell addSubview:imgView];
    [counerCell addSubview:btn];
    
    return counerCell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(75, 75);
}

- (void)removeImage:(UIButton *)sender {

        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.colectionView];
        NSIndexPath *indexPath = [self.colectionView indexPathForItemAtPoint:buttonPosition];
        if (indexPath != nil) {
            
            [self.imgArray removeObjectAtIndex:indexPath.row];
            
            [self.colectionView deleteItemsAtIndexPaths:@[indexPath]];
            
            if (self.type == TTPostTypeVideo && [self.imgArray count] < MAX_IMAGE_IN_VIDEO_POST) {
                
                self.addPhoto.enabled = YES;
                
                
            } else if (self.type == TTPostTypeWall && [self.imgArray count] < MAX_IMAGE_IN_WALL_POST) {
                
                self.addPhoto.enabled = YES;
                
            }
            
            
        }
    
}

#pragma mark - RBImagePickerDataSource

- (void)imagePickerController:(RBImagePickerController *)imagePicker didFinishPickingImagesWithURL:(NSArray *)imageURLS {
    
    if ([imageURLS count] > 0) {
            
        [self.imgArray addObjectsFromArray:imageURLS];
        [self.colectionView reloadData];
        
        if (self.type == TTPostTypeVideo && [self.imgArray count] == MAX_IMAGE_IN_VIDEO_POST) {
            
            self.addPhoto.enabled = NO;
            
        } else if (self.type == TTPostTypeWall && [self.imgArray count] == MAX_IMAGE_IN_WALL_POST) {
            
            self.addPhoto.enabled = NO;
            
        }
        
        
    }

}

- (void)imagePickerControllerDidCancel:(RBImagePickerController *)imagePicker {
    
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self.textView becomeFirstResponder];
    
}

#pragma mark - RBImagePickerDataSource

- (NSInteger)imagePickerControllerMaxSelectionCount:(RBImagePickerController *)imagePicker {
    
    if (self.type == TTPostTypeVideo) {
        
        if ([self.imgArray count] < MAX_IMAGE_IN_VIDEO_POST) {
            return MAX_IMAGE_IN_VIDEO_POST - [self.imgArray count];
        } else {
            return 0;
        }
        
    } else if (self.type == TTPostTypeWall) {
        
        if ([self.imgArray count] < MAX_IMAGE_IN_WALL_POST) {
            return MAX_IMAGE_IN_WALL_POST - [self.imgArray count];
        } else {
            return 0;
        }
        
    } else {
        return 10;
    }
    
}

- (NSInteger)imagePickerControllerMinSelectionCount:(RBImagePickerController *)imagePicker {
    return 0;
}


- (void)hidePostView:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPostOnWall:(UIBarButtonItem *)sender {
    
    if (self.type == TTPostTypeVideo) {
        TTVideo *video = (TTVideo *)self.data;
        
        [[TTServerManager sharedManager]postVideoCreateCommentText:self.textView.text image:self.imgArray onGroupWall:[[TTServerManager sharedManager] group].group_id videoid:video.videoid onSuccess:^(id result) {
            
            [self.delegate updateData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
    } else if (self.type == TTPostTypeWall) {

        [[TTServerManager sharedManager]postWallCreateCommentText:self.textView.text image:self.imgArray onGroupWall:[[TTServerManager sharedManager] group].group_id onSuccess:^(id result) {
            [self.delegate updateData];
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    } else if (self.type == TTPostTypeWallComment) {
        
        TTWall *wall = (TTWall *)self.data;
        
        [[TTServerManager sharedManager]postWallAddCommentText:self.textView.text image:self.imgArray onGroupWall:wall.owner_id onGroupTopic:wall.post_id onSuccess:^(id result) {
            
            [self.delegate updateData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
         
    } else if (self.type == TTPostTypeBoardComment) {
        
        TTTopics *topic = (TTTopics *)self.data;
        
        [[TTServerManager sharedManager]postTopicAddCommentText:self.textView.text image:self.imgArray onGroupWall:iOSDevCourseGroupID onGroupTopic:topic.topicsid onSuccess:^(id result) {
            
            [self.delegate updateData];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
            
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
