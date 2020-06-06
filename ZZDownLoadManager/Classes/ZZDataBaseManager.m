//
//  ZZDataBaseManager.m
//  ZZDownloadDemo
//
//  Created by wenmei on 2020/6/5.
//  Copyright © 2020 hero. All rights reserved.
//

#import "ZZDataBaseManager.h"
#import "FMDB.h"
#import "ZZToolBox.h"
#import "ZZDownLoadModel.h"
#import "ZZGlobalConst.h"
typedef NS_ENUM(NSInteger, ZZDBGetDateOption) {
    ZZDBGetDateOptionAllCacheData = 0,      // 所有缓存数据
    ZZDBGetDateOptionAllDownloadingData,    // 所有正在下载的数据
    ZZDBGetDateOptionAllDownloadedData,     // 所有下载完成的数据
    ZZDBGetDateOptionAllUnDownloadedData,   // 所有未下载完成的数据
    ZZDBGetDateOptionAllWaitingData,        // 所有等待下载的数据
    ZZDBGetDateOptionModelWithUrl,          // 通过url获取单条数据
    ZZDBGetDateOptionWaitingModel,          // 第一条等待的数据
    ZZDBGetDateOptionLastDownloadingModel,  // 最后一条正在下载的数据
};


@interface ZZDataBaseManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation ZZDataBaseManager

// 获取单例
+ (instancetype)shareManager
{
    static ZZDataBaseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
    
}

- (instancetype)init
{
    if (self = [super init]) {
        [self creatCachesTable];
    }
    return self;
}
- (void)creatCachesTable
{
    // 数据库文件路径
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZZDownloadFileCaches.sqlite"];
    
    // 创建队列对象，内部会自动创建一个数据库, 并且自动打开
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];

    [_dbQueue inDatabase:^(FMDatabase *db) {
        // 创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS zz_fileCaches (id integer PRIMARY KEY AUTOINCREMENT, vid text, fileName text, url text, resumeData blob, totalFileSize integer, tmpFileSize integer, state integer, progress float, lastSpeedTime double, intervalFileSize integer, lastStateTime integer)"];
        if (result) {
//            ZZLog(@"视频缓存数据表创建成功");
        }else {
            NSLog(@"缓存数据表创建失败");
        }
    }];
}

// 插入数据
- (void)zz_insertModel:(ZZDownLoadModel *)model
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL result = [db executeUpdate:@"INSERT INTO zz_fileCaches (vid, fileName, url, resumeData, totalFileSize, tmpFileSize, state, progress, lastSpeedTime, intervalFileSize, lastStateTime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", model.vid, model.fileName, model.url, model.resumeData, [NSNumber numberWithInteger:model.totalFileSize], [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithInteger:model.state], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithDouble:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]];
            if (result) {
    //            ZZLog(@"插入成功：%@", model.fileName);
            }else {
                NSLog(@"插入失败：%@", model.fileName);
            }
        }];
}
// 根据url获取数据
- (ZZDownLoadModel *)zz_getModelWithUrl:(NSString *)url
{
    return [self getModelWithOption:ZZDBGetDateOptionModelWithUrl url:url];
}
// 获取第一条等待的数据
- (ZZDownLoadModel *)zz_getWaitingModel
{
    return [self getModelWithOption:ZZDBGetDateOptionWaitingModel url:nil];
}
// 获取最后一条正在下载的数据
- (ZZDownLoadModel *)zz_getLastDownloadingModel
{
    return [self getModelWithOption:ZZDBGetDateOptionLastDownloadingModel url:nil];
}
// 获取所有数据
- (NSArray<ZZDownLoadModel *> *)zz_getAllCacheData
{
    return [self getDateWithOption:ZZDBGetDateOptionAllCacheData];
}
// 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<ZZDownLoadModel *> *)zz_getAllDownloadingData
{
    return [self getDateWithOption:ZZDBGetDateOptionAllDownloadingData];
}
// 获取所有下载完成的数据
- (NSArray<ZZDownLoadModel *> *)zz_getAllDownloadedData
{
    return [self getDateWithOption:ZZDBGetDateOptionAllDownloadedData];
}
// 获取所有未下载完成的数据（包含正在下载、等待、暂停、错误）
- (NSArray<ZZDownLoadModel *> *)zz_getAllUnDownloadedData
{
   return [self getDateWithOption:ZZDBGetDateOptionAllUnDownloadedData];
}
// 获取所有等待下载的数据
- (NSArray<ZZDownLoadModel *> *)zz_getAllWaitingData
{
    return [self getDateWithOption:ZZDBGetDateOptionAllWaitingData];
}

// 获取单条数据
- (ZZDownLoadModel *)getModelWithOption:(ZZDBGetDateOption)option url:(NSString *)url
{
    __block ZZDownLoadModel *model = nil;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet;
        switch (option) {
            case ZZDBGetDateOptionModelWithUrl:
                resultSet = [db executeQuery:@"SELECT * FROM zz_fileCaches WHERE url = ?", url];
                break;
                
            case ZZDBGetDateOptionWaitingModel:
                resultSet = [db executeQuery:@"SELECT * FROM zz_fileCaches WHERE state = ? order by lastStateTime asc limit 0,1", [NSNumber numberWithInteger:ZZDownloadStateWaiting]];
                break;
                
            case ZZDBGetDateOptionLastDownloadingModel:
                resultSet = [db executeQuery:@"SELECT * FROM zz_fileCaches WHERE state = ? order by lastStateTime desc limit 0,1", [NSNumber numberWithInteger:ZZDownloadStateDownloading]];
                break;
                
            default:
                break;
        }
        
        while ([resultSet next]) {
            model = [[ZZDownLoadModel alloc] initWithFMResultSet:resultSet];
        }
    }];
    
    return model;
}

