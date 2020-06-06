//
//  ZZDownLoadManager.h
//  ZZDownloadDemo
//
//  Created by wenmei on 2020/6/5.
//  Copyright © 2020 hero. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZZDownLoadModel;

@interface ZZDownLoadManager : NSObject

+ (instancetype)shareManager;

// 开始下载
- (void)zz_startDownloadTask:(ZZDownLoadModel *)model;

// 暂停下载
- (void)zz_pauseDownloadTask:(ZZDownLoadModel *)model;

// 删除下载任务及本地缓存
- (void)zz_deleteTaskAndCache:(ZZDownLoadModel *)model;


@end

NS_ASSUME_NONNULL_END
