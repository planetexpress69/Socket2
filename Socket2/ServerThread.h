//
//  ServerThread.h
//  TCPDataTransfer
//
//  Created by Rahul Yadav on 30/12/15.
//  Copyright © 2015 Rahul Yadav. All rights reserved.
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
-(void)StopServer;
@end