// 获取数据集合
- (NSArray<ZZDownLoadModel *> *)getDateWithOption:(ZZDBGetDateOption)option
{
    __block NSArray<ZZDownLoadModel *> *array = nil;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet;
        switch (option) {
            case ZZDBGetDateOptionAllCacheData:
                resultSet = [db executeQuery:@"SELECT * FROM zz_fileCaches"];
                break;
                
            case ZZDBGetDateOptionAllDownloadingData:
                resultSet = [db executeQuery:@"SELECT * FROM zz_fileCaches WHERE state = ? order by lastStateTime desc", [NSNumber numberWithInteger:ZZDownloadStateDownloading]];
                break;
                
            case ZZDBGetDateOptionAllDownloadedData:
                resultSet = [db executeQuery:@"SELECT * FROM zz_fileCaches WHERE state = ?", [NSNumber numberWithInteger:ZZDownloadStateFinish]];
                break;
                
            case ZZDBGetDateOptionAllUnDownloadedData:
                resultSet = [db executeQuery:@"SELECT * FROM zz_fileCaches WHERE state != ?", [NSNumber numberWithInteger:ZZDownloadStateFinish]];
                break;
                
            case ZZDBGetDateOptionAllWaitingData:
                resultSet = [db executeQuery:@"SELECT * FROM zz_fileCaches WHERE state = ?", [NSNumber numberWithInteger:ZZDownloadStateWaiting]];
                break;
                
            default:
                break;
        }
        
        NSMutableArray *tmpArr = [NSMutableArray array];
        while ([resultSet next]) {
            [tmpArr addObject:[[ZZDownLoadModel alloc] initWithFMResultSet:resultSet]];
        }
        array = tmpArr;
    }];
    
    return array;
}

// 更新数据
- (void)zz_updateWithModel:(ZZDownLoadModel *)model option:(ZZDBUpdateOption)option
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        if (option & ZZDBUpdateOptionState) {
            [self postStateChangeNotificationWithFMDatabase:db model:model];
            [db executeUpdate:@"UPDATE zz_fileCaches SET state = ? WHERE url = ?", [NSNumber numberWithInteger:model.state], model.url];
        }
        if (option & ZZDBUpdateOptionLastStateTime) {
            [db executeUpdate:@"UPDATE zz_fileCaches SET lastStateTime = ? WHERE url = ?", [NSNumber numberWithInteger:[ZZToolBox getTimeStampWithDate:[NSDate date]]], model.url];
        }
        if (option & ZZDBUpdateOptionResumeData) {
            [db executeUpdate:@"UPDATE zz_fileCaches SET resumeData = ? WHERE url = ?", model.resumeData, model.url];
        }
        if (option & ZZDBUpdateOptionProgressData) {
            [db executeUpdate:@"UPDATE zz_fileCaches SET tmpFileSize = ?, totalFileSize = ?, progress = ?, lastSpeedTime = ?, intervalFileSize = ? WHERE url = ?", [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithFloat:model.totalFileSize], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithDouble:model.lastSpeedTime], [NSNumber numberWithInteger:model.intervalFileSize], model.url];
        }
        if (option & ZZDBUpdateOptionAllParam) {
            [self postStateChangeNotificationWithFMDatabase:db model:model];
            [db executeUpdate:@"UPDATE zz_fileCaches SET resumeData = ?, totalFileSize = ?, tmpFileSize = ?, progress = ?, state = ?, lastSpeedTime = ?, intervalFileSize = ?, lastStateTime = ? WHERE url = ?", model.resumeData, [NSNumber numberWithInteger:model.totalFileSize], [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithInteger:model.state], [NSNumber numberWithDouble:model.lastSpeedTime], [NSNumber numberWithInteger:model.intervalFileSize], [NSNumber numberWithInteger:[ZZToolBox getTimeStampWithDate:[NSDate date]]], model.url];
        }
    }];
}

// 状态变更通知
- (void)postStateChangeNotificationWithFMDatabase:(FMDatabase *)db model:(ZZDownLoadModel *)model
{
    // 原状态
    NSInteger oldState = [db intForQuery:@"SELECT state FROM zz_fileCaches WHERE url = ?", model.url];
    if (oldState != model.state && oldState != ZZDownloadStateFinish) {
        // 状态变更通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ZZDownloadStateChangeNotification object:model];
    }
}
// 删除数据
- (void)zz_deleteModelWithUrl:(NSString *)url
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL result = [db executeUpdate:@"DELETE FROM zz_fileCaches WHERE url = ?", url];
            if (result) {
    //            HWLog(@"删除成功：%@", url);
            }else {
                NSLog(@"删除失败：%@", url);
            }
        }];
}

@end
