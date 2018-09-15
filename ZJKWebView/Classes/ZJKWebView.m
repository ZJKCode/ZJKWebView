//
//  ZJKWebView.m
//  Pods-ZJKWebView_Example
//
//  Created by sweet on 2018/9/15.
//

#define iOS10 ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)

#define SCREENWIDTH      [UIScreen mainScreen].bounds.size.width

#define SCREENHEIGHT     [UIScreen mainScreen].bounds.size.height

#define UIColorRGB(rgb) ([[UIColor alloc] initWithRed:(((rgb >> 16) & 0xff) / 255.0f) green:(((rgb >> 8) & 0xff) / 255.0f) blue:(((rgb) & 0xff) / 255.0f) alpha:1.0f])

#define HPROPORTION2 ([UIScreen mainScreen].bounds.size.height == 480?568/667.f:[UIScreen mainScreen].bounds.size.height != 812? [UIScreen mainScreen].bounds.size.height/667 : [UIScreen mainScreen].bounds.size.height/812)

#define kNormalBlueColor UIColorRGB(0x3f569c)

#define kNormalRedColor UIColorRGB(0xfe5722)

#import "ZJKWebView.h"
#import <WebKit/WebKit.h>

NSString *completeRPCURLPath = @"/njkwebviewprogressproxy/complete";

#define CJQSystemVersion  [[[UIDevice currentDevice] systemVersion] floatValue]

static float version = 8.0;
const float CJQInitialProgressValue = 0.1f;
const float CJQInteractiveProgressValue = 0.5f;
const float CJQFinalProgressValue = 0.9f;

@interface ZJKWebView ()<UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property (strong, nonatomic)CAShapeLayer * progressLayer;
@property (assign, nonatomic)float progress;


@end

@implementation ZJKWebView {
    NSUInteger _loadingCount;
    NSUInteger _maxLoadCount;
    NSURL *_currentURL;
    BOOL _interactive;
}
@synthesize scalesPageToFit = _scalesPageToFit;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!_realWebView) {
            if (CJQSystemVersion < version) {
                UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
                webView.delegate = self;
                webView.opaque = NO;
                _realWebView = webView;
                _isWebViewContent = YES;
                _webviewScrollView = webView.scrollView;
                webView.backgroundColor = [UIColor whiteColor];
                webView.scrollView.showsVerticalScrollIndicator = NO;
                webView.scrollView.showsHorizontalScrollIndicator = NO;
                [self addSubview:_realWebView];
                _maxLoadCount = _loadingCount = 0;
                _interactive = NO;
            }else{
                WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
                configuration.selectionGranularity = iOS10? WKSelectionGranularityDynamic:WKSelectionGranularityCharacter;
                configuration.preferences.javaScriptEnabled = YES;
                WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)) configuration:configuration];
                _realWebView = webView;
                _isWebViewContent = NO;
                webView.navigationDelegate = self;
                webView.UIDelegate = self;
                webView.scrollView.showsVerticalScrollIndicator = NO;
                webView.scrollView.showsHorizontalScrollIndicator = NO;
                webView.backgroundColor=[UIColor whiteColor];
                _webviewScrollView = webView.scrollView;
                [self addSubview:_realWebView];
                
                [webView addObserver:self forKeyPath:@"estimatedProgress" options:0 context:nil];
                
                /** 绘制线段Path*/
                            CGMutablePathRef linePath = nil;
                            linePath = CGPathCreateMutable();//开辟内存空间
                            CGPathMoveToPoint(linePath, NULL,0, 64);
                            CGPathAddLineToPoint(linePath, NULL, SCREENWIDTH ,64);
                
                            /** 创建承载线段Path的ShapeLayer类*/
                            [self.layer addSublayer:({
                                _progressLayer = [CAShapeLayer layer];
                                _progressLayer.frame = self.bounds;
                                _progressLayer.fillColor = [[UIColor clearColor] CGColor];
                                _progressLayer.strokeColor = [kNormalBlueColor CGColor];
                                _progressLayer.lineCap = kCALineCapSquare;
                                _progressLayer.lineWidth = 3;
                                _progressLayer.path = linePath;
                
                                CALayer *gradientLayer = [CALayer layer];
                                CAGradientLayer *gradientLayer1 =  [CAGradientLayer layer];
                                gradientLayer1.frame = CGRectMake(0, 0, SCREENWIDTH/2, 3 * HPROPORTION2);
                                [gradientLayer1 setColors:[NSArray arrayWithObjects:(id)[[UIColor redColor] CGColor],(id)[UIColorRGB(0xfde802) CGColor], nil]];
                                [gradientLayer1 setLocations:@[@0.5,@0.9,@1 ]];
                                [gradientLayer1 setStartPoint:CGPointMake(0.5, 1)];
                                [gradientLayer1 setEndPoint:CGPointMake(0.5, 0)];
                                [gradientLayer addSublayer:gradientLayer1];
                
                                CAGradientLayer *gradientLayer2 =  [CAGradientLayer layer];
                                [gradientLayer2 setLocations:@[@0.1,@0.5,@1]];
                                gradientLayer2.frame = CGRectMake(SCREENWIDTH/2, 0, SCREENWIDTH/2, 3 * HPROPORTION2);
                                [gradientLayer2 setColors:[NSArray arrayWithObjects:(id)[UIColorRGB(0xfde802) CGColor],(id)[kNormalRedColor CGColor], nil]];
                                [gradientLayer2 setStartPoint:CGPointMake(0.5, 0)];
                                [gradientLayer2 setEndPoint:CGPointMake(0.5, 1)];
                                [gradientLayer addSublayer:gradientLayer2];
                                [gradientLayer setMask:_progressLayer]; //用progressLayer来截取渐变层
                                _progressLayer.hidden = YES;
                                _progressLayer;
                            })];
                            CGPathRelease(linePath);
                
            }
        }
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (CJQSystemVersion<version) {
        UIWebView *webView =  (UIWebView *)_realWebView;
        [webView setFrame:frame];
    } else {
        WKWebView *webView = (WKWebView *)_realWebView;
        [webView setFrame:frame];
    }
}

