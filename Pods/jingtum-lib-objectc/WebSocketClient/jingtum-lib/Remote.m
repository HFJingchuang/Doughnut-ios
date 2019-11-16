//
//  Remote.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/14.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "Remote.h"
#import <CoreBitcoin/CoreBitcoin.h>
#import "Transaction.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


NSString * const kWebSocketDidOpen           = @"kWebSocketDidOpen";
NSString * const kWebSocketDidClose          = @"kWebSocketDidClose";
NSString * const kWebSocketdidReceiveMessage = @"kWebSocketdidReceiveMessage";

@implementation Remote

@synthesize isLocal;
@synthesize tx;

+(Remote *)instance{
    static Remote *Instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        Instance = [[Remote alloc] init];
    });
    
    return Instance;
}

-(id)init{
    if (self = [super init]) {
        req_id = 1;
    }
    
    return self;
}

#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self
- (void)sendData:(id)data {
    NSLog(@"socketSendData --------------- %@",data);
    
    WeakSelf(ws);
    dispatch_queue_t queue =  dispatch_queue_create("sendata", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
            } else {
                NSLog(@"the state isn`t open ");
            }
        } else {
            NSLog(@"we have no network");
        }
    });
}

#pragma mark - socket delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    //开启心跳，暂时先不做心跳？是否需要发送这个心跳呢？
//    [self initHeartBeat];
    
    if (webSocket == self.socket) {
        NSLog(@"************************** successfully connect socket ********************* ");
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidOpen object:nil];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket fail************************** ");
        _socket = nil;
        //连接失败就重连
//        [self reConnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket break ************************** ");
//        NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",(long)code,reason,wasClean);
//        [self SRWebSocketClose];
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidClose object:nil];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message  {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** receive data from socket************************** ");
//        NSLog(@"message: %@", message);
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketdidReceiveMessage object:message];
        if (tx != nil) {
            [tx sign:message];
        }
    }
}

#pragma mark - **************** public methods
-(void)connectWithURLString:(NSString *)urlString local_sign:(BOOL)isLocal {
    
    //如果是同一个url return
    if (self.socket) {
        return;
    }
    
    if (!urlString) {
        return;
    }
    
    self.isLocal = isLocal;
    
    self.urlString = urlString;
    
    self.socket = [[SRWebSocket alloc] initWithURLRequest:
                   [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    NSLog(@"the websocket address is：%@", self.socket.url.absoluteString);
    
    self.socket.delegate = self;   //SRWebSocketDelegate 协议
    
    [self.socket open];     //开始连接
}

-(void)disconnect
{
    NSLog(@"ready to disconnect the socket");
    
    if (self.socket){
        [self.socket close];
        self.socket = nil;
    }
}

-(void)requestServerInfo
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:@"ledger"];
    [array addObject:@"server"];
    
    NSNumber *num = [NSNumber numberWithInt:req_id++];
    [dic setObject:num forKey:@"id"];
    [dic setObject:@"server_info" forKey:@"command"]; // server_info
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(void)requestLedgerClosed
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:@"ledger"];
    [array addObject:@"server"];
    
    NSNumber *num = [NSNumber numberWithInt:req_id++];
    [dic setObject:num forKey:@"id"];
    [dic setObject:@"ledger_closed" forKey:@"command"]; // ledger_closed
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

// var HASH__RE = /^[A-F0-9]{64}$/;
-(BOOL)isValidHash:(NSString*)ledger_hash
{
    if (ledger_hash == nil || ledger_hash.length <= 0) {
        return false;
    }
    
    NSString *HASH__RE = @"^[A-F0-9]{64}$";
    NSPredicate *matchPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", HASH__RE];
    return [matchPre evaluateWithObject:ledger_hash];
}

