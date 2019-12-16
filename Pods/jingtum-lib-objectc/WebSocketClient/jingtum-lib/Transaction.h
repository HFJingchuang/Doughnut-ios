//
//  Transaction.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/24.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Remote.h"

@class Remote;

@interface Transaction : NSObject
{
    NSMutableDictionary *gFlags;
}

@property (nonatomic, retain) Remote *remote;
@property (nonatomic, copy) NSString* src;
@property (nonatomic, copy) NSString* secret;
@property (nonatomic, copy) NSMutableArray* memo;
@property (nonatomic, strong) NSMutableDictionary *tx_json;

-(void)setSecret:(NSString*)secret;
-(void)addMemo:(NSString*)memo;
-(void)submit;
-(void)sign:(id)message;
-(void)setFlags:(id)flags;

@end
