//
//  DOSAssetHeader.h
//  Doughnut
//
//  Created by xumingyang on 2019/9/12.
//  Copyright © 2019 jch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DOSAssetHeaderDelegate<NSObject>
- (void)DOSAssetHeaderDidTapTransactionButton;
- (void)DOSAssetHeaderDidTapReceiverButton;
- (void)DOSAssetHeaderDidTapPrivateButtonWithStatus:(BOOL)status;
@end

@interface DOSAssetHeader : UIView

@property (nonatomic, weak) id<DOSAssetHeaderDelegate> delegate;

- (void)changeLanguage;
- (void)updateTotalAsset:(CGFloat)totalAsset unit:(NSString *)unit privateMode:(BOOL)privateModel;

@end