- (void)setWebViewScrollViewScrollEnable:(BOOL)enable {
    if (CJQSystemVersion<version) {
        UIWebView *webView =  (UIWebView *)_realWebView;
        [webView.scrollView setScrollEnabled:enable];
    } else {
        WKWebView *webView = (WKWebView *)_realWebView;
        [webView.scrollView setScrollEnabled:enable];
    }
}

- (NSURL *)URL {
    NSURL *url;
    if (CJQSystemVersion<version) {
        UIWebView *webView =  (UIWebView *)_realWebView;
        url = webView.request.URL;
    } else {
        WKWebView *webView = (WKWebView *)_realWebView;
        url = webView.URL;
    }
    return url;
}

#pragma mark -UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    /** 如果URL的目录同已完成的路径，则执行加载完成 */
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return NO;
    }
    BOOL ret = YES;
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        ret = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    [self configUrlWithWebView:webView request:request withRet:ret];
    return ret;
}

- (void)configUrlWithWebView:(UIWebView *)webView request:(NSURLRequest *)request withRet:(BOOL)ret {
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTPOrLocalFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    if(ret && !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation) {
        _currentURL = request.URL;
        [self resetProgress];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
    
    _loadingCount ++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);
    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
    _loadingCount--;
    [self incrementProgress];
    [self configDidFinishLoad:webView];
}

- (void)configDidFinishLoad:(UIWebView *)webView {
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
    _loadingCount--;
    [self incrementProgress];
    [self didFailLoad:webView withError:error];
}

