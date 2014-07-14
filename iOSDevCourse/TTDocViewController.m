//
//  TTDocViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/6/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTDocViewController.h"
#import "TTServerManager.h"
#import "TTDocuments.h"
#import "TTDocTableViewCell.h"
#import "TTDocWebViewController.h"

@interface TTDocViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) NSMutableArray *documentArray;
@property (assign,nonatomic) BOOL loadingData;
@property (strong,nonatomic) UIRefreshControl *refresh;

@end

@implementation TTDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Documents";
    self.view.backgroundColor = [UIColor whiteColor];
    self.documentArray = [NSMutableArray array];
    
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh addTarget:self action:@selector(refreshWall:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
    [self getDocumentsFromServer];

}

- (void)getDocumentsFromServer {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
    
        [[TTServerManager sharedManager]getDocumentGroup:self.group.group_id count:20 offset:[self.documentArray count] onSuccess:^(NSArray *docGroupArray) {
            
            if ([docGroupArray count] > 0) {
                
                [self.documentArray addObjectsFromArray:docGroupArray];
                
                NSMutableArray* newPaths = [NSMutableArray array];
                for (int i = (int)[self.documentArray count] - (int)[docGroupArray count]; i < [self.documentArray count]; i++) {
                    [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [self.refresh endRefreshing];
                self.loadingData = NO;
            }
            
            
        } onFailure:^(NSError *error) {
            
        }];
    }
    
}

- (void)refreshWall:(UIBarButtonItem *)sender {
    
    if (self.loadingData != YES) {
        self.loadingData = YES;
        
        [[TTServerManager sharedManager]getDocumentGroup:self.group.group_id count:20 offset:[self.documentArray count] onSuccess:^(NSArray *docGroupArray) {
            
            if ([docGroupArray count] > 0) {
                
                [self.documentArray removeAllObjects];
                [self.documentArray addObjectsFromArray:docGroupArray];
                [self.refresh endRefreshing];
                [self.tableView reloadData];
                self.loadingData = NO;
            }
            
            
        } onFailure:^(NSError *error) {
            
        }];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData) {
            [self getDocumentsFromServer];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.documentArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"docCell";
    
    TTDocTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TTDocTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    TTDocuments *doc = [self.documentArray objectAtIndex:indexPath.row];
    
    cell.fileNameLabel.text = doc.title;
    cell.sizeFileLabel.text = doc.size;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TTDocWebViewController *vc = [[TTDocWebViewController alloc]init];
    TTDocuments *doc = [self.documentArray objectAtIndex:indexPath.row];
    
    vc.documents = doc;
    
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [self presentViewController:nv animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_tableView setDelegate:nil];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

@end