-(BOOL)isValidAddress:(NSString*)address
{
    NSData *data = [address dataFromBase58];
    char *bytes = [data bytes];
    if (data == nil || data.length < 5 || bytes[0] != (char)0) {
        return false;
    }
    NSData *checksum = [data subdataWithRange:NSMakeRange(data.length-4, 4)];
    
    NSData *seedBytes = [data subdataWithRange:NSMakeRange(0, data.length-4)];
    NSData *computed = [[[seedBytes SHA256] SHA256] subdataWithRange:NSMakeRange(0, 4)];
    
    if (![checksum isEqualToData:computed]) {
        return false;
    }
    
    return true;
}
// var CURRENCY_RE = /^([a-zA-Z0-9]{3,6}|[A-F0-9]{40})$/;
-(BOOL)isValidCurrency:(NSString*)currency
{
    if (currency == nil || currency.length <= 0) {
        return false;
    }
    
    NSString *CURRENCY_RE = @"^([a-zA-Z0-9]{3,6}|[A-F0-9]{40})$";
    NSPredicate *matchPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CURRENCY_RE];
    return [matchPre evaluateWithObject:currency];
}

-(BOOL)isValidAmount0:(NSDictionary*)dic
{
    if (dic == nil) {
        return  false;
    }
    id currency = [dic objectForKey:@"currency"];
    id issuer = [dic objectForKey:@"issuer"];
    if (currency == nil || ![self isValidCurrency:(NSString*)currency]) {
        return false;
    } else {
        if ([currency isKindOfClass:[NSString class]]) {
            NSString *curr = (NSString*)currency;
            if ([curr isEqualToString:@"SWT"]) {
                if ([issuer isKindOfClass:[NSString class]]) {
                    NSString *newissuer = (NSString*)issuer;
                    if (newissuer != nil && newissuer.length > 0) {
                        return false;
                    }
                }
            }
            if (![curr isEqualToString:@"SWT"] && ![self isValidAddress:(NSString*)issuer]) {
                return false;
            }
        }
    }
    
    return true;
}

-(void)requestLedger:(NSDictionary*)paramDic
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:@"ledger"];
    [array addObject:@"server"];
    
    NSNumber *num = [NSNumber numberWithInt:req_id++];
    [dic setObject:num forKey:@"id"];
    [dic setObject:@"ledger" forKey:@"command"]; // ledger
    
    // 把参数填进来
    NSObject *ledger_index = [paramDic objectForKey:@"ledger_index"];
    if (ledger_index != nil) {
        [dic setObject:ledger_index forKey:@"ledger_index"];
    }
    NSString *ledger_hash = [paramDic objectForKey:@"ledger_hash"]; // 需要验证是否是合法的hash
    if (ledger_hash != nil && [self isValidHash:ledger_hash]) {
        [dic setObject:ledger_hash forKey:@"ledger_hash"];
    }
    // 以下四个都是 bool 型哦
    NSObject *full = [paramDic objectForKey:@"full"];
    if (full != nil) {
        [dic setObject:full forKey:@"full"];
    }
    NSObject *expand = [paramDic objectForKey:@"expand"];
    if (expand != nil) {
        [dic setObject:expand forKey:@"expand"];
    }
    NSObject *transactions = [paramDic objectForKey:@"transactions"];
    if (transactions != nil) {
        [dic setObject:transactions forKey:@"transactions"];
    }
    NSObject *accounts = [paramDic objectForKey:@"accounts"];
    if (accounts != nil) {
        [dic setObject:accounts forKey:@"accounts"];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(void)requestTx:(NSDictionary*)paramDic
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:@"ledger"];
    [array addObject:@"server"];
    
    NSNumber *num = [NSNumber numberWithInt:req_id++];
    [dic setObject:num forKey:@"id"];
    [dic setObject:@"tx" forKey:@"command"]; // tx
    
    // 把参数填进来
    NSString *hash = [paramDic objectForKey:@"hash"];
    if (hash != nil && [self isValidHash:hash]) {
        [dic setObject:hash forKey:@"transaction"];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(void)requestAccount:(NSMutableDictionary*)dic param:(NSDictionary*)paramDic
{
    // 把参数填进来
    NSString *account = [paramDic objectForKey:@"account"];
    if (![self isValidAddress:account]) {
        NSLog(@"invalid address");
        return;
    }
    if (account != nil) {
        [dic setObject:account forKey:@"account"];
    }
    id ledger = [paramDic objectForKey:@"ledger"];
    if (ledger != nil) {
        if ([ledger isKindOfClass:[NSString class]]) {
            [dic setObject:ledger forKey:@"ledger_index"];
        } else if ([ledger isKindOfClass:[NSNumber class]]) {
            [dic setObject:ledger forKey:@"ledger_index"];
        }
    } else {
        [dic setObject:@"validated" forKey:@"ledger_index"];
    }
    NSString *peer = [paramDic objectForKey:@"peer"];
    if (peer != nil && [self isValidAddress:peer]) {
        [dic setObject:peer forKey:@"peer"];
    }
    NSNumber *limit = [paramDic objectForKey:@"limit"];
    if (limit != nil) {
        if (limit < 0) {
            limit = 0;
        }
        //        if (limit > 1000000000) {
        //            limit = 1000000000;
        //        }
        [dic setObject:limit forKey:@"limit"];
    }
    NSString *marker = [paramDic objectForKey:@"marker"];
    if (marker != nil) {
        [dic setObject:marker forKey:@"marker"];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(void)requestAccountInfo:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    if (account != nil && [self isValidAddress:account]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:req_id++];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"account_info" forKey:@"command"]; // account_info
        
        [self requestAccount:dic param:paramDic];
    } else {
        NSLog(@"without the account or the account is invalid");
    }
}