- (void)didFailLoad:(UIWebView *)webView withError:(NSError *)error {
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
}
#pragma mark -WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        result = [self.delegate webView:self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    }
    if (result) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if ([webView.URL.host isEqualToString:@"static.caijinquan.com"]) {
        
        NSURLCredential * cred = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,cred);
        
    }else{
        NSURLCredential * cred = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,cred);
        
    }
    
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
}
#pragma mark - WKScriptMessageHandler delegate
/*! @abstract Invoked when a script message is received from a webpage.
 @param userContentController The user content controller invoking the
 delegate method.
 @param message The script message received.
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
}
#pragma mark -Action

- (void)loadRequest:(NSURLRequest *)request{
    if (_isWebViewContent) {
        [(UIWebView *)_realWebView loadRequest:request];
    }else{
        [(WKWebView *)_realWebView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if (_isWebViewContent) {
        [(UIWebView *)_realWebView loadHTMLString:string baseURL:baseURL];
    }else{
        [(WKWebView *)_realWebView loadHTMLString:string baseURL:baseURL];
    }
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    if (_isWebViewContent) {
        [(UIWebView *)_realWebView loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
    }else{
        [(WKWebView *)_realWebView loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
    }
}

- (void)reload{
    if (_isWebViewContent) {
        [(UIWebView *)_realWebView reload];
    }else{
        [(WKWebView *)_realWebView reload];
    }
}

- (void)stopLoading
{
    if (_isWebViewContent) {
        [(UIWebView *)_realWebView stopLoading];
    }else{
        [(WKWebView *)_realWebView stopLoading];
    }
}

- (void)goBack{
    if (_isWebViewContent) {
        [(UIWebView *)_realWebView goBack];
    }else{
        [(WKWebView *)_realWebView goBack];
    }
}

- (void)goForward{
    if (_isWebViewContent) {
        [(UIWebView *)_realWebView goForward];
    }else{
        [(WKWebView *)_realWebView goForward];
    }
}

- (BOOL)canGoBack
{
    if (_isWebViewContent) {
        return [(UIWebView *)_realWebView canGoBack];
    }else{
        return [(WKWebView *)_realWebView canGoBack];
    }
}

- (void) clearColor{
    [_realWebView setBackgroundColor:[UIColor clearColor]];
    [_realWebView setOpaque:NO];
}

- (void)removeObserver
{
    if (_isWebViewContent) {
        
    }else{
        WKWebView * webView = (WKWebView *)_realWebView;
        if(webView.observationInfo){
            [webView removeObserver:self forKeyPath:@"estimatedProgress"];
        }
    }
    
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id obj , NSError *))completionHandler
{
    if (_isWebViewContent) {
        NSString *result = [(UIWebView *)self.realWebView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if (completionHandler) {
            completionHandler(result, nil);
        }
    }else{
        return [(WKWebView *)self.realWebView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString
{
    
    if(_isWebViewContent)
    {
        NSString* result = [(UIWebView*)self.realWebView stringByEvaluatingJavaScriptFromString:javaScriptString];
        return result;
    }
    else
    {
        __block NSString* result = nil;
        __block BOOL isExecuted = NO;
        [(WKWebView*)self.realWebView evaluateJavaScript:javaScriptString completionHandler:^(id obj, NSError *error) {
            result = obj;
            isExecuted = YES;
        }];
        
        while (isExecuted == NO) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        result = [NSString stringWithFormat:@"%@",result];
        
        return result;
    }
    
}

#pragma mark - Init

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if (_isWebViewContent) {
        UIWebView *webView = _realWebView;
        webView.scalesPageToFit = scalesPageToFit;
    }else{
    }
    
    _scalesPageToFit = scalesPageToFit;
}

- (BOOL)scalesPageToFit{
    if (_isWebViewContent) {
        return [_realWebView scalesPageToFit];
    }else{
        return _scalesPageToFit;
    }
}


#pragma mark - SuperClass

- (void)setOpaque:(BOOL)opaque{
    [(UIView *)_realWebView setOpaque:opaque];
    [super setOpaque:opaque];
}

#pragma mark - WKWebViewObserVe

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if([keyPath isEqualToString:@"estimatedProgress"]){
        WKWebView * webView = (WKWebView *)_realWebView;
        [self setProgress:webView.estimatedProgress];
    }
}


- (void)startProgress
{
    if (_progress < CJQInitialProgressValue) {
        [self setProgress:CJQInitialProgressValue];
    }
}
- (void)incrementProgress
{
    float progress = self.progress;
    float maxProgress = _interactive ? CJQFinalProgressValue : CJQInteractiveProgressValue;
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
}

- (void)completeProgress
{
    [self setProgress:1.0];
}

- (void)resetProgress {
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
    [self setProgress:0.0];
}

- (void)setProgress:(float)progress
{
    // progress should be incremental only
    if (progress > _progress || progress == 0) {
        _progress = progress;
        if(self.delegate && [self.delegate respondsToSelector:@selector(webViewProgress:)]) {
            [self.delegate webViewProgress:progress];
        }
    }
}
/** 隐藏进度条*/
- (void)hiddenProgressLayer {
    _progressLayer.hidden = YES;
    [self removeObserver];
}




@end
