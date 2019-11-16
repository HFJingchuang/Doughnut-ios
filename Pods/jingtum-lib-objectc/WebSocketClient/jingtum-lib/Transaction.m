//
//  Transaction.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/6/24.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "Transaction.h"
#import "Seed.h"
#import "Serializer.h"

@implementation Transaction

@synthesize remote;
@synthesize src;
@synthesize tx_json;

-(id)init
{
    _memo = [[NSMutableArray alloc] init];
    
    if (self = [super init]) {
        gFlags = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                 [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [NSNumber numberWithInt:2147483648], @"FullyCanonicalSig",
                  nil], @"Universal",
                 [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [NSNumber numberWithInt:65536], @"RequireDestTag",
                  [NSNumber numberWithInt:131072], @"OptionalDestTag",
                  [NSNumber numberWithInt:262144], @"RequireAuth",
                  [NSNumber numberWithInt:524288], @"OptionalAuth",
                  [NSNumber numberWithInt:1048576], @"DisallowSWT",
                  [NSNumber numberWithInt:2097152], @"AllowSWT",
                  nil], @"AccountSet",
                 [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [NSNumber numberWithInt:65536], @"SetAuth",
                  [NSNumber numberWithInt:131072], @"NoSkywell",
                  [NSNumber numberWithInt:131072], @"SetNoSkywell",
                  [NSNumber numberWithInt:262144], @"ClearNoSkywell",
                  [NSNumber numberWithInt:1048576], @"SetFreeze",
                  [NSNumber numberWithInt:2097152], @"ClearFreeze",
                  nil], @"TrustSet",
                 [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [NSNumber numberWithInt:65536], @"Passive",
                  [NSNumber numberWithInt:131072], @"ImmediateOrCancel",
                  [NSNumber numberWithInt:262144], @"FillOrKill",
                  [NSNumber numberWithInt:524288], @"Sell",
                  nil], @"OfferCreate",
                 [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [NSNumber numberWithInt:65536], @"NoSkywellDirect",
                  [NSNumber numberWithInt:131072], @"PartialPayment",
                  [NSNumber numberWithInt:262144], @"LimitQuality",
                  nil], @"Payment",
                 [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [NSNumber numberWithInt:1], @"Authorize",
                  [NSNumber numberWithInt:17], @"Freeze",
                  nil], @"RelationSet",
                 nil];
    }
    
    return self;
}

-(void)setSecret:(NSString *)secret
{
    NSLog(@"we are in setSecret %@", secret);
    _secret = [secret copy];
}

-(void)addMemo:(NSString *)memostr
{
    NSLog(@"we are in addMemo %@", memostr);
    if (memostr.length > 2048) {
        NSLog(@"memo is too long");
        return;
    }
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                         memostr, @"MemoData",
                         nil];
    [_memo addObject:dic];
}

-(void)submit
{
    NSLog(@"we are in submit");
    NSString *TransactionType = [tx_json objectForKey:@"TransactionType"];
    if (TransactionType != nil && [TransactionType isEqualToString:@"Signer"]) {
        NSString *blob = [tx_json objectForKey:@"blob"];
        [remote sendSignTx:blob];
    } else if (remote.isLocal) {
        //
        NSNumber *Sequence = [tx_json objectForKey:@"Sequence"];
        if (Sequence != nil) {
            // 这边做真正的签名动作
            [self signing];
        } else {
            // 获取源账户的 AccountInfo 信息，在里面获取到 Sequence
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:src forKey:@"account"];
            [dic setObject:@"trust" forKey:@"type"];
            
            [remote requestAccountInfo:dic];
        }
    } else {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:_secret forKey:@"secret"];
        [dic setObject:tx_json forKey:@"tx_json"];
        [remote sendUnsignTx:dic];
    }
}

-(void)sign:(id)message
{
    // 本地签名
    NSString *msg = (NSString*)message;
//    NSLog(@"in transaction the msg is %@", msg);
    NSData *jsonData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"fail to parse the message %@", msg);
        return;
    }
    
    NSDictionary *result = [dic objectForKey:@"result"];
    if (result != nil) {
        NSDictionary *account_data = [result objectForKey:@"account_data"];
        if (account_data != nil) {
            NSNumber *Sequence = [account_data objectForKey:@"Sequence"];
            [tx_json setObject:Sequence forKey:@"Sequence"];
            // 这边做真正的签名动作
            [self signing];
        }
    }
}