-(void)requestAccountTums:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    if (account != nil && [self isValidAddress:account]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:req_id++];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"account_currencies" forKey:@"command"]; // account_currencies
        
        [self requestAccount:dic param:paramDic];
    } else {
        NSLog(@"without the account or the account is invalid");
    }
}

-(void)requestAccountRelations:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *type = [paramDic objectForKey:@"type"];
    if (type != nil && account != nil && [self isValidAddress:account]) {
        BOOL isValid = true;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:req_id++];
        [dic setObject:num forKey:@"id"];
        
        if ([type isEqualToString:@"trust"]) {
            [dic setObject:@"account_lines" forKey:@"command"]; // account_lines
        } else if ([type isEqualToString:@"authorize"] || [type isEqualToString:@"freeze"]) {
            [dic setObject:@"account_relation" forKey:@"command"]; // account_relation
        } else {
            isValid = false;
        }
        
        if (isValid) {
            [self requestAccount:dic param:paramDic];
        } else {
            NSLog(@"the type is invalid");
        }
    } else {
        // 出错啦
        NSLog(@"without the type or the account is invalid");
    }
}

-(void)requestAccountOffers:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    if (account != nil && [self isValidAddress:account]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:req_id++];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"account_offers" forKey:@"command"]; // account_offers
        
        [self requestAccount:dic param:paramDic];
    } else {
        NSLog(@"without the account or the account is invalid");
    }
}

-(void)requestAccountTx:(NSDictionary*)paramDic
{
    NSString *account = [paramDic objectForKey:@"account"];
    if (account != nil && [self isValidAddress:account]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:req_id++];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"account_tx" forKey:@"command"]; // account_tx
        
        if ([self isValidAddress:account]) {
            [dic setObject:account forKey:@"account"];
            NSNumber *ledger_min = [paramDic objectForKey:@"ledger_min"];
            if (ledger_min != nil) {
                [dic setObject:ledger_min forKey:@"ledger_index_min"];
            } else {
                NSNumber *zero = [NSNumber numberWithInt:0];
                [dic setObject:zero forKey:@"ledger_index_min"];
            }
            NSNumber *ledger_max = [paramDic objectForKey:@"ledger_max"];
            if (ledger_max != nil) {
                [dic setObject:ledger_max forKey:@"ledger_index_max"];
            } else {
                NSNumber *zero = [NSNumber numberWithInt:-1];
                [dic setObject:zero forKey:@"ledger_index_max"];
            }
            NSNumber *limit = [paramDic objectForKey:@"limit"];
            if (limit != nil) {
                [dic setObject:limit forKey:@"limit"];
            }
            NSNumber *offset = [paramDic objectForKey:@"offset"];
            if (offset != nil) {
                [dic setObject:offset forKey:@"offset"];
            }
            NSDictionary *marker = [paramDic objectForKey:@"marker"];
            if (marker != nil) {
//                NSNumber *ledger = [marker objectForKey:@"ledger"];
//                NSNumber *seq = [marker objectForKey:@"seq"];
                [dic setObject:marker forKey:@"marker"];
            }
            // 以下是 bool 类型的哦
            NSObject *forward = [paramDic objectForKey:@"forward"];
            if (forward != nil) {
                [dic setObject:forward forKey:@"forward"];
            }
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"json string: %@", json);
            
            [self sendData:json];
        } else {
            NSLog(@"account parameter is invalid");
        }
    } else {
        NSLog(@"without the account or the account is invalid");
    }
}

