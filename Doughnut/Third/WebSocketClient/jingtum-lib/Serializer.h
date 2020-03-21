//
//  Serializer.h
//  WebSocketClient
//
//  Created by tongmuxu on 2018/8/13.
//  Copyright © 2018年 tongmuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Serializer : NSObject
{
    NSMutableDictionary *base;
    NSMutableDictionary *TRANSACTION_TYPES;
    NSMutableDictionary *TRANSACTION_TYPES_INDEX;
    NSMutableDictionary *INVERSE_FIELDS_MAP;
    NSMutableDictionary *TYPES_MAP;
    
    NSMutableData *so;
}

-(NSString*)from_json:(NSDictionary*)dic;
-(NSData*)hash:(long)prefix;

@end
