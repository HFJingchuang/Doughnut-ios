//
//  CaclUnit.h
//  Doughnut
//
//  Created by xumingyang on 2019/10/17.
//  Copyright © 2019 jch. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CaclUtil : NSObject

- (NSString *)add:(NSString *)v1 :(NSString *)v2;

- (NSString *)sub:(NSString *)v1 :(NSString *)v2;

- (NSString *)mul:(NSString *)v1 :(NSString *)v2;

- (NSString *)div:(NSString *)v1 :(NSString *)v2;

- (NSString *)add:(NSString *)v1 :(NSString *)v2 :(int) scale;

- (NSString *)sub:(NSString *)v1 :(NSString *)v2 :(int) scale;

- (NSString *)mul:(NSString *)v1 :(NSString *)v2 :(int) scale;

- (NSString *)div:(NSString *)v1 :(NSString *)v2 :(int) scale;

- (NSComparisonResult)compare:(NSString *)v1 :(NSString *)v2;

- (NSString *)formatValues:(NSString *)values :(int) scale;

- (NSString *)formatAmount:(NSString *)values: (int)scale :(BOOL)decimal :(BOOL)digits;
@end

NS_ASSUME_NONNULL_END