//{"id":1,"command":"book_offers","taker_gets":{"currency":"CNY","issuer":"jBciDE8Q3uJjf111VeiUNM775AMKHEbBLS"},"taker_pays":{"currency":"SWT","issuer":""},"taker":"jjjjjjjjjjjjjjjjjjjjBZbvri"}
-(void)requestOrderBook:(NSDictionary*)paramDic
{
    NSDictionary *gets = [paramDic objectForKey:@"gets"];
    NSDictionary *pays = [paramDic objectForKey:@"pays"];
    NSObject *taker_gets = [paramDic objectForKey:@"taker_gets"];
    NSObject *taker_pays = [paramDic objectForKey:@"taker_pays"];
    if ((gets != nil && pays != nil) || (taker_gets != nil && taker_pays != nil)) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        [array addObject:@"ledger"];
        [array addObject:@"server"];
        
        NSNumber *num = [NSNumber numberWithInt:req_id++];
        [dic setObject:num forKey:@"id"];
        [dic setObject:@"book_offers" forKey:@"command"]; // book_offers
        
        if (taker_gets != nil) {
            if ([self isValidAmount0:taker_gets]) {
                [dic setObject:taker_gets forKey:@"taker_gets"];
            }
        } else {
            if ([self isValidAmount0:gets]) {
                [dic setObject:gets forKey:@"taker_gets"];
            }
        }
        
        if (taker_pays != nil) {
            if ([self isValidAmount0:taker_pays]) {
                [dic setObject:taker_pays forKey:@"taker_pays"];
            }
        } else {
            if ([self isValidAmount0:pays]) {
                [dic setObject:pays forKey:@"taker_pays"];
            }
        }
        
        NSObject *taker = [paramDic objectForKey:@"taker"];
        if (taker != nil) {
            [dic setObject:taker forKey:@"taker"];
        } else {
            // utils.ACCOUNT_ONE
            [dic setObject:@"jjjjjjjjjjjjjjjjjjjjBZbvri" forKey:@"taker"];
        }
        NSObject *limit = [paramDic objectForKey:@"limit"];
        if (limit != nil) {
            [dic setObject:limit forKey:@"limit"];
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"json string: %@", json);
        
        [self sendData:json];
    } else {
        NSLog(@"invalid taker gets amount");
    }
}

-(Transaction*)buildPaymentTx:(NSDictionary *)paramDic
{
    NSString *source = [paramDic objectForKey:@"source"];
    NSString *from = [paramDic objectForKey:@"from"];
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *destination = [paramDic objectForKey:@"destination"];
    NSString *to = [paramDic objectForKey:@"to"];
    NSDictionary *amount = [paramDic objectForKey:@"amount"];
    NSString *fee = [paramDic objectForKey:@"fee"];
    NSString *secret = [paramDic objectForKey:@"secret"];
    NSString *memo = [paramDic objectForKey:@"memo"];
    
    NSString *src = nil;
    NSString *dst = nil;
    if (source != nil) {
        src = source;
    } else if (from != nil) {
        src = from;
    } else if (account != nil) {
        src = account;
    }
    if (destination != nil) {
        dst = destination;
    } else if (to != nil) {
        dst = to;
    }
    
    if (![self isValidAddress:src]) {
        NSLog(@"invalid source address");
        return nil;
    }
    if (![self isValidAddress:dst]) {
        NSLog(@"invalid destination address");
        return nil;
    }
    if (![self isValidAddress:account]) { 
        NSLog(@"invalid amount");
        return nil;
    }
    
    tx = [[Transaction alloc] init];
    tx.remote = self;
    tx.src = src;
    
    NSMutableDictionary *tx_json = [[NSMutableDictionary alloc] init];
    
    [tx_json setObject:@"Payment" forKey:@"TransactionType"];
    [tx_json setObject:src forKey:@"Account"];
    [tx_json setObject:[self toAmount:amount] forKey:@"Amount"];
    [tx_json setObject:to forKey:@"Destination"];
    NSNumber *flags = [NSNumber numberWithInt:0];
    [tx_json setObject:flags forKey:@"Flags"];
    [tx_json setObject:fee forKey:@"Fee"];
    
    tx.tx_json = tx_json;
    
    return tx;
}

