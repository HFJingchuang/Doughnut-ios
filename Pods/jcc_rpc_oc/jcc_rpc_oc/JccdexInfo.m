//
//  JccdexInfo.m
//  jcc_rpc_oc
//
//  Created by xumingyang on 2019/8/21.
//  Copyright © 2019 JCCDex. All rights reserved.
//
#import <stdlib.h>
#import "JccdexInfo.h"
#import "JccdexMacro.h"
#import "JccdexRoute.h"

@interface JccdexInfo() {
    NSURLSession *_sharedSession;
}
@property (strong, nonatomic) NSArray *jccdexInfoNodes;
@end

@implementation JccdexInfo

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static JccdexInfo *inst;
    dispatch_once(&onceToken, ^{
        inst = [[JccdexInfo alloc] init];
    });
    return inst;
};

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _sharedSession = [NSURLSession sharedSession];
    }
    return self;
}

- (void) initInfoNodes:(NSArray *)nodes {
    _jccdexInfoNodes = nodes;
}

- (NSString *) getNode {
    if (_jccdexInfoNodes == nil) {
        return @"";
    }
    NSInteger value = arc4random_uniform((int) [_jccdexInfoNodes count]);
    return _jccdexInfoNodes[value];
}

- (void) requestTicker:(NSString *)base counter:(NSString *)counter onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail{
    NSString *node = [self getNode];
    NSString *pair = [NSString stringWithFormat:@"%@%@", [base uppercaseString],[NSString stringWithFormat:@"-%@" ,[[counter uppercaseString]stringByReplacingOccurrencesOfString:@"CNT" withString:@"CNY"]]];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",node, [NSString stringWithFormat:JC_REQUEST_TICKER_ROUTE,pair]];
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [_sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (onResponse) {
                onResponse(dict);
            }
        } else {
            if (onFail) {
                onFail(error);
            }
        }
    }];
    [dataTask resume];
}

- (void) requestAllTickers:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",node, JC_REQUEST_ALLTICKERS_ROUTE];
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [_sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (onResponse) {
                onResponse(dict);
            }
        } else {
            if (onFail) {
                onFail(error);
            }
        }
    }];
    [dataTask resume];
}

- (void) requestDepth:(NSString *)base counter:(NSString *)counter type:(NSString *)type onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *pair = [NSString stringWithFormat:@"%@%@", [base uppercaseString],[NSString stringWithFormat:@"-%@" ,[[counter uppercaseString]stringByReplacingOccurrencesOfString:@"CNT" withString:@"CNY"]]];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@%@",node, [NSString stringWithFormat:JC_REQUEST_DEPTH_ROUTE,pair],[NSString stringWithFormat:@"/%@",type]];
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [_sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (onResponse) {
                onResponse(dict);
            }
        } else {
            if (onFail) {
                onFail(error);
            }
        }
    }];
    [dataTask resume];
}

- (void) requestKline:(NSString *)base counter:(NSString *)counter type:(NSString *)type onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *pair = [NSString stringWithFormat:@"%@%@", [base uppercaseString],[NSString stringWithFormat:(NSString *)@"-%@" ,[[counter uppercaseString]stringByReplacingOccurrencesOfString:@"CNT" withString:@"CNY"]]];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@%@",node, [NSString stringWithFormat:JC_REQUEST_KLINE_ROUTE,pair],[NSString stringWithFormat:@"/%@",type]];
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [_sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (onResponse) {
                onResponse(dict);
            }
        } else {
            if (onFail) {
                onFail(error);
            }
        }
    }];
    [dataTask resume];
}

- (void) requestHistory:(NSString *)base counter:(NSString *)counter type:(NSString *)type time:(NSString *)time onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *pair = [NSString stringWithFormat:@"%@%@",[base uppercaseString],[NSString stringWithFormat:@"-%@" ,[[counter uppercaseString]stringByReplacingOccurrencesOfString:@"CNT" withString:@"CNY"]]];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@%@",node, [NSString stringWithFormat:JC_REQUEST_INFO_HISTORY_ROUTE,pair],[NSString stringWithFormat:@"/%@",type]];
    if ([type isEqualToString:@"newest"]){
        requestUrl = [NSString stringWithFormat:@"%@?time=%@",requestUrl,time];
    }
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [_sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (onResponse) {
                onResponse(dict);
            }
        } else {
            if (onFail) {
                onFail(error);
            }
        }
    }];
    [dataTask resume];
}

- (void) requestTickerFromCMC:(NSString *)token currency:(NSString *)currency onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *pair = [NSString stringWithFormat: @"/%@%@%@",[token lowercaseString],[NSString stringWithFormat:@"_%@" ,[currency lowercaseString]],@".json"];
    NSString *time = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@?t=%@",node,pair,time];
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [_sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (onResponse) {
                onResponse(dict);
            }
        } else {
            if (onFail) {
                onFail(error);
            }
        }
    }];
    [dataTask resume];
    
}


@end
