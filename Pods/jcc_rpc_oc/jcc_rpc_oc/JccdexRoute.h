//
//  JccdexRoute.h
//  jcc_rpc_oc
//
//  Created by 沐生 on 2018/12/28.
//  Copyright © 2018 JCCDex. All rights reserved.
//

#ifndef JccdexRoute_h
#define JccdexRoute_h

// route of jccdex exchange api
#define JC_REQUEST_BALANCE_ROUTE @"/exchange/balances/%@"
#define JC_REQUEST_HISTORY_ROUTE @"/exchange/tx/%@"
#define JC_REQUEST_ORDER_ROUTE @"/exchange/orders/%@/%d"
#define JC_CREATE_ORDER_ROUTE @"/exchange/sign_order/"
#define JC_CANCEL_ORDER_ROUTE @"/exchange/sign_cancel_order/"
#define JC_REQUEST_SEQUENCE_ROUTE @"/exchange/sequence/%@"
#define JC_TRNSFER_TOKEN_ROUTE @"/exchange/sign_payment/"

// route of jccdex info api
#define JC_REQUEST_TICKER_ROUTE  @"/info/ticker/%@"
#define JC_REQUEST_ALLTICKERS_ROUTE @"/info/alltickers"
#define JC_REQUEST_DEPTH_ROUTE @"/info/depth/%@"
#define JC_REQUEST_KLINE_ROUTE @"/info/kline/%@"
#define JC_REQUEST_INFO_HISTORY_ROUTE @"/info/history/%@"

// route of jccdex config api
#define JC_REQUEST_CONFIG_ROUTE @"/static/config/jc_config.json"

#endif /* JccdexRoute_h */
