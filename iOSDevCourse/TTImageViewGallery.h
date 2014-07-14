//
//  TTImageViewGallery.h
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/12/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTVideo;

@protocol TTImageViewGalleryDelegete;

@interface TTImageViewGallery : UIView

@property (weak,nonatomic) id <TTImageViewGalleryDelegete> delegate;

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSMutableArray *framesArray;

- (instancetype) initWithImageArray:(NSArray *)imageArray startPoint:(CGPoint)point;

@end


@protocol TTImageViewGalleryDelegete <NSObject>

- (void)openVideo:(TTVideo *)video;

@end