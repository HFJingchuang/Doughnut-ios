//
//  JingtumManager.m
//  jcc_oc_base_lib
//
//  Created by 沐生 on 2019/1/2.
//  Copyright © 2019 JCCDex. All rights reserved.
//

#import "JTWalletManager.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"
#import "JingtumWallet.h"
#import "JccChains.h"

@interface JTWalletManager()<WKNavigationDelegate,WKUIDelegate>
@property WebViewJavascriptBridge *bridge;
@property (nonatomic, strong) WKWebView *webView;
@end

/**
 manage jingtum & jingtum alliance chains.
 */
@implementation JTWalletManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static JTWalletManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[JTWalletManager alloc] init];
        [manager initJingtumWebview];
    });
    return manager;
}

- (void)createWallet:(NSString *)chain completion:(void (^)(NSError *, JingtumWallet *))completion {
    __weak typeof(self) weakSelf = self;
    [_bridge callHandler:@"createJingtumWallet" data:chain responseCallback:^(id responseData) {
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            JingtumWallet *wallet = [JingtumWallet mj_objectWithKeyValues:responseData];
            if (completion) {
                completion(nil, wallet);
            }
        } else {
            if (completion) {
                completion([weakSelf errorDomain:@"from jingtum.js" reason:@"create wallet unsuccessfully"], nil);
            }
        }
    }];
}

- (void)importSecret:(NSString *)secret chain:(NSString *)chain completion:(void (^)(NSError *, JingtumWallet *))completion {
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *parms = [[NSMutableDictionary alloc] initWithCapacity:0];
    [parms setObject:secret forKey:@"secret"];
    [parms setObject:chain forKey:@"chain"];
    NSString *json = [weakSelf dataTojsonString:parms];
    [_bridge callHandler:@"importJingtumSecret" data:json responseCallback:^(id responseData) {
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            JingtumWallet *wallet = [JingtumWallet mj_objectWithKeyValues:responseData];
            if (completion) {
                completion(nil, wallet);
            }
        } else {
            if (completion) {
                completion([weakSelf errorDomain:@"from jingtum.js" reason:@"the secret is invalid"], nil);
            }
        }
    }];
}

- (void)isValidAddress:(NSString *)address chain:(NSString *)chain completion:(void (^)(BOOL))completion {
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *parms = [[NSMutableDictionary alloc] initWithCapacity:0];
    [parms setObject:address forKey:@"address"];
    [parms setObject:chain forKey:@"chain"];
    NSString *json = [weakSelf dataTojsonString:parms];
    [_bridge callHandler:@"isJingtumAddress" data:json responseCallback:^(id responseData) {
        if(completion) {
            completion([responseData boolValue]);
        }
    }];
}

- (void)isValidSecret:(NSString *)secret chain:(NSString *)chain completion:(void (^)(BOOL))completion {
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *parms = [[NSMutableDictionary alloc] initWithCapacity:0];
    [parms setObject:secret forKey:@"secret"];
    [parms setObject:chain forKey:@"chain"];
    NSString *json = [weakSelf dataTojsonString:parms];
    [_bridge callHandler:@"isJingtumSecret" data:json responseCallback:^(id responseData) {
        if(completion) {
            completion([responseData boolValue]);
        }
    }];
}

- (void)sign:(NSDictionary *)transaction secret:(NSString *)secret chain:(NSString *)chain completion:(void (^)(NSError *, NSString *))completion {
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *parms = [[NSMutableDictionary alloc] initWithCapacity:0];
    [parms setObject:transaction forKey:@"transaction"];
    [parms setObject:secret forKey:@"secret"];
    [parms setObject:chain forKey:@"chain"];
    NSString *json = [weakSelf dataTojsonString:parms];
    [_bridge callHandler:@"jingtumSign" data:json responseCallback:^(id responseData) {
        if ([responseData isKindOfClass:[NSString class]]) {
            if (completion) {
                completion(nil, (NSString *)responseData);
            }
        } else {
            if (completion) {
                completion([weakSelf errorDomain:@"from jingtum.js" reason:@"locally sign unsuccessfully"], nil);
            }
        }
    }];
}

#pragma mark - WebView
- (WKWebView *)pureWebView {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preferences;
    return [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
}

- (void)initJingtumWebview {
    if (_bridge) {
        return;
    }
    self.webView = [self pureWebView];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    [self loadHtml:self.webView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.webView];
}

- (void)loadHtml: (WKWebView*)webView  {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *htmlPath = [bundle pathForResource:@"jingtum" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (NSString *)dataTojsonString:(id)object {
    
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (NSError *)errorDomain:(NSString *)domain reason:(NSString *)reason {
    NSError *error = [NSError errorWithDomain:domain code:-1 userInfo:@{NSLocalizedDescriptionKey:reason}];
    return error;
}

@end
