#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface LineModel : NSObject
@property (copy,nonatomic)   NSString *account;
@property (strong,nonatomic) NSNumber *quality_out;
@property (strong,nonatomic) NSNumber *no_skywell_peer;
@property (copy,nonatomic)   NSString *limit;
@property (strong,nonatomic) NSNumber *quality_in;
@property (copy,nonatomic)   NSString *currency;
@property (copy,nonatomic)   NSString *balance;
@property (copy,nonatomic)   NSString *limit_peer;
@end

