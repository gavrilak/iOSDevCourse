//
//  TTLoginViewController.m
//  iOSDevCourse
//
//  Created by Sergey Reshetnyak on 6/3/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTLoginViewController.h"
#import "TTAccessToken.h"

@interface TTLoginViewController () <UIWebViewDelegate>

@property (copy, nonatomic) TTLoginCompletionBlock completion;
@property (weak, nonatomic) UIWebView *webView;

@end

@implementation TTLoginViewController

- (id) initWithCompletionBlock:(TTLoginCompletionBlock) completion {
    
    if (self = [super init]) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:rect];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:webView];
    self.webView = webView;
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideLoginView:)];
    
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    self.navigationItem.title = @"Login";
    
    NSString* urlString =@"https://oauth.vk.com/authorize?"
    "client_id=4395172&"
    "scope=401430&"
    "redirect_uri=https://oauth.vk.com/blank.html&"
    "display=mobile&"
    "v=5.21&"
    "response_type=token";
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    webView.delegate = self;
    
    [webView loadRequest:request];
    
}

#pragma mark - UIWebViewDelegete

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[[request URL] description] rangeOfString:@"#access_token="].location != NSNotFound) {
        
        TTAccessToken* token = [[TTAccessToken alloc] init];
        
        NSString* query = [[request URL] description];
        
        NSArray* array = [query componentsSeparatedByString:@"#"];
        
        if ([array count] > 1) {
            query = [array lastObject];
        }
        
        NSArray* pairs = [query componentsSeparatedByString:@"&"];
        
        for (NSString* pair in pairs) {
            
            NSArray* values = [pair componentsSeparatedByString:@"="];
            
            if ([values count] == 2) {
                
                NSString* key = [values firstObject];
                
                if ([key isEqualToString:@"access_token"]) {
                    token.token = [values lastObject];
                } else if ([key isEqualToString:@"expires_in"]) {
                    
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    
                    token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                    
                } else if ([key isEqualToString:@"user_id"]) {
                    
                    token.userId = [values lastObject];
                }
            }
        }
        
        self.webView.delegate = nil;
        
        if (self.completion) {

            self.completion(token);
            
            [self dismissViewControllerAnimated:YES completion:nil];

        }

        return NO;
    }
    
    return YES;
}

#pragma mark - Actions

- (void)hideLoginView:(id)sender {
    
    if (self.completion) {
        self.completion(nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
