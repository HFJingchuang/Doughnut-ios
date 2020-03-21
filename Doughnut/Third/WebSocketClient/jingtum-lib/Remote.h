//
//  Remote.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/14.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketRocket.h"
#import "Transaction.h"

@class Transaction;

extern NSString * const kWebSocketDidOpen;
extern NSString * const kWebSocketDidClose;
extern NSString * const kWebSocketdidReceiveMessage;

@interface Remote : NSObject <SRWebSocketDelegate>
{
    int _index;
    NSTimer * heartBeat;
    NSTimeInterval reConnectTime;
    @public int req_id;
}

@property (nonatomic,strong) SRWebSocket *socket;

@property (nonatomic,copy) NSString *urlString;

@property (nonatomic) BOOL isLocal;

@property (nonatomic, strong) Transaction *tx;

+ (Remote *)instance;

-(void)connectWithURLString:(NSString *)urlString local_sign:(BOOL)isLocal;
-(void)connect;
-(void)disconnect;

-(void)requestServerInfo; // 获得井通底层的服务器信息
-(void)requestLedgerClosed; // 获得最新账本信息，包括区块高度 (ledger_index)与区块hash(ledger_hash)
-(void)requestLedger:(NSDictionary*)paramDic;
-(void)requestTx:(NSDictionary*)paramDic;
-(void)requestAccountInfo:(NSDictionary*)paramDic;
-(void)requestAccountTums:(NSDictionary*)paramDic;
-(void)requestAccountRelations:(NSDictionary*)paramDic;
-(void)requestAccountOffers:(NSDictionary*)paramDic;
-(void)requestAccountTx:(NSDictionary*)paramDic;
-(void)requestOrderBook:(NSDictionary*)paramDic;
-(Transaction*)buildPaymentTx:(NSDictionary*)paramDic;
-(void)sendSignTx:(NSString*)blob;
-(void)sendUnsignTx:(NSDictionary*)paramDic;
-(Transaction*)buildRelationTx:(NSDictionary*)paramDic;
-(Transaction*)buildAccountSetTx:(NSDictionary*)paramDic;
-(Transaction*)buildOfferCreateTx:(NSDictionary*)paramDic;
-(Transaction*)buildOfferCancelTx:(NSDictionary*)paramDic;

-(NSString*)toAmount:(NSDictionary*)amount;

-(BOOL)isValidAddress:(NSString*)address;

@end
