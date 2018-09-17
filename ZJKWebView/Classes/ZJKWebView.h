//
//  ZJKWebView.h
//  Pods-ZJKWebView_Example
//
//  Created by sweet on 2018/9/15.
//

#import <UIKit/UIKit.h>

@class ZJKWebView;

typedef BOOL(^ZJKShouldStartLoadWithRequestBlock)(NSURLRequest *request, NSInteger navigationType);
typedef void(^ZJKWebViewDidStartLoadBlcok)(ZJKWebView *webView);
typedef void(^ZJKWebViewDidFinishLoadBlock)(ZJKWebView *webView);
typedef void(^ZJKWebViewDidFailLoadWithErrorBlock)(ZJKWebView * webView, NSError *error);

@protocol ZJKWebViewDelegate <NSObject>
@optional
- (BOOL)webView:(ZJKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType;
- (void)webViewDidStartLoad:(ZJKWebView *)webView;
- (void)webViewDidFinishLoad:(ZJKWebView *)webView;
- (void)webView:(ZJKWebView *)webView didFailLoadWithError:(NSError *)error;

- (void)webViewProgress:(float)progress;

@end

/**
 *  webView 封装，iOS8以下  采用UIWebview
 */
@interface ZJKWebView : UIView
@property (strong, nonatomic) id realWebView;
@property (strong, nonatomic) UIScrollView *webviewScrollView;
@property (weak, nonatomic) id<ZJKWebViewDelegate> delegate;
@property (assign, nonatomic, readonly) BOOL isWebViewContent;
@property (nonatomic) BOOL scalesPageToFit;
@property (strong, readonly, nonatomic) NSURL *URL;
- (instancetype)initWithFrame:(CGRect)frame
              shouldStartLoad:(ZJKShouldStartLoadWithRequestBlock)shouldStartLoadWithRequestBlock
                 didStartLoad:(ZJKWebViewDidStartLoadBlcok)startBlock
                    didFinish:(ZJKWebViewDidFinishLoadBlock)finishBlock
              didFailLoadWith:(ZJKWebViewDidFailLoadWithErrorBlock)errorBlock;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:( NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

- (void)reload;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;

- (void)clearColor;

- (BOOL)canGoBack;

- (void)removeObserver;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id obj, NSError *error))completionHandler;
/** 隐藏进度条*/
- (void)hiddenProgressLayer;
/** 设置是否允许WebView内的ScrollView滚动*/
- (void)setWebViewScrollViewScrollEnable:(BOOL)enable;
///不建议使用这个办法  因为会在内部等待webView的执行结果
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString;

@end
