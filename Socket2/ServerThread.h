//
//  ServerThread.h
//  TCPDataTransfer
//
//  Created by Martin Kautz on 23.08.16.
//  Copyright © 2016 Raketenmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <sys/socket.h>
#include <netinet/in.h>

@interface ServerThread : NSThread <NSStreamDelegate>
{
    CFSocketRef obj_server;
    NSMutableData *_data;
    NSNumber *_bytesRead;
    NSInputStream *inputStream;
@public

}

-(void)initializeServer;
-(void)main;
-(void)stopServer;
@end
