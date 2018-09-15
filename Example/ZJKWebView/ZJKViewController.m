//
//  ZJKViewController.m
//  ZJKWebView
//
//  Created by k721684713@163.com on 09/15/2018.
//  Copyright (c) 2018 k721684713@163.com. All rights reserved.
//

#import "ZJKViewController.h"
#import "ZJKWebView-Prefix.pch"
#import <ZJKWebView/ZJKWebView.h>
@interface ZJKViewController ()<ZJKWebViewDelegate>

@property (nonatomic, strong) ZJKWebView *webView;

@end

@implementation ZJKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _webView = [[ZJKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    
}

#pragma mark ZJKWebViewDelegate
- (BOOL)webView:(ZJKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(ZJKWebView *)webView {
    NSLog(@"startLoad");
}
- (void)webViewDidFinishLoad:(ZJKWebView *)webView {
    NSLog(@"didFinishwebView");
}
- (void)webView:(ZJKWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"error");
}
- (void)webViewProgress:(float)progress {
    NSLog(@"progress : %f",progress);
}



@end
