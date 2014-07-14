//
//  TTAddPostViewController.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/5/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTGroup.h"

typedef enum {
    TTPostTypeVideo,
    TTPostTypeWall,
    TTPostTypeWallComment,
    TTPostTypeBoardComment,
} TTPostType;

@protocol TTAddPostDelegete;

@interface TTAddPostViewController : UIViewController

@property (weak,nonatomic) id <TTAddPostDelegete> delegate;
@property (strong,nonatomic) id data;

- (id)initWithTypePost:(TTPostType)postType;

@end


@protocol TTAddPostDelegete <NSObject>

- (void)updateData;

@end