-(void)sendSignTx:(NSString*)blob
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    NSNumber *num = [NSNumber numberWithInt:req_id++];
    [dic setObject:num forKey:@"id"];
    [dic setObject:blob forKey:@"tx_blob"];
    [dic setObject:@"submit" forKey:@"command"]; // submit
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(void)sendUnsignTx:(NSDictionary*)paramDic
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:paramDic];
    
    NSNumber *num = [NSNumber numberWithInt:req_id++];
    [dic setObject:num forKey:@"id"];
    [dic setObject:@"submit" forKey:@"command"]; // submit
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json string: %@", json);
    
    [self sendData:json];
}

-(id)toAmount:(NSDictionary*)amount
{
    id ret = nil;
    
    NSString *currency = [amount objectForKey:@"currency"];
    NSString *valuestr = [amount objectForKey:@"value"];
    
    long value = (long)([valuestr doubleValue] + 0.5);
    if (value > 100000000000) {
        NSLog(@"invalid amount: amount's maximum value is 100000000000");
    }
    
    if ([currency isEqualToString:@"SWT"]) {
        long mul = 1000000;
        long value2 = (long)value * mul;
        ret = [NSString stringWithFormat:@"%ld", value2];
    } else {
        ret = amount;
    }
    
    return ret;
}

-(Transaction*)__buildRelationSet:(NSDictionary*)paramDic tx:(Transaction*)tx
{
    NSString *source = [paramDic objectForKey:@"source"];
    NSString *from = [paramDic objectForKey:@"from"];
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *src = nil;
    if (source != nil) {
        src = source;
    } else if (from != nil) {
        src = from;
    } else if (account != nil) {
        src = account;
    }
    tx.src = src;
    
    if (![self isValidAddress:src]) {
        NSLog(@"invalid source address");
        return nil;
    }
    
    NSString *des = [paramDic objectForKey:@"target"];
    if (![self isValidAddress:des]) {
        NSLog(@"invalid target address");
        return nil;
    }
    NSDictionary *limit = [paramDic objectForKey:@"limit"];
    if (![self isValidAmount0:limit]) {
        NSLog(@"invalid amount");
        return nil;
    }
    
    NSString *type = [paramDic objectForKey:@"type"];
    if ([type isEqualToString:@"unfreeze"]) {
        [tx.tx_json setObject:@"RelationDel" forKey:@"TransactionType"];
    } else {
        [tx.tx_json setObject:@"RelationSet" forKey:@"TransactionType"];
    }
    
    [tx.tx_json setObject:src forKey:@"Account"];
    [tx.tx_json setObject:des forKey:@"Target"];
    
    if ([type isEqualToString:@"authorize"]) {
        NSNumber *number = [NSNumber numberWithInt:1];
        [tx.tx_json setObject:number forKey:@"RelationType"];
    } else {
        NSNumber *number = [NSNumber numberWithInt:3];
        [tx.tx_json setObject:number forKey:@"RelationType"];
    }
    if (limit != nil) {
        [tx.tx_json setObject:limit forKey:@"LimitAmount"];
    }
    
    return tx;
}

