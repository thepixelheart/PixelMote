//
//  PFNetworkManager.m
//  PixelMote
//
//  Created by Ian Mendiola on 12/26/12.
//  Copyright (c) 2012 PixelFactory. All rights reserved.
//

#import "PFNetworkManager.h"

NSString* const PHNetworkManagerDidFindServerNotification = @"PHNetworkManagerDidFindServerNotification";
NSString* const PHNetworkManagerDidRemoveServerNotification = @"PHNetworkManagerDidRemoveServerNotification";

@interface PFNetworkManager() <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@end

@implementation PFNetworkManager {
  NSNetServiceBrowser* _browser;
  NSNetService* _service;
}

static PFNetworkManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (PFNetworkManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[self allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.host = nil;
        self.port = 0;
        initalizingConnection = NO;


      _browser = [[NSNetServiceBrowser alloc] init];
      _browser.delegate = self;
      [_browser scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
      [_browser searchForServicesOfType:@"_pixelmote._tcp." inDomain:@""];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)initNetworkConnectionWithPreviousHostAndPort
{
    if (self.host && self.port > 0) {
        [self initNetworkConnectionWithHost:self.host port:self.port block:streamBlock];
    }
}

- (void)initNetworkConnectionWithHost:(NSString *)h port:(NSInteger)p block:(void (^)(BOOL))block{
  [self closeNetworkConnection];

    initalizingConnection = YES;
    streamBlock = [block copy];
    
    if (!outputStream && !inputStream) {
        self.host = [h copy];
        self.port = p;
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

- (void)setStreamBlock:(void(^)(BOOL success))block {
  streamBlock = [block copy];
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
        streamEvent & NSStreamEventHasSpaceAvailable &&
        initalizingConnection) {
        initalizingConnection = NO;
        streamBlock(YES);
    }
    
    if (streamEvent & NSStreamEventErrorOccurred) {
        if (theStream == outputStream) {
            streamBlock(NO);
            outputStream = nil;
        } else if (theStream == inputStream) {
            inputStream = nil;
        }
    }
}

#pragma mark - NSNetServiceBrowserDelegate

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
  _service = aNetService;
  _service.delegate = self;
  [_service resolveWithTimeout:15.0];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:PHNetworkManagerDidRemoveServerNotification object:nil];
}

#pragma mark - NSNetServiceDelegate

-(void)netServiceDidResolveAddress:(NSNetService *)sender {
  self.host = [sender hostName];
  self.port = [sender port];

  NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:PHNetworkManagerDidFindServerNotification object:nil];
}

@end
