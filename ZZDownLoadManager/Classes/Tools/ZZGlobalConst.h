//
//  ZZGlobalConst.h
//  ZZDownloadDemo
//
//  Created by wenmei on 2020/6/6.
//  Copyright © 2020 hero. All rights reserved.
//
#import <UIKit/UIKit.h>
/************************* 下载 *************************/
UIKIT_EXTERN NSString * const ZZDownloadProgressNotification;                   // 进度回调通知
UIKIT_EXTERN NSString * const ZZDownloadStateChangeNotification;                // 状态改变通知
UIKIT_EXTERN NSString * const ZZDownloadMaxConcurrentCountKey;                  // 最大同时下载数量key
UIKIT_EXTERN NSString * const ZZDownloadMaxConcurrentCountChangeNotification;   // 最大同时下载数量改变通知
UIKIT_EXTERN NSString * const ZZDownloadAllowsCellularAccessKey;                // 是否允许蜂窝网络下载key
UIKIT_EXTERN NSString * const ZZDownloadAllowsCellularAccessChangeNotification; // 是否允许蜂窝网络下载改变通知
UIKIT_EXTERN NSString * const ZZDownloadBackgroundURLSessionDidFinishEvents;    //后台任务执行完成后
/************************* 网络 *************************/
UIKIT_EXTERN NSString * const ZZNetworkingReachabilityDidChangeNotification;    // 网络改变改变通知
