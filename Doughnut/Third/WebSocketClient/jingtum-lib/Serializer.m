//
//  Serializer.m
//  WebSocketClient
//
//  Created by tongmuxu on 2018/8/13.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import "Serializer.h"
#import "Keypairs.h"
#import "BTCData.h"
#import "TumAmount.h"

@implementation Serializer

#define CURRENCY_NAME_LEN 3
#define CURRENCY_NAME_LEN2 6

-(id)init
{
    if (self = [super init]) {
        TYPES_MAP = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                     @"Int16", @"1",
                     @"Int32", @"2",
                     @"Int64", @"3",
                     @"Hash128", @"4",
                     @"Hash256", @"5",
                     @"Amount", @"6",
                     @"VL", @"7",
                     @"Account", @"8",
                     @"Object", @"14",
                     @"Array", @"15",
                     @"Int8", @"16",
                     @"Hash160", @"17",
                     @"PathSet", @"18",
                     @"Vector256", @"19",
                     nil];
        NSNumber *REQUIRED = [NSNumber numberWithInt:0];
        NSNumber *OPTIONAL = [NSNumber numberWithInt:1];
        NSNumber *DEFAULT  = [NSNumber numberWithInt:2];
        base = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                REQUIRED, @"TransactionType",
                OPTIONAL, @"Flags",
                OPTIONAL, @"SourceTag",
                OPTIONAL, @"LastLedgerSequence",
                REQUIRED, @"Account",
                OPTIONAL, @"Sequence",
                REQUIRED, @"Fee",
                OPTIONAL, @"OperationLimit",
                OPTIONAL, @"SigningPubKey",
                OPTIONAL, @"TxnSignature",
                nil];
        
        TRANSACTION_TYPES = [[NSMutableDictionary alloc] init];
        TRANSACTION_TYPES_INDEX = [[NSMutableDictionary alloc] init];
        
        [TRANSACTION_TYPES_INDEX setObject:@"3" forKey:@"AccountSet"];
        NSMutableDictionary *AccountSet = [[NSMutableDictionary alloc] initWithDictionary:base];
        [AccountSet setObject:OPTIONAL forKey:@"EmailHash"];
        [AccountSet setObject:OPTIONAL forKey:@"WalletLocator"];
        [AccountSet setObject:OPTIONAL forKey:@"WalletSize"];
        [AccountSet setObject:OPTIONAL forKey:@"MessageKey"];
        [AccountSet setObject:OPTIONAL forKey:@"Domain"];
        [AccountSet setObject:OPTIONAL forKey:@"TransferRate"];
        
        [TRANSACTION_TYPES setObject:AccountSet forKey:@"AccountSet"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"20" forKey:@"TrustSet"];
        NSMutableDictionary *TrustSet = [[NSMutableDictionary alloc] initWithDictionary:base];
        [TrustSet setObject:OPTIONAL forKey:@"LimitAmount"];
        [TrustSet setObject:OPTIONAL forKey:@"QualityIn"];
        [TrustSet setObject:OPTIONAL forKey:@"QualityOut"];
        
        [TRANSACTION_TYPES setObject:TrustSet forKey:@"TrustSet"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"21" forKey:@"RelationSet"];
        NSMutableDictionary *RelationSet = [[NSMutableDictionary alloc] initWithDictionary:base];
        [RelationSet setObject:REQUIRED forKey:@"Target"];
        [RelationSet setObject:REQUIRED forKey:@"RelationType"];
        [RelationSet setObject:OPTIONAL forKey:@"LimitAmount"];
        
        [TRANSACTION_TYPES setObject:RelationSet forKey:@"RelationSet"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"22" forKey:@"RelationDel"];
        NSMutableDictionary *RelationDel = [[NSMutableDictionary alloc] initWithDictionary:base];
        [RelationDel setObject:REQUIRED forKey:@"Target"];
        [RelationDel setObject:REQUIRED forKey:@"RelationType"];
        [RelationDel setObject:OPTIONAL forKey:@"LimitAmount"];
        
        [TRANSACTION_TYPES setObject:RelationDel forKey:@"RelationDel"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"7" forKey:@"OfferCreate"];
        NSMutableDictionary *OfferCreate = [[NSMutableDictionary alloc] initWithDictionary:base];
        [OfferCreate setObject:REQUIRED forKey:@"TakerPays"];
        [OfferCreate setObject:REQUIRED forKey:@"TakerGets"];
        [OfferCreate setObject:OPTIONAL forKey:@"Expiration"];
        
        [TRANSACTION_TYPES setObject:OfferCreate forKey:@"OfferCreate"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"8" forKey:@"OfferCancel"];
        NSMutableDictionary *OfferCancel = [[NSMutableDictionary alloc] initWithDictionary:base];
        [OfferCancel setObject:REQUIRED forKey:@"OfferSequence"];
        
        [TRANSACTION_TYPES setObject:OfferCancel forKey:@"OfferCancel"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"5" forKey:@"SetRegularKey"];
        NSMutableDictionary *SetRegularKey = [[NSMutableDictionary alloc] initWithDictionary:base];
        [SetRegularKey setObject:REQUIRED forKey:@"RegularKey"];
        
        [TRANSACTION_TYPES setObject:SetRegularKey forKey:@"SetRegularKey"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"0" forKey:@"Payment"];
        NSMutableDictionary *Payment = [[NSMutableDictionary alloc] initWithDictionary:base];
        [Payment setObject:REQUIRED forKey:@"Destination"];
        [Payment setObject:REQUIRED forKey:@"Amount"];
        [Payment setObject:OPTIONAL forKey:@"SendMax"];
        [Payment setObject:DEFAULT forKey:@"Paths"];
        [Payment setObject:OPTIONAL forKey:@"InvoiceID"];
        [Payment setObject:OPTIONAL forKey:@"DestinationTag"];
        
        [TRANSACTION_TYPES setObject:Payment forKey:@"Payment"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"9" forKey:@"Contract"];
        NSMutableDictionary *Contract = [[NSMutableDictionary alloc] initWithDictionary:base];
        [Contract setObject:REQUIRED forKey:@"Expiration"];
        [Contract setObject:REQUIRED forKey:@"BondAmount"];
        [Contract setObject:REQUIRED forKey:@"StampEscrow"];
        [Contract setObject:REQUIRED forKey:@"JingtumEscrow"];
        [Contract setObject:OPTIONAL forKey:@"CreateCode"];
        [Contract setObject:OPTIONAL forKey:@"FundCode"];
        [Contract setObject:OPTIONAL forKey:@"RemoveCode"];
        [Contract setObject:OPTIONAL forKey:@"ExpireCode"];
        
        [TRANSACTION_TYPES setObject:Contract forKey:@"Contract"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"10" forKey:@"RemoveContract"];
        NSMutableDictionary *RemoveContract = [[NSMutableDictionary alloc] initWithDictionary:base];
        [RemoveContract setObject:REQUIRED forKey:@"Target"];
        
        [TRANSACTION_TYPES setObject:RemoveContract forKey:@"RemoveContract"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"100" forKey:@"EnableFeature"];
        NSMutableDictionary *EnableFeature = [[NSMutableDictionary alloc] initWithDictionary:base];
        [EnableFeature setObject:REQUIRED forKey:@"Feature"];
        
        [TRANSACTION_TYPES setObject:EnableFeature forKey:@"EnableFeature"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"101" forKey:@"SetFee"];
        NSMutableDictionary *SetFee = [[NSMutableDictionary alloc] initWithDictionary:base];
        [SetFee setObject:REQUIRED forKey:@"Features"];
        [SetFee setObject:REQUIRED forKey:@"BaseFee"];
        [SetFee setObject:REQUIRED forKey:@"ReferenceFeeUnits"];
        [SetFee setObject:REQUIRED forKey:@"ReserveBase"];
        [SetFee setObject:REQUIRED forKey:@"ReserveIncrement"];
        
        [TRANSACTION_TYPES setObject:SetFee forKey:@"SetFee"];
        
        [TRANSACTION_TYPES_INDEX setObject:@"30" forKey:@"ConfigContract"];
        NSMutableDictionary *ConfigContract = [[NSMutableDictionary alloc] initWithDictionary:base];
        [ConfigContract setObject:REQUIRED forKey:@"Method"];
        [ConfigContract setObject:OPTIONAL forKey:@"Payload"];
        [ConfigContract setObject:OPTIONAL forKey:@"Destination"];
        [ConfigContract setObject:OPTIONAL forKey:@"Amount"];
        [ConfigContract setObject:OPTIONAL forKey:@"Contracttype"];
        [ConfigContract setObject:OPTIONAL forKey:@"ContractMethod"];
        [ConfigContract setObject:OPTIONAL forKey:@"Args"];
        
        [TRANSACTION_TYPES setObject:ConfigContract forKey:@"ConfigContract"];
        
        INVERSE_FIELDS_MAP = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              @[@"1", @"1"], @"LedgerEntryType",
                              @[@"1", @"2"], @"TransactionType",
                              @[@"2", @"2"], @"Flags",
                              @[@"2", @"3"], @"SourceTag",
                              @[@"2", @"4"], @"Sequence",
                              @[@"2", @"5"], @"PreviousTxnLgrSeq",
                              @[@"2", @"6"], @"LedgerSequence",
                              @[@"2", @"7"], @"CloseTime",
                              @[@"2", @"8"], @"ParentCloseTime",
                              @[@"2", @"9"], @"SigningTime",
                              @[@"2", @"10"], @"Expiration",
                              @[@"2", @"11"], @"TransferRate",
                              @[@"2", @"12"], @"WalletSize",
                              @[@"2", @"13"], @"OwnerCount",
                              @[@"2", @"14"], @"DestinationTag",
                              @[@"2", @"16"], @"HighQualityIn",
                              @[@"2", @"17"], @"HighQualityOut",
                              @[@"2", @"18"], @"LowQualityIn",
                              @[@"2", @"19"], @"LowQualityOut",
                              @[@"2", @"20"], @"QualityIn",
                              @[@"2", @"21"], @"QualityOut",
                              @[@"2", @"22"], @"StampEscrow",
                              @[@"2", @"23"], @"BondAmount",
                              @[@"2", @"24"], @"LoadFee",
                              @[@"2", @"25"], @"OfferSequence",
                              @[@"2", @"26"], @"FirstLedgerSequence",
                              @[@"2", @"27"], @"LastLedgerSequence",
                              @[@"2", @"28"], @"TransactionIndex",
                              @[@"2", @"29"], @"OperationLimit",
                              @[@"2", @"30"], @"ReferenceFeeUnits",
                              @[@"2", @"31"], @"ReserveBase",
                              @[@"2", @"32"], @"ReserveIncrement",
                              @[@"2", @"33"], @"SetFlag",
                              @[@"2", @"34"], @"ClearFlag",
                              @[@"2", @"35"], @"RelationType",
                              @[@"2", @"36"], @"Method",
                              @[@"2", @"39"], @"Contracttype",
                              @[@"3", @"1"], @"IndexNext",
                              @[@"3", @"2"], @"IndexPrevious",
                              @[@"3", @"3"], @"BookNode",
                              @[@"3", @"4"], @"OwnerNode",
                              @[@"3", @"5"], @"BaseFee",
                              @[@"3", @"6"], @"ExchangeRate",
                              @[@"3", @"7"], @"LowNode",
                              @[@"3", @"8"], @"HighNode",
                              @[@"4", @"1"], @"EmailHash",
                              @[@"5", @"1"], @"LedgerHash",
                              @[@"5", @"2"], @"ParentHash",
                              @[@"5", @"3"], @"TransactionHash",
                              @[@"5", @"4"], @"AccountHash",
                              @[@"5", @"5"], @"PreviousTxnID",
                              @[@"5", @"6"], @"LedgerIndex",
                              @[@"5", @"7"], @"WalletLocator",
                              @[@"5", @"8"], @"RootIndex",
                              @[@"5", @"9"], @"AccountTxnID",
                              @[@"5", @"16"], @"BookDirectory",
                              @[@"5", @"17"], @"InvoiceID",
                              @[@"5", @"18"], @"Nickname",
                              @[@"5", @"19"], @"Amendment",
                              @[@"5", @"20"], @"TicketID",
                              @[@"6", @"1"], @"Amount",
                              @[@"6", @"2"], @"Balance",
                              @[@"6", @"3"], @"LimitAmount",
                              @[@"6", @"4"], @"TakerPays",
                              @[@"6", @"5"], @"TakerGets",
                              @[@"6", @"6"], @"LowLimit",
                              @[@"6", @"7"], @"HighLimit",
                              @[@"6", @"8"], @"Fee",
                              @[@"6", @"9"], @"SendMax",
                              @[@"6", @"16"], @"MinimumOffer",
                              @[@"6", @"17"], @"JingtumEscrow",
                              @[@"6", @"18"], @"DeliveredAmount",
                              @[@"7", @"1"], @"PublicKey",
                              @[@"7", @"2"], @"MessageKey",
                              @[@"7", @"3"], @"SigningPubKey",
                              @[@"7", @"4"], @"TxnSignature",
                              @[@"7", @"5"], @"Generator",
                              @[@"7", @"6"], @"Signature",
                              @[@"7", @"7"], @"Domain",
                              @[@"7", @"8"], @"FundCode",
                              @[@"7", @"9"], @"RemoveCode",
                              @[@"7", @"10"], @"ExpireCode",
                              @[@"7", @"11"], @"CreateCode",
                              @[@"7", @"12"], @"MemoType",
                              @[@"7", @"13"], @"MemoData",
                              @[@"7", @"14"], @"MemoFormat",
                              @[@"7", @"15"], @"Payload",
                              @[@"7", @"17"], @"ContractMethod",
                              @[@"7", @"18"], @"Parameter",
                              @[@"8", @"1"], @"Account",
                              @[@"8", @"2"], @"Owner",
                              @[@"8", @"3"], @"Destination",
                              @[@"8", @"4"], @"Issuer",
                              @[@"8", @"7"], @"Target",
                              @[@"8", @"8"], @"RegularKey",
                              @[@"15", @"1"], @"undefined",
                              @[@"14", @"2"], @"TransactionMetaData",
                              @[@"14", @"3"], @"CreatedNode",
                              @[@"14", @"4"], @"DeletedNode",
                              @[@"14", @"5"], @"ModifiedNode",
                              @[@"14", @"6"], @"PreviousFields",
                              @[@"14", @"7"], @"FinalFields",
                              @[@"14", @"8"], @"NewFields",
                              @[@"14", @"9"], @"TemplateEntry",
                              @[@"14", @"10"], @"Memo",
                              @[@"14", @"11"], @"Arg",
                              @[@"15", @"2"], @"SigningAccounts",
                              @[@"15", @"3"], @"TxnSignatures",
                              @[@"15", @"4"], @"Signatures",
                              @[@"15", @"5"], @"Template",
                              @[@"15", @"6"], @"Necessary",
                              @[@"15", @"7"], @"Sufficient",
                              @[@"15", @"8"], @"AffectedNodes",
                              @[@"15", @"9"], @"Memos",
                              @[@"15", @"10"], @"Args",
                              @[@"16", @"1"], @"CloseResolution",
                              @[@"16", @"2"], @"TemplateEntryType",
                              @[@"16", @"3"], @"TransactionResult",
                              @[@"17", @"1"], @"TakerPaysCurrency",
                              @[@"17", @"2"], @"TakerPaysIssuer",
                              @[@"17", @"3"], @"TakerGetsCurrency",
                              @[@"17", @"4"], @"TakerGetsIssuer",
                              @[@"18", @"1"], @"Paths",
                              @[@"19", @"1"], @"Indexes",
                              @[@"19", @"2"], @"Hashes",
                              @[@"19", @"3"], @"Amendments",
                              nil];
    }
    
    return self;
}

