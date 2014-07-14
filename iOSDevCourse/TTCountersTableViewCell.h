//
//  TTCountersTableViewCell.h
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/5/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTGroup.h"

@protocol TTCountersDelegete;

@interface TTCountersTableViewCell : UITableViewCell

@property (strong, nonatomic) TTGroup* group;
@property (weak,nonatomic) id <TTCountersDelegete> delegete;

@end

@protocol TTCountersDelegete <NSObject>

- (void)collectionCellPressedAtIndex:(NSIndexPath *)indexPath;

@end