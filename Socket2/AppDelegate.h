//
//  AppDelegate.h
//  Socket2
//
//  Created by Martin Kautz on 23.08.16.
//  Copyright © 2016 Raketenmann. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServerThread.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSMutableAttributedString *_noService;
    ServerThread *obj_server_thread;
    int _counter;

}
// ---------------------------------------------------------------------------------------------------------------------
@property (weak, nonatomic) IBOutlet      NSMenu                  *theMenu;
@property (weak, nonatomic) IBOutlet      NSMenuItem              *theMenuItemSettings;
@property (weak, nonatomic) IBOutlet      NSMenuItem              *theMenuItemQuit;
@property (strong, nonatomic)               NSStatusItem            *theStatusBar;
@property (weak, nonatomic) IBOutlet      NSPanel                 *thePanel;
@property (weak, nonatomic) IBOutlet      NSPanel                 *theCountdownPanel;
@property (weak, nonatomic) IBOutlet      NSTextField             *countdownBig;
@property (weak, nonatomic) IBOutlet      NSTextField             *prefCountdownField;
@property (weak, nonatomic) IBOutlet      NSButton                *prefShowPanelButton;
@property (assign)                          int                     counter;
@property (nonatomic, weak)                 NSTimer                 *countdownTimer;
// ---------------------------------------------------------------------------------------------------------------------
@end

