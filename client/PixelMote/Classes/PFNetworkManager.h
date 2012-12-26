//
//  PFNetworkManager.h
//  PixelMote
//
//  Created by Ian Mendiola on 12/26/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^StreamBlock)(BOOL);

@interface PFNetworkManager : NSObject <NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *host;
    NSInteger port;
    StreamBlock streamBlock;
    BOOL initalizingConnection;
}
+ (id)sharedInstance;
- (void)sendDataWithMessageType:(NSString *)type data:(NSData *)data;
- (void)initNetworkConnectionWithPreviousHostAndPort;
- (void)initNetworkConnectionWithHost:(NSString *)host port:(NSInteger)port block:(void(^)(BOOL success))block;
- (void)closeNetworkConnection;
@end