-(NSString*)from_json:(NSDictionary*)dic
{
    NSString *ret = nil;
    
    NSString *TransactionType = [dic objectForKey:@"TransactionType"];
    if (TransactionType != nil) {
        // 对应的是：if (typeof obj.TransactionType === 'string') {
        NSDictionary *typedefDic = [TRANSACTION_TYPES objectForKey:TransactionType];
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
        
        NSString *index = [TRANSACTION_TYPES_INDEX objectForKey:TransactionType];
        NSNumber *number = [NSNumber numberWithInt:[index intValue]];
        [newDic setObject:number forKey:@"TransactionType"];
        
        so = [[NSMutableData alloc] init];
        
        [self serialize:typedefDic obj:newDic];
        
        if ([so length] > 0) {
            NSString *tmp = [self bytes_to_str:so];
            ret = [tmp uppercaseString];
        }
    }
    
    return ret;
}

-(NSString*)bytes_to_str:(NSData*)data
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < 256; i++) {
        NSString *hexString = [NSString stringWithFormat:@"%x", i];
        if ([hexString length] == 1) {
            hexString = [@"0" stringByAppendingString:hexString];
            hexString = [hexString uppercaseString];
        }
//        NSLog(@"the hexstr is %@", hexString);
        NSNumber *index = [NSNumber numberWithInt:i];
        [dic setObject:hexString forKey:index];
    }
    
    NSString *ret = [[NSString alloc] init];
    char *cstr = [data bytes];
    int len = [data length];
    for (int i = 0; i < len; i++) {
        char aBytes = cstr[i];
        int value = (int)aBytes & 0xFF;
        NSNumber *index = [NSNumber numberWithInt:value];
        ret = [ret stringByAppendingString:[dic objectForKey:index]];
    }
    
    return ret;
}

