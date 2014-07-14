//
//  TTDetailCollectionViewController.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/8/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAlbum.h"

@interface TTDetailCollectionViewController : UIViewController

@property (strong,nonatomic) TTAlbum *album;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
