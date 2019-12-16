//
//  JccdexConfig.m
//  jcc_rpc_oc
//
//  Created by xumingyang on 2019/8/23.
//  Copyright © 2019 JCCDex. All rights reserved.
//

#import "JccdexConfig.h"
#import <stdlib.h>
#import "JccdexMacro.h"
#import "JccdexRoute.h"

@interface JccdexConfig(){
    NSURLSession *_sharedSession;
}
@property (strong, nonatomic) NSArray *jccdexConfigNodes;
@end

@implementation JccdexConfig

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static JccdexConfig *inst;
    dispatch_once(&onceToken, ^{
        inst = [[JccdexConfig alloc] init];
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

- (void) initConfigNodes:(NSArray *)nodes {
    _jccdexConfigNodes = nodes;
}

- (NSString *) getNode {
    if (_jccdexConfigNodes == nil) {
        return @"";
    }
    NSInteger value = arc4random_uniform((int) [_jccdexConfigNodes count]);
    return _jccdexConfigNodes[value];
}

-(void) requestConfig:(void (^)(NSDictionary *response))onResponse onFail:(void(^)(NSError *error))onFail {
    NSString *node = [self getNode];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",node, JC_REQUEST_CONFIG_ROUTE];
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
