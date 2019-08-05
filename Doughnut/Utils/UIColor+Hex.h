//
//  UIColor+Hex.h
//  TokenBank
//
//  Created by MarcusWoo on 03/01/2018.
//  Copyright © 2018 MarcusWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(int)hex;
+ (UIColor *)colorWithHex:(int)hex alpha:(float)alpha;

@end
