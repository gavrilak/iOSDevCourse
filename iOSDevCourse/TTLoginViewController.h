//
//  TTLoginViewController.h
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/3/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTAccessToken;

typedef void(^TTLoginCompletionBlock)(TTAccessToken* token);

@interface TTLoginViewController : UIViewController

- (id)initWithCompletionBlock:(TTLoginCompletionBlock) completion;

@end
