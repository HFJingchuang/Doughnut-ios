
# jcc-oc-base-lib

An interface for interacting with the blockchain wallet operation for ios

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

## Installation with CocoaPods

To integrate `jcc_oc_base_lib` into your Xcode project using CocoaPods, specify it in your Podfile, then run `pod install`.

```ruby
pod 'jcc_oc_base_lib'
```

## API of JTWalletManager

interface for interacting with the node sdk of jingtum & jingtum alliance chains. Now supports [SWTC](https://state.jingtum.com/#!/) & [BIZAIN](https://bizain.net/) chain.

### createWallet

```objective-c
#import <jcc_oc_base_lib/JTWalletManager.h>
#import <jcc_oc_base_lib/JingtumWallet.h>
#import <jcc_oc_base_lib/JccChains.h>

// create swtc wallet
NSString *chain = SWTC_CHAIN;
// create bizain wallet
// NSString *chain = BIZAIN_CHAIN;

[[JTWalletManager shareInstance] createWallet:chain completion:^(NSError *error, JingtumWallet *wallet) {
    // create successfully if the error is nil.
}];
```

### importSecret

```objective-c
// import swtc secret
NSString *chain = SWTC_CHAIN;
// import bizain secret
// NSString *chain = BIZAIN_CHAIN;

NSString *secret = @"";

[[JTWalletManager shareInstance] importSecret:secret chain:chain completion:^(NSError *error, JingtumWallet *wallet) {
    // import succesfully if the error is nil.
}];
```

### isValidSecret

```objective-c
NSString *chain = SWTC_CHAIN;
// NSString *chain = BIZAIN_CHAIN;

NSString *secret = @"";

[[JTWalletManager shareInstance] isValidSecret:secret chain:chain completion:^(BOOL isValid) {
    // the isValid is YES if the secret is valid.
}];
```

### isValidAddress

```objective-c
NSString *chain = SWTC_CHAIN;
// NSString *chain = BIZAIN_CHAIN;

NSString *address = @"";

[[JTWalletManager shareInstance] isValidAddress:address chain:chain completion:^(BOOL isValid) {
    // the isValid is YES if the address is valid.
}];
```

### sign

```objective-c
// transaction data
NSMutableDictionary *transaction = [[NSMutableDictionary alloc] initWithCapacity:0];

NSString *secret = @"";

// sign transaction data of swtc chain
NSString *chain = SWTC_CHAIN;
// sign transaction data of bizain chain
// NSString *chain = BIZAIN_CHAIN;

[_jtWalletManager sign:transaction secret:secret chain:chain completion:^(NSError *error, NSString *signature) {
    // the error is nil if locally sign successfully.
}];
```
