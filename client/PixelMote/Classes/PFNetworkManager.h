//
//  PFNetworkManager.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/26/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^StreamBlock)(BOOL);

extern NSString* const PHNetworkManagerDidFindServerNotification;
extern NSString* const PHNetworkManagerDidRemoveServerNotification;

@interface PFNetworkManager : NSObject <NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    StreamBlock streamBlock;
    BOOL initalizingConnection;
}
+ (id)sharedInstance;
- (void)sendDataWithMessageType:(NSString *)type data:(NSData *)data;
- (void)initNetworkConnectionWithPreviousHostAndPort;
- (void)initNetworkConnectionWithHost:(NSString *)host port:(NSInteger)port block:(void(^)(BOOL success))block;
- (void)closeNetworkConnection;
- (void)setStreamBlock:(void(^)(BOOL success))block;
@property (nonatomic, copy) NSString* host;
@property (nonatomic, assign) NSInteger port;
@end
