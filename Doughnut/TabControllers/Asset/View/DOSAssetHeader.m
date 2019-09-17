//
//  DOSAssetHeader.m
//  Doughnut
//
//  Created by xumingyang on 2019/9/12.
//  Copyright © 2019 jch. All rights reserved.
//

#import "DOSAssetHeader.h"
@interface DOSAssetHeader()

@property (weak, nonatomic) IBOutlet UILabel *totalAssetLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *CNYBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *CNYAssetLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletImport;
@property (weak, nonatomic) IBOutlet UILabel *walletCreate;
@property (weak, nonatomic) IBOutlet UIImageView *aseetSeeImage;

@end


@implementation DOSAssetHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    [self changeLanguage];
}

- (void)changeLanguage {
}

- (void)updateTotalAsset:(CGFloat)totalAsset unit:(NSString *)unit privateMode:(BOOL)privateModel {}

- (IBAction)assetImportAction:(id)sender {
}


- (IBAction)assetCreateAction:(id)sender {
}

@end
