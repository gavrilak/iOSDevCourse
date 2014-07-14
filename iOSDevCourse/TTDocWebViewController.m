//
//  TTDocWebViewController.m
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/14/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTDocWebViewController.h"

@interface TTDocWebViewController () <UIWebViewDelegate,UIScrollViewDelegate,UIActionSheetDelegate>

@property (strong,nonatomic) UILabel *titleViewLabel;

@property (weak, nonatomic) UIWebView *webView;

@property (assign, nonatomic) CGFloat lastOffsetY;

@end

@implementation TTDocWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:rect];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:webView];
    self.webView = webView;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIBarButtonItem *close = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeModalView:)];
    
    self.navigationItem.leftBarButtonItem = close;
    
    UIBarButtonItem *openIn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openIn:)];
    
    self.navigationItem.rightBarButtonItem = openIn;
    
    self.navigationItem.title = @"Document";
    
    NSURL *url = [NSURL URLWithString:self.documents.url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    self.webView.scrollView.delegate = self;
    [webView loadRequest:request];

}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    bool hide = (scrollView.contentOffset.y > self.lastOffsetY);
    [[self navigationController] setNavigationBarHidden:hide animated:YES];
    
}

#pragma mark - UIWebViewDelegete

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)closeModalView:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openIn:(UIBarButtonItem *)sender {
    
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:self.documents.url
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"Open in Safari",nil];
                                  
                                  
    [actSheet showInView:self.view];
                                  
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.documents.url]];
    }
}

- (void)dealloc {
    self.webView.scrollView.delegate = nil;
    self.webView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
