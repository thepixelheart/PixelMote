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
NSString* const PHNetworkManagerDidLoadAnimationsServerNotification = @"PHNetworkManagerDidLoadAnimationsServerNotification";

static NSInteger kMaxPacketSize = 1024 * 4;

typedef enum {
  PFReadStateNone,
  PFReadStateListing,
} PFReadState;

@interface PFNetworkManager() <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@end

@implementation PFNetworkManager {
  NSNetServiceBrowser* _browser;
  NSNetService* _service;

  PFReadState _readState;
  int32_t _additionalBytesLength;
  NSMutableData* _mutableData;
  int32_t _buffer;
  NSInteger _offset;
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
    
    if (!_outputStream && !_inputStream) {
        self.host = [h copy];
        self.port = p;
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)h, p, &readStream, &writeStream);
        _inputStream = (__bridge NSInputStream *)readStream;
        _outputStream = (__bridge NSOutputStream *)writeStream;
        [_inputStream setDelegate:self];
        [_outputStream setDelegate:self];
        
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
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
    [_outputStream write:[message bytes] maxLength:[message length]];
}

- (void)closeNetworkConnection
{
    if (_inputStream && [_inputStream streamStatus] == NSStreamStatusOpen) {
        [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream close];
        _inputStream = nil;
    }
    
    if (_outputStream && [_outputStream streamStatus] == NSStreamStatusOpen) {
        [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream close];
        _outputStream = nil;
    }
}

- (void)openNetworkConnection
{
    if ([_inputStream streamStatus] == NSStreamStatusNotOpen ||
        [_inputStream streamStatus] == NSStreamStatusClosed) {
        [_inputStream open];
    }
    
    if ([_outputStream streamStatus] == NSStreamStatusNotOpen ||
        [_outputStream streamStatus] == NSStreamStatusClosed) {
        [_outputStream open];
    }
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
  if (initalizingConnection) {
    if ([_outputStream streamStatus] == NSStreamStatusOpen &&
        [_inputStream streamStatus] == NSStreamStatusOpen &&
        streamEvent & NSStreamEventHasSpaceAvailable) {
        initalizingConnection = NO;
        streamBlock(YES);
    }
  } else if (streamEvent & NSStreamEventErrorOccurred) {
    if (theStream == _outputStream) {
      streamBlock(NO);
      _outputStream = nil;
    } else if (theStream == _inputStream) {
      _inputStream = nil;
    }
  } else if ([theStream isKindOfClass:[NSInputStream class]]) {
    NSInputStream* inputStream = (NSInputStream *)theStream;

    if (streamEvent & NSStreamEventHasBytesAvailable) {
      uint8_t bytes[kMaxPacketSize];
      memset(bytes, 0, sizeof(uint8_t) * kMaxPacketSize);
      NSInteger nread = [inputStream read:bytes maxLength:kMaxPacketSize];

      NSInteger start = 0;
      
      if (_readState != PFReadStateNone
          && _offset < _additionalBytesLength) {
        NSInteger bytesRemaining = _additionalBytesLength - _offset;
        NSInteger bytesToRead = MIN(nread, bytesRemaining);

        _offset += bytesToRead;
        
        [_mutableData appendBytes:bytes length:sizeof(uint8_t) * bytesToRead];
        if (bytesToRead == bytesRemaining) {
          [self didCompleteRead];
        }

        start += bytesToRead;
      }

      for (NSInteger ix = start; ix < nread; ++ix) {
        uint8_t byte = bytes[ix];
        [self readByte:byte];
      }
    }
  }
}

- (void)didCompleteRead {
  if (_readState == PFReadStateListing) {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:_mutableData];
    NSArray* animations = [[unarchiver decodeObject] copy];

    _animations = [animations copy];

    [[NSNotificationCenter defaultCenter] postNotificationName:PHNetworkManagerDidLoadAnimationsServerNotification object:nil];
  }

  _mutableData = nil;
  _readState = PFReadStateNone;
}

- (id)readByte:(uint8_t)byte {
  if (_readState == PFReadStateNone) {
    switch (byte) {
      case 'l':
        _readState = PFReadStateListing;
        _offset = 0;
        _additionalBytesLength = -1;
        _buffer = 0;
        break;

      default:
        break;
    }
  } else if (_readState == PFReadStateListing) {
    if (_additionalBytesLength == -1) {
      if (_offset < 4) {
        ((uint8_t *)&_buffer)[_offset] = byte;
        _offset++;
        if (_offset == 4) {
          _offset = 0;
          _additionalBytesLength = _buffer;
          _mutableData = [NSMutableData dataWithCapacity:_additionalBytesLength];
        }
      }
    } else {
      if (_offset < _additionalBytesLength) {
        [_mutableData appendBytes:&byte length:sizeof(uint8_t)];
        _offset++;

        if (_offset == _additionalBytesLength) {
          [self didCompleteRead];
        }
      }
    }
  }
  return nil;
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
