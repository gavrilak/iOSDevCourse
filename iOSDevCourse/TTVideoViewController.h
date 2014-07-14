//
//  TTVideoViewController.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/10/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTVideo.h"

@interface TTVideoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TTVideo *video;

@end
