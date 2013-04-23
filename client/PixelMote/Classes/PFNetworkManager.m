//
//  PFNetworkManager.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/26/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFNetworkManager.h"

@implementation PFNetworkManager
static PFNetworkManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (PFNetworkManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        host = nil;
        port = 0;
        initalizingConnection = NO;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)initNetworkConnectionWithPreviousHostAndPort
{
    if (host && port > 0) {
        [self initNetworkConnectionWithHost:host port:port block:streamBlock];
    }
}

- (void)initNetworkConnectionWithHost:(NSString *)h port:(NSInteger)p block:(void (^)(BOOL))block{
  [self closeNetworkConnection];

    initalizingConnection = YES;
    streamBlock = block;
    
    if (!outputStream && !inputStream) {
        host = [h copy];
        port = p;
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)h, p, &readStream, &writeStream);
        inputStream = (__bridge NSInputStream *)readStream;
        outputStream = (__bridge NSOutputStream *)writeStream;
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self openNetworkConnection];
    }
}

- (void)sendDataWithMessageType:(NSString *)type data:(NSData *)data
{
    NSMutableData *message = [[NSMutableData alloc] initWithData:[type dataUsingEncoding:NSASCIIStringEncoding]];
    [message appendData:data];
    [outputStream write:[message bytes] maxLength:[message length]];
}

- (void)closeNetworkConnection
{
    if (inputStream && [inputStream streamStatus] == NSStreamStatusOpen) {
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream close];
        inputStream = nil;
    }
    
    if (outputStream && [outputStream streamStatus] == NSStreamStatusOpen) {
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream close];
        outputStream = nil;
    }
}

- (void)openNetworkConnection
{
    if ([inputStream streamStatus] == NSStreamStatusNotOpen ||
        [inputStream streamStatus] == NSStreamStatusClosed) {
        [inputStream open];
    }
    
    if ([outputStream streamStatus] == NSStreamStatusNotOpen ||
        [outputStream streamStatus] == NSStreamStatusClosed) {
        [outputStream open];
    }
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    if ([outputStream streamStatus] == NSStreamStatusOpen &&
        [inputStream streamStatus] == NSStreamStatusOpen &&
        streamEvent == NSStreamEventHasSpaceAvailable &&
        initalizingConnection) {
        initalizingConnection = NO;
        streamBlock(YES);
    }
    
    if (streamEvent & NSStreamEventErrorOccurred) {
      NSLog(@"%@", [theStream streamError]);
        if (theStream == outputStream) {
            streamBlock(NO);
            outputStream = nil;
        } else if (theStream == inputStream) {
            inputStream = nil;
        }
    }
}
@end
