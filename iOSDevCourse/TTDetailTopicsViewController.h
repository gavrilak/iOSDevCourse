//
//  TTDetailTopicsViewController.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTopics.h"

@interface TTDetailTopicsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) TTTopics *topics;

@end
