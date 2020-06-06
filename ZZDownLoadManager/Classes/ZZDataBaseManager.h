//
//  ZZDataBaseManager.h
//  ZZDownloadDemo
//
//  Created by wenmei on 2020/6/5.
//  Copyright © 2020 hero. All rights reserved.
//  基于FMDB

#import <Foundation/Foundation.h>
@class ZZDownLoadModel;

typedef NS_OPTIONS(NSUInteger, ZZDBUpdateOption) {
    ZZDBUpdateOptionState         = 1 << 0,         // 更新状态
    ZZDBUpdateOptionLastStateTime = 1 << 1,         // 更新状态最后改变的时间
    ZZDBUpdateOptionResumeData    = 1 << 2,         // 更新下载的数据
    ZZDBUpdateOptionProgressData  = 1 << 3,         // 更新进度数据（包含tmpFileSize、totalFileSize、progress、intervalFileSize、lastSpeedTime）
    ZZDBUpdateOptionAllParam      = 1 << 4          // 更新全部数据
};

NS_ASSUME_NONNULL_BEGIN

@interface ZZDataBaseManager : NSObject

// 获取单例
+ (instancetype)shareManager;

// 插入数据
- (void)zz_insertModel:(ZZDownLoadModel *)model;

// 获取数据
- (ZZDownLoadModel *)zz_getModelWithUrl:(NSString *)url;    // 根据url获取数据
- (ZZDownLoadModel *)zz_getWaitingModel;                    // 获取第一条等待的数据
- (ZZDownLoadModel *)zz_getLastDownloadingModel;            // 获取最后一条正在下载的数据
- (NSArray<ZZDownLoadModel *> *)zz_getAllCacheData;         // 获取所有数据
- (NSArray<ZZDownLoadModel *> *)zz_getAllDownloadingData;   // 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<ZZDownLoadModel *> *)zz_getAllDownloadedData;    // 获取所有下载完成的数据
- (NSArray<ZZDownLoadModel *> *)zz_getAllUnDownloadedData;  // 获取所有未下载完成的数据（包含正在下载、等待、暂停、错误）
- (NSArray<ZZDownLoadModel *> *)zz_getAllWaitingData;       // 获取所有等待下载的数据

// 更新数据
- (void)zz_updateWithModel:(ZZDownLoadModel *)model option:(ZZDBUpdateOption)option;

// 删除数据
- (void)zz_deleteModelWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
