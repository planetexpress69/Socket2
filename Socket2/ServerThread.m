//
//  ServerThread.m
//  TCPDataTransfer
//
//  Created by Martin Kautz on 23.08.16.
//  Copyright © 2016 Raketenmann. All rights reserved.
//

#import "ServerThread.h"

@implementation ServerThread

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Establish the socket
/* ---------------------------------------------------------------------------------------------- */
- (void)initializeServer {
    CFSocketContext sctx = { 0, (__bridge void *)(self), NULL, NULL, NULL };
    obj_server = CFSocketCreate(kCFAllocatorDefault, AF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, TCPServerCallBackHandler, &sctx);
    int so_reuse_flag = 1;
    setsockopt(CFSocketGetNative(obj_server), SOL_SOCKET, SO_REUSEADDR, &so_reuse_flag, sizeof(so_reuse_flag));
    struct sockaddr_in sock_addr;
    memset(&sock_addr, 0, sizeof(sock_addr));
    sock_addr.sin_len=sizeof(sock_addr);
    sock_addr.sin_family=AF_INET;
    sock_addr.sin_port=htons(6658);
    sock_addr.sin_addr.s_addr=INADDR_ANY;

    CFDataRef dref=CFDataCreate(kCFAllocatorDefault, (UInt8*)&sock_addr, sizeof(sock_addr));
    CFSocketSetAddress(obj_server, dref);
    CFRelease(dref);
    NSLog(@"Server initialized!");
}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Thread's main to wire the socket to run loop
/* ---------------------------------------------------------------------------------------------- */
-(void)main{
    CFRunLoopSourceRef loopref = CFSocketCreateRunLoopSource(kCFAllocatorDefault, obj_server, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loopref, kCFRunLoopDefaultMode);
    CFRelease(loopref);
    CFRunLoopRun();
    NSLog(@"Server wired to run loop!");
}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - IBAction to invalidate the thread and remove it from the run loop
/* ---------------------------------------------------------------------------------------------- */
-(void)StopServer{
    CFSocketInvalidate(obj_server);
    CFRelease(obj_server);
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"Server stopped!");
}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Socket server's callback function
/* ---------------------------------------------------------------------------------------------- */
void TCPServerCallBackHandler(CFSocketRef cfSocket,
                              CFSocketCallBackType callbacktype,
                              CFDataRef address,
                              const void *data,
                              void *info)
{
    switch (callbacktype) {
        case kCFSocketAcceptCallBack:
      {

        ServerThread *server = (__bridge ServerThread *)info;

        // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        uint8_t peerName[SOCK_MAXADDRLEN];
        socklen_t namelen = sizeof(peerName);
        NSData *peer = nil;

        if (0 == getpeername(nativeSocketHandle, (struct sockaddr *)peerName, &namelen)) {
            peer = [NSData dataWithBytes:peerName length:namelen];
        }

        // set up streams - we actually don't need an output

        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);


        if (readStream && writeStream) {
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);


            // nice! hand over to stream handling...
            [server handleNewConnectionFromAddress:peer
                                       inputStream:(__bridge NSInputStream *)readStream
                                      outputStream:(__bridge NSOutputStream *)writeStream];
        } else {
            // on any failure, need to destroy the CFSocketNativeHandle
            // since we are not going to use it any more
            close(nativeSocketHandle);
        }

        if (readStream)
            CFRelease(readStream);

        if (writeStream)
            CFRelease(writeStream);
      }
            break;

        default:
            break;
    }


}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Stream handling
/* ---------------------------------------------------------------------------------------------- */
- (void)handleNewConnectionFromAddress:(NSData *)addr
                           inputStream:(NSInputStream *)istr
                          outputStream:(NSOutputStream *)ostr {

    inputStream = (NSInputStream *)istr;
    [inputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];


    // if the delegate implements the delegate method, call it
    //if (delegate && [delegate respondsToSelector:@selector(ServerThread:didReceiveConnectionFromAddress:inputStream:outputStream:)]) {
    //    [delegate TCPServer:self didReceiveConnectionFromAddress:addr inputStream:istr outputStream:ostr];
    //}
}


/* ---------------------------------------------------------------------------------------------- */
#pragma mark - NSStreamDelegate protocol methods
/* ---------------------------------------------------------------------------------------------- */
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {


    switch(eventCode) {
        case NSStreamEventNone:
            NSLog(@"None!");
            break;
        case NSStreamEventOpenCompleted:
            //NSLog(@"OpenCompleted!");
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"HasSpaceAvailable!");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"EventErrorOccurred!");
            break;
        case NSStreamEventEndEncountered:
            //NSLog(@"EventEndEncountered!");
            //NSLog(@"> %@", [[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding]);
            [[NSNotificationCenter defaultCenter]postNotificationName:@"DidGetCommand" object:[[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding]];
            _data = [NSMutableData data];
            break;
        case NSStreamEventHasBytesAvailable:
      {

        //NSLog(@"HasBytesAvailable!");

        if(!_data) {
            _data = [NSMutableData data];
        }
        uint8_t buf[1024];
        unsigned int len = 0;
        len = (int)[(NSInputStream *)stream read:buf maxLength:1024];
        //NSLog(@"len: %d", len);
        if(len && len > 0) {
            [_data appendBytes:(const void *)buf length:len];
            //NSLog(@"Got: %@", [[NSString alloc]initWithData:_data encoding:NSUTF8StringEncoding]);
            //_data = [NSMutableData data];
        } else {
            //NSLog(@"no buffer!");
        }
        break;
      }
    }
    
}

@end
