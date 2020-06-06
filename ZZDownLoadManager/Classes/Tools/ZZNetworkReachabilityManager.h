//
//  ZZNetworkReachabilityManager.h
//  HWDownloadDemo
//
//  Created by wenmei on 2020/6/6.
//  Copyright © 2020 hero. All rights reserved.
//  依赖于AFN

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZZNetworkReachabilityManager : NSObject
// 当前网络状态
@property (nonatomic, assign, readonly) AFNetworkReachabilityStatus networkReachabilityStatus;

// 获取单例
+ (instancetype)shareManager;

// 监听网络状态
- (void)monitorNetworkStatus;
@end

NS_ASSUME_NONNULL_END