// 构造类似的报文：
// {tx_json={Account=j47gDd3ethDU4UJMD2rosg9WrSXeh9bLd1, Destination=jK4kdiriyxErTfW8wMMjzP25oT2AKLWGfY, TransactionType=Payment, Amount=1}, tx_blob=12000022800000002400000091614000000000000001684000000000000014732103725CDCE8DF9A3ECA9C311FDB9FF65F68DC86E41E4876ADAD577F75FFFC7E6366744730450221009753F558B6C18DD86F46006EF23EBB7FA25644D158475976CA54D9FF293D82E0022012F2D4B9AA3828CB4FB01119E0ADCC832F085DBDA02ACE78C45D338F9913F37E8114EB969C12D9CFEA15D46C2B0BABD4659E086BB7EC8314C98F6CA34063D287DA5214717AC1DE6209830DB8F9EA7D2265363934616665346262393833303265333033303330333033303331353335373534E1F1, memo=支付0.000001SWT, command=submit}
-(void)signing
{
    NSNumber *fee = [tx_json objectForKey:@"Fee"];
    if (fee != nil) {
        double value = [fee doubleValue]/1000000;
        NSNumber *newfee = [NSNumber numberWithDouble:value];
        [tx_json setObject:newfee forKey:@"Fee"];
    }
    // payment
    id amount = [tx_json objectForKey:@"Amount"];
    if (amount != nil && ![amount isKindOfClass:[NSDictionary class]]) {
        double newvalue = [((NSString*)amount) doubleValue] / 1000000;
        NSNumber *value = [NSNumber numberWithDouble:newvalue];
        [tx_json setObject:value forKey:@"Amount"];
    }
    
    if ([_memo count] > 0) {
        [tx_json setObject:_memo forKey:@"Memos"];
    }
    
    // order
    id takerPays = [tx_json objectForKey:@"TakerPays"];
    if (takerPays != nil && ![takerPays isKindOfClass:[NSDictionary class]]) {
        double newvalue = [((NSString*)takerPays) doubleValue] / 1000000;
        NSNumber *value = [NSNumber numberWithDouble:newvalue];
        [tx_json setObject:value forKey:@"TakerPays"];
    }
    id takerGets = [tx_json objectForKey:@"TakerGets"];
    if (takerGets != nil && ![takerGets isKindOfClass:[NSDictionary class]]) {
        double newvalue = [((NSString*)takerGets) doubleValue] / 1000000;
        NSNumber *value = [NSNumber numberWithDouble:newvalue];
        [tx_json setObject:value forKey:@"TakerGets"];
    }
    
    Seed *seed = [[Seed alloc] init];
    
    Keypairs *keypairs = [seed deriveKeyPair:_secret];
    NSData *pub = [keypairs getPublicKey];
    
    [tx_json setObject:pub forKey:@"SigningPubKey"];
    
    long prefix = 0x53545800;
    Serializer *getHashSerialize = [[Serializer alloc] init];
    [getHashSerialize from_json:tx_json];
    NSData *hash = [getHashSerialize hash:prefix];
    
    NSData *txnSignature = [seed signTx:hash];
    [tx_json setObject:txnSignature forKey:@"TxnSignature"];
    Serializer *getBlobSerialize = [[Serializer alloc] init];
    NSString *blob = [getBlobSerialize from_json:tx_json];
    NSLog(@"the blob is %@", blob);
//  [tx_json setObject:blob forKey:@"blob"];
    
    [remote sendSignTx:blob];
}

-(void)setFlags:(id)flags
{
    if (flags == nil) {
        return;
    }
    
    if ([flags isKindOfClass:[NSNumber class]]) {
        [tx_json setObject:flags forKey:@"Flags"];
        return;
    }
    
    NSString *type = [tx_json objectForKey:@"TransactionType"];
    NSDictionary *transaction_flags = [gFlags objectForKey:type];
    NSMutableArray *flag_set = nil;
    if (transaction_flags != nil) {
        if ([flags isKindOfClass:[NSArray class]]) {
            flag_set = [(NSArray*)flags mutableCopy];
        } else {
            flag_set = [[NSMutableArray alloc] init];
            [flag_set addObject:flags];
        }
    }
    for (NSString *flag in flag_set) {
        if (transaction_flags != nil) {
            NSNumber *number = [transaction_flags objectForKey:flags];
            if (number != nil) {
                NSNumber *prev = [tx_json objectForKey:@"Flags"];
                if (prev != nil) {
                    int prevValue = [prev intValue];
                    int currValue = [number intValue];
                    int totalValue = prevValue + currValue;
                    NSNumber *total = [NSNumber numberWithInt:totalValue];
                    [tx_json setObject:total forKey:@"Flags"];
                } else {
                    [tx_json setObject:number forKey:@"Flags"];
                }
            }
        }
    }
}

@end