-(Transaction*)__buildTrustSet:(NSDictionary*)paramDic tx:(Transaction*)tx
{
    NSString *source = [paramDic objectForKey:@"source"];
    NSString *from = [paramDic objectForKey:@"from"];
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *src = nil;
    if (source != nil) {
        src = source;
    } else if (from != nil) {
        src = from;
    } else if (account != nil) {
        src = account;
    }
    tx.src = src;
    
    if (![self isValidAddress:src]) {
        NSLog(@"invalid source address");
        return nil;
    }
    
    NSDictionary *limit = [paramDic objectForKey:@"limit"];
    if (![self isValidAmount0:limit]) {
        NSLog(@"invalid amount");
        return nil;
    }
    [tx.tx_json setObject:@"TrustSet" forKey:@"TransactionType"];
    [tx.tx_json setObject:src forKey:@"Account"];
    if (limit != nil) {
        [tx.tx_json setObject:limit forKey:@"LimitAmount"];
    }
    
    NSString *quality_out = [paramDic objectForKey:@"quality_out"];
    NSString *quality_in = [paramDic objectForKey:@"quality_in"];
    
    if (quality_out != nil) {
        [tx.tx_json setObject:quality_out forKey:@"quality_out"];
    }
    if (quality_in != nil) {
        [tx.tx_json setObject:quality_in forKey:@"quality_in"];
    }
    
    return tx;
}

-(Transaction*)buildRelationTx:(NSDictionary*)paramDic
{
    tx = [[Transaction alloc] init];
    tx.remote = self;
    
    NSMutableDictionary *tx_json = [[NSMutableDictionary alloc] init];
    NSNumber *flags = [NSNumber numberWithInt:0];
    NSNumber *fee = [NSNumber numberWithFloat:10000];
    [tx_json setObject:flags forKey:@"Flags"];
    [tx_json setObject:fee forKey:@"Fee"];
    tx.tx_json = tx_json;
    
    NSString *type = [paramDic objectForKey:@"type"];
    if ([type isEqualToString:@"trust"]) {
        return [self __buildTrustSet:paramDic tx:tx];
    } else if ([type isEqualToString:@"authorize"] ||
               [type isEqualToString:@"freeze"] ||
               [type isEqualToString:@"unfreeze"]) {
        return [self __buildRelationSet:paramDic tx:tx];
    }
    
    return nil;
}

-(Transaction*)__buildAccountSet:(NSDictionary*)paramDic tx:(Transaction*)tx
{
    NSString *source = [paramDic objectForKey:@"source"];
    NSString *from = [paramDic objectForKey:@"from"];
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *src = nil;
    if (source != nil) {
        src = source;
    } else if (from != nil) {
        src = from;
    } else if (account != nil) {
        src = account;
    }
    tx.src = src;
    
    if (![self isValidAddress:src]) {
        NSLog(@"invalid source address");
        return nil;
    }
    
    [tx.tx_json setObject:src forKey:@"Account"];
    [tx.tx_json setObject:@"AccountSet" forKey:@"TransactionType"];
    
    
    return tx;
}

-(Transaction*)__buildDelegateKeySet:(NSDictionary*)paramDic tx:(Transaction*)tx
{
    NSString *source = [paramDic objectForKey:@"source"];
    NSString *from = [paramDic objectForKey:@"from"];
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *src = nil;
    if (source != nil) {
        src = source;
    } else if (from != nil) {
        src = from;
    } else if (account != nil) {
        src = account;
    }
    tx.src = src;
    
    if (![self isValidAddress:src]) {
        NSLog(@"invalid source address");
        return nil;
    }
    NSString *delegate_key = [paramDic objectForKey:@"delegate_key"];
    if (![self isValidAddress:delegate_key]) {
        NSLog(@"invalid regular key address");
        return nil;
    }
    
    [tx.tx_json setObject:@"SetRegularKey" forKey:@"TransactionType"];
    [tx.tx_json setObject:src forKey:@"Account"];
    [tx.tx_json setObject:delegate_key forKey:@"RegularKey"];
    
    return tx;
}

-(Transaction*)__buildSignerSet:(NSDictionary*)paramDic tx:(Transaction*)tx
{
    return nil;
}