-(NSData*)hash:(long)prefix
{
    NSMutableData *sign_buffer = [[NSMutableData alloc] init];
    NSData * prefixData = [self bytesFromUInt32:prefix];
    [sign_buffer appendData:prefixData];
    [sign_buffer appendData:so];
    
    NSMutableData *data = BTCSHA512(sign_buffer);
    NSData *retData = nil;
    if ([data length] >= 32) {
        retData = [data subdataWithRange:NSMakeRange(0, 32)];
    }
    
    return retData;
}

-(void)serialize:(NSDictionary*)typedefDic obj:(NSDictionary*)dic
{
    NSArray *keys = [dic allKeys];
    NSArray *sortKeys = [self sort_fields:keys];
    for (NSString *key in sortKeys) {
        NSLog(@"the key is %@", key);
        [self doserialize:key obj:[dic objectForKey:key]];
    }
}

-(NSData *)byteFromUInt8:(uint8_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[1];
    valChar[0] = 0xff & val;
    [valData appendBytes:valChar length:1];
    
    return valData;
}

-(NSData *)bytesFromUInt16:(uint16_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[2];
    valChar[1] = 0xff & val;
    valChar[0] = (0xff00 & val) >> 8; // xutm 这边有可能实现那个三个移位的功能哦
    [valData appendBytes:valChar length:2];
    
    return valData;
}

