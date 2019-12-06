//
//  KSExportViewController.m
//  Doughnut
//
//  Created by xumingyang on 2019/11/19.
//  Copyright © 2019 jch. All rights reserved.
//

#import "KSExportViewController.h"
#import "TPOSMacro.h"
#import "SGQRCodeGenerateManager.h"

@interface KSExportViewController ()
@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *KeyStoreTV;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet UIButton *copylabelButton;
@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;
@end

@implementation KSExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
    self.scrollView.bounces = NO;
    [self setupView];
}

-(void)setupView {
    _KeyStoreTV.editable = NO;
    _walletNameLabel.text = self.walletName?self.walletName:@"";
    _KeyStoreTV.text = self.keyStore?self.keyStore:@"";
    if (self.keyStore&&self.keyStore.length >0){
        UIImage *code = [SGQRCodeGenerateManager generateWithDefaultQRCodeData:self.keyStore imageViewWidth:240];
        self.codeImgView.image = code;
        self.codeImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (IBAction)copyAction:(id)sender {
    if (self.keyStore&&self.keyStore.length >0){
        [[UIPasteboard generalPasteboard] setString:_KeyStoreTV.text];
        [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"copy_to_board"]];
    }
}

- (IBAction)exportAction:(id)sender {
    UIImage *image = self.codeImgView.image;
    if (!image){
        return;
    }
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:),nil);
    
}

- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError*)error contextInfo: (void*)contextInfo {
    if(error) {
        [self showErrorWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"save_fail"]];
    }else{
        [self showSuccessWithStatus:[[TPOSLocalizedHelper standardHelper] stringWithKey:@"save_succ"]];
    }
}

@end
