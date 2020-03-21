//
//  JccdexExchange.m
//  jcc_rpc_oc
//
//  Created by 沐生 on 2018/12/26.
//  Copyright © 2018 JCCDex. All rights reserved.
//

#include <stdlib.h>
#import "JccdexExchange.h"
#import "JccdexMacro.h"
#import "JccdexRoute.h"

@interface JccdexExchange() {
    NSURLSession *_sharedSession;
}
@property (strong, nonatomic) NSArray *jccdexExchangeNodes;
@end

@implementation JccdexExchange

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static JccdexExchange *inst;
    dispatch_once(&onceToken, ^{
        inst = [[JccdexExchange alloc] init];
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

- (void) initExchangeNodes:(NSArray *)nodes {
    _jccdexExchangeNodes = nodes;
}

- (NSString *) getNode {
    if (_jccdexExchangeNodes == nil) {
        return @"";
    }
    NSInteger value = arc4random_uniform((int) [_jccdexExchangeNodes count]);
    return _jccdexExchangeNodes[value];
}

- (void)requestBalance:(NSString *)address onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",node, [NSString stringWithFormat:JC_REQUEST_BALANCE_ROUTE,address]];
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

- (void)createOrder:(NSString *)signature onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", node, JC_CREATE_ORDER_ROUTE];
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString stringWithFormat:@"sign=%@", signature] dataUsingEncoding:NSUTF8StringEncoding];
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

- (void)requestSequence:(NSString *)address onResponse:(void (^)(NSInteger))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",node, [NSString stringWithFormat:JC_REQUEST_SEQUENCE_ROUTE,address]];
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [_sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSString *code = [dict objectForKey:@"code"];
            NSInteger __block sequence;
            if ([code isEqualToString:REQUEST_JC_SUCCESS_CODE]) {
                sequence =[[[dict objectForKey:@"data"] objectForKey:@"sequence"] integerValue];
            } else {
                sequence = JC_INVALID_SEQUENCE;
            }
            if (onResponse) {
                onResponse(sequence);
            }
        } else {
            if (onFail) {
                onFail(error);
            }
        }
    }];
    [dataTask resume];
}

- (void)cancelOrder:(NSString *)signature onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", node, JC_CANCEL_ORDER_ROUTE];
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"DELETE";
    NSDictionary *data = @{@"sign":signature};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
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

- (void)transferToken:(NSString *)signature onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", node, JC_TRNSFER_TOKEN_ROUTE];
    NSURL *url = [NSURL URLWithString: requestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString stringWithFormat:@"sign=%@", signature] dataUsingEncoding:NSUTF8StringEncoding];
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

- (void)requestOrders:(NSString *)address page:(NSInteger)page onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",node, [NSString stringWithFormat:JC_REQUEST_ORDER_ROUTE,address, (int)page]];
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

- (void)requestHistory:(NSString *)url success:(void (^)(NSDictionary *data))success failure:(void (^)(NSError *error))failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *dataTask = [_sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (success) {
                success(dict);
            }
        } else {
            if (failure) {
                failure(error);
            }
        }
    }];
    [dataTask resume];
}

- (void)requestHistoricTransactions:(NSString *)address ledger:(NSInteger)ledger seq:(NSInteger)seq onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@?ledger=%d&seq=%d",node, [NSString stringWithFormat:JC_REQUEST_HISTORY_ROUTE,address],(int) ledger,(int) seq];
    [self requestHistory:requestUrl success:^(NSDictionary *data) {
        if (onResponse) {
            onResponse(data);
        }
    } failure:^(NSError *error) {
        if (onFail) {
            onFail(error);
        }
    }];
}

- (void)requestHistoricTransactions:(NSString *)address onResponse:(void (^)(NSDictionary *))onResponse onFail:(void (^)(NSError *))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",node, [NSString stringWithFormat:JC_REQUEST_HISTORY_ROUTE,address]];
    [self requestHistory:requestUrl success:^(NSDictionary *data) {
        if (onResponse) {
            onResponse(data);
        }
    } failure:^(NSError *error) {
        if (onFail) {
            onFail(error);
        }
    }];
}

@end