-(NSData *)bytesFromUInt32:(uint32_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[4];
    valChar[3] = 0xff & val;
    valChar[2] = (0xff00 & val) >> 8;
    valChar[1] = (0xff0000 & val) >> 16;
    valChar[0] = (0xff000000 & val) >> 24;
    [valData appendBytes:valChar length:4];
    
    return valData;
}

-(void)doserialize:(NSString*)field_name obj:(id)objValue
{
    NSArray *field_coordinates = [INVERSE_FIELDS_MAP objectForKey:field_name];
    NSString *type_bits_str  = [field_coordinates objectAtIndex:0];
    NSString *field_bits_str = [field_coordinates objectAtIndex:1];
//    uint8_t type_bits  = [type_bits_str integerValue];
//    uint8_t field_bits = [field_bits_str integerValue];
//    uint8_t tag_byte = (type_bits < 16 ? type_bits << 4 : 0) | (field_bits < 16 ? field_bits : 0);
    int type_bits  = [type_bits_str intValue];
    int field_bits = [field_bits_str intValue];
    int tag_byte = (type_bits < 16 ? type_bits << 4 : 0) | (field_bits < 16 ? field_bits : 0);
    NSLog(@"the tag_byte is %d the field_name is %@", tag_byte, field_name);
    
    NSString *classtype = [objValue class];
    NSLog(@"the classtype is %@", classtype);
    // if ('string' === typeof value) { // xutm 但是其实这边是没有进来的哦！！！！！！！！！！！to be continue
    
    if ([objValue isKindOfClass:[NSString class]]) {
        if ([field_name isEqualToString:@"LedgerEntryType"]) {
//            value = get_ledger_entry_type(value);
        } else if ([field_name isEqualToString:@"TransactionResult"]) {
//            value = get_transaction_type(value);//binformat.ter[value];
        }
    }
    // 1. 对 tag_byte 进行序列化
    NSData *data = [self byteFromUInt8:tag_byte];
    [so appendData:data];
    
    if (type_bits >= 16) {
        // 对 type_bits 进行序列化
        NSData *data = [self byteFromUInt8:type_bits];
        [so appendData:data];
    }
    if (field_bits >= 16) {
        // 对 field_bits 进行序列化
        NSData *data = [self byteFromUInt8:field_bits];
        [so appendData:data];
    }
    
    if ([field_name isEqualToString:@"Memo"]) {
        if ([objValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*)objValue;
            NSArray *keys = [dic allKeys];
            for (NSString *key in keys) {
                NSLog(@"the key should be MemoData: %@", key); // the key should be MemoData
                id value = [dic objectForKey:key];
                NSData *data = nil;
                if ([key isEqualToString:@"MemoType"] || [key isEqualToString:@"MemoFormat"]) {
                    data = [value data];
                } else if ([key isEqualToString:@"MemoData"]) {
                    if ([value isKindOfClass:[NSString class]]) {
                        NSString *str = (NSString*)value;
                        data = [str dataUsingEncoding:NSUTF8StringEncoding];
                    } else {
                        
                    }
                }
                
                [self doserialize:key obj:data];
            }
            // STInt8.serialize(so, 0xe1);
            NSData *no_marker_value = [self byteFromUInt8:0xe1];
            [so appendData:no_marker_value];
        }
        
        return;
    }
    
    // 2. 对值进行序列化，比如 int16，就是占用了2个字节
    NSString *typeKey = [NSString stringWithFormat:@"%d", type_bits];
    NSString *typebits_str = [TYPES_MAP objectForKey:typeKey];
    if ([typebits_str isEqualToString:@"Int16"]) {
        int value = [((NSNumber*)objValue) intValue];
        data = [self bytesFromUInt16:value];
        [so appendData:data];
    } else if ([typebits_str isEqualToString:@"Int32"]) {
        int value = [((NSNumber*)objValue) intValue];
        data = [self bytesFromUInt32:value];
        [so appendData:data];
    } else if ([typebits_str isEqualToString:@"Amount"]) {
        // 进行 Amount 的序列化??????
        if ([objValue isKindOfClass:[NSNumber class]]) {
            double value = [(NSNumber*)objValue doubleValue];
            [self parse_swt_value:value data:so];
        } else if ([objValue isKindOfClass:[NSString class]]) {
            double value = [(NSString*)objValue doubleValue];
            [self parse_swt_value:value data:so];
        } else if ([objValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*)objValue;
            NSString *currency = [dic objectForKey:@"currency"];
            if ([self isTumCode:currency]) {
                //
                if (![currency isEqualToString:@"SWT"]) {
                    // 非 SWT 原生币
                    NSString *issuer = [dic objectForKey:@"issuer"];
                    if ([self isValidAddress:issuer]) { // 这边判断是否是合法的地址 To be continue...
                        TumAmount *amount = [[TumAmount alloc] init];
                        [amount parseJson:dic];
                        
                        int hi = 0, lo = 0;
                        hi |= 1 << 31;
                        
                        if (![amount is_zero]) {
                            if (![amount is_negative]) {
                                hi |= 1 << 30;
                            }
                            hi |= ((97 + amount.offset) & 0xff) << 22;
                            // Remaining 54 bits: mantissa
                            long value = amount.value; // ?????
                            hi |= (value >> 32) & 0x3fffff;
                            lo = value & 0xffffffff;
                        }
                        int arr[2] = {hi, lo};
                        int l = 2, x, bl, i, tmp;
                        if (l == 0) {
                            bl = 0;
                        } else {
                            x = arr[l - 1];
                            int roundX = round(x / 0x10000000000);
                            if (roundX == 0) {
                                roundX = 32;
                            }
//                            bl = (l - 1) * 32 + roundX||32; //
                            bl = (l - 1) * 32 + roundX; //
                        }
                        NSMutableData *tmparray = [[NSMutableData alloc] init];
                        for (i = 0; i < bl/8; i++) {
                            if ((i & 3) == 0) {
                                tmp = arr[i / 4];
                            }
                            long tmpvalue = (unsigned int)tmp >> 24; // 
                            NSData *data = [self byteFromUInt8:tmpvalue];
                            [tmparray appendData:data];
                            tmp <<= 8;
                        }
                        if ([tmparray length] > 8) {
                            NSLog(@"Invalid byte array length in AMOUNT value representation");
                        }
                        [so appendData:tmparray];
                        
                        NSData *tum_bytes = [amount tum_to_bytes];
                        [so appendData:tum_bytes];
                        
                        Keypairs *keypairs = [[Keypairs alloc] init];
                        NSString *address = [dic objectForKey:@"issuer"];
                        NSData *datastr = [keypairs convertAddressToBytes:address];
                        [so appendData:datastr];
                    } else {
                        NSLog(@"Amount.parse_json: Input JSON has invalid issuer info!");
                    }
                } else {
                    NSString *valuestr = [dic objectForKey:@"value"];
                    double value = [valuestr doubleValue];
                    [self parse_swt_value:value data:so];
                }
            } else {
                NSLog(@"Amount.parse_json: Input JSON has invalid Tum info!");
            }
        }
        
        
    } else if ([typebits_str isEqualToString:@"VL"]) {
        // 进行字符串的序列化
        NSLog(@"the classtype is %@", classtype);
        if ([objValue isKindOfClass:[NSData class]]) {
            NSData *value = (NSData*)objValue;
            int length = [value length];
            NSData *data = [self byteFromUInt8:length];
            [so appendData:data];
            
            [so appendData:value];
        }
    } else if ([typebits_str isEqualToString:@"Account"]) {
        if ([objValue isKindOfClass:[NSString class]]) {
            NSString *address = (NSString*)objValue;
            
            Keypairs *keypairs = [[Keypairs alloc] init];
            
            NSData *datastr = [keypairs convertAddressToBytes:address];
        
            int length = [datastr length];
            NSData *data = [self byteFromUInt8:length];
            [so appendData:data];
        
            [so appendData:datastr];
        }
    } else if ([typebits_str isEqualToString:@"Array"]) {
        if ([objValue isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray*)objValue;
            for (id iter in array) {
                if ([iter isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = (NSDictionary*)iter;
                    NSString *field_name = @"Memo";
                    [self doserialize:field_name obj:dic];
                }
            }
            
            // STInt8.serialize(so, 0xf1);
            NSData *ending_marker_value = [self byteFromUInt8:0xf1];
            [so appendData:ending_marker_value];
        }
    }
}

-(BOOL)isValidAddress:(NSString*)address
{
    return true;
}

-(void)parse_swt_value:(double)value data:(NSMutableData*)so
{
    value = value * 1000000;
    long newvalue = (long)(value+0.5);
    BTCBigNumber *bn = [[BTCBigNumber alloc] initWithInt32:newvalue];
    NSData *data = [bn unsignedData];
    if (data.length >= 32) {
        NSData *subdata = [data subdataWithRange:NSMakeRange(24, 8)];
        
        char *cstr = [subdata bytes];
        int length = 8;
        char ret[8];
        memcpy(ret, cstr, 8);
        ret[0] &= 0x3f;
        ret[0] |= 0x40;
        [so appendBytes:ret length:8];
    }
}

-(BOOL)isTumCode:(NSString*)in_code
{
    BOOL ret = false;
    if ([in_code isEqualToString:@"SWT"] || [self isCurrency:in_code] || [self isCustomTum:in_code]) {
        ret = true;
    }
    
    return ret;
}

-(BOOL)isCurrency:(NSString*)in_code
{
    BOOL ret = false;
    
    int len = [in_code length];
    if (CURRENCY_NAME_LEN <= len && len <= CURRENCY_NAME_LEN2) {
        ret = true;
    }
    
    return ret;
}
// 判断是否只包含数字和字符，To be continue...
-(BOOL)isCustomTum:(NSString*)in_code
{
    BOOL ret = true;
    
    return ret;
}

-(NSArray*)sort_fields:(NSArray*)keys
{
    NSArray *ret = [keys sortedArrayWithOptions:NSSortStable usingComparator:
                    ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        NSArray *a_field_coordinates = [INVERSE_FIELDS_MAP objectForKey:obj1];
                        NSArray *b_field_coordinates = [INVERSE_FIELDS_MAP objectForKey:obj2];
                        
                        NSString *a_type_bits_str  = [a_field_coordinates objectAtIndex:0];
                        NSString *a_field_bits_str = [a_field_coordinates objectAtIndex:1];
                        
                        NSString *b_type_bits_str  = [b_field_coordinates objectAtIndex:0];
                        NSString *b_field_bits_str = [b_field_coordinates objectAtIndex:1];
                        
                        int a_type_bits  = [a_type_bits_str integerValue];
                        int a_field_bits = [a_field_bits_str integerValue];
                        int b_type_bits  = [b_type_bits_str integerValue];
                        int b_field_bits = [b_field_bits_str integerValue];
                        
                        if (a_type_bits != b_type_bits) {
                            if (a_type_bits > b_type_bits) {
                                return NSOrderedDescending;
                            } else if (a_type_bits == b_type_bits) {
                                return NSOrderedSame;
                            } else {
                                return NSOrderedAscending;
                            }
                        } else {
                            if (a_field_bits > b_field_bits) {
                                return NSOrderedDescending;
                            } else if (a_field_bits == b_field_bits) {
                                return NSOrderedSame;
                            } else {
                                return NSOrderedAscending;
                            }
                        }
                    }];
    
    return ret;
}

@end
