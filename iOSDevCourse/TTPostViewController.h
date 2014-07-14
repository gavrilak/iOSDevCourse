//
//  TTPostViewController.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/4/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTWall.h"

@interface TTPostViewController : UIViewController

@property (nonatomic,strong) TTWall *wallPost;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
