
#import <Foundation/Foundation.h>
@class HTMIWFCAFNManager;

@protocol HTMIWFCAFNManagerDelegate <NSObject>

@optional
/**
 *  发送请求成功
 *
 *  @param manager AFNManager
 */
-(void)AFNManagerDidSuccess:(id)data;
/**
 *  发送请求失败
 *
 *  @param manager AFNManager
 */
-(void)AFNManagerDidFaild:(NSError *)error;

@end