-(Transaction*)buildAccountSetTx:(NSDictionary *)paramDic
{
    tx = [[Transaction alloc] init];
    tx.remote = self;
    
    NSMutableDictionary *tx_json = [[NSMutableDictionary alloc] init];
    NSNumber *flags = [NSNumber numberWithInt:0];
    NSNumber *fee = [NSNumber numberWithFloat:10000];
    [tx_json setObject:flags forKey:@"Flags"];
    [tx_json setObject:fee forKey:@"Fee"];
    
    tx.tx_json = tx_json;
    
    NSString *type = [paramDic objectForKey:@"type"];
    if ([type isEqualToString:@"property"]) {
        return [self __buildAccountSet:paramDic tx:tx];
    } else if ([type isEqualToString:@"delegate"]) {
        return [self __buildDelegateKeySet:paramDic tx:tx];
    } else if ([type isEqualToString:@"signer"]) {
        return [self __buildSignerSet:paramDic tx:tx];
    }
    
    return nil;
}

-(Transaction*)buildOfferCreateTx:(NSDictionary *)paramDic
{
    tx = [[Transaction alloc] init];
    tx.remote = self;
    NSMutableDictionary *tx_json = [[NSMutableDictionary alloc] init];
    
    tx.tx_json = tx_json;
    
    NSNumber *flags = [NSNumber numberWithInt:0];
    NSNumber *fee = [NSNumber numberWithFloat:10000];
    [tx_json setObject:flags forKey:@"Flags"];
    [tx_json setObject:fee forKey:@"Fee"];
    
    id offer_type = [paramDic objectForKey:@"type"];
    
    NSString *source = [paramDic objectForKey:@"source"];
    NSString *from = [paramDic objectForKey:@"from"];
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *src = nil;
    if (source != nil) {
        src = source;
    } else if (from != nil) {
        src = from;
    } else if (account != nil) {
        src = account;
    }
    tx.src = src;
    NSDictionary *taker_gets = [paramDic objectForKey:@"taker_gets"];
    if (taker_gets == nil) {
        taker_gets = [paramDic objectForKey:@"pays"];
    }
    NSDictionary *taker_pays = [paramDic objectForKey:@"taker_pays"];
    if (taker_pays == nil) {
        taker_pays = [paramDic objectForKey:@"gets"];
    }
    
    if (![self isValidAddress:src]) {
        NSLog(@"invalid source address");
        return nil;
    }
    
    [tx_json setObject:@"OfferCreate" forKey:@"TransactionType"];
    
    if ([offer_type isEqualToString:@"Sell"]) {
        [tx setFlags:offer_type];
    }
    [tx_json setObject:src forKey:@"Account"];
    [tx_json setObject:[self toAmount:taker_pays] forKey:@"TakerPays"];
    [tx_json setObject:[self toAmount:taker_gets] forKey:@"TakerGets"];
    
    return tx;
}

-(Transaction*)buildOfferCancelTx:(NSDictionary*)paramDic
{
    tx = [[Transaction alloc] init];
    tx.remote = self;
    NSMutableDictionary *tx_json = [[NSMutableDictionary alloc] init];
    
    tx.tx_json = tx_json;
    
    NSNumber *flags = [NSNumber numberWithInt:0];
    NSNumber *fee = [NSNumber numberWithFloat:10000];
    [tx_json setObject:flags forKey:@"Flags"];
    [tx_json setObject:fee forKey:@"Fee"];
    
    NSString *source = [paramDic objectForKey:@"source"];
    NSString *from = [paramDic objectForKey:@"from"];
    NSString *account = [paramDic objectForKey:@"account"];
    NSString *src = nil;
    if (source != nil) {
        src = source;
    } else if (from != nil) {
        src = from;
    } else if (account != nil) {
        src = account;
    }
    tx.src = src;
    if (![self isValidAddress:src]) {
        NSLog(@"invalid source address");
        return nil;
    }
    NSNumber *sequence = [paramDic objectForKey:@"sequence"];
    
    [tx_json setObject:@"OfferCancel" forKey:@"TransactionType"];
    [tx_json setObject:src forKey:@"Account"];
    [tx_json setObject:sequence forKey:@"OfferSequence"];
    
    return tx;
}

@end
