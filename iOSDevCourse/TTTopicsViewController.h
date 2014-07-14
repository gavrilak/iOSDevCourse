//
//  TTTopicsViewController.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTGroup.h"

@interface TTTopicsViewController : UIViewController

@property (strong,nonatomic) TTGroup *group;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
