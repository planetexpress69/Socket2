//
//  AppDelegate.m
//  Socket2
//
//  Created by Martin Kautz on 23.08.16.
//  Copyright © 2016 Raketenmann. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate () <NSTextFieldDelegate>
@property (weak) IBOutlet NSWindow *window;
@end

#define kPrefKeyDuration @"CountdownDuration"
#define kPrefKeyShowPane @"ShowCountDownPanel"

@implementation AppDelegate

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Awakening & app start
/* ---------------------------------------------------------------------------------------------- */
- (void)awakeFromNib {

    // init UI
    [self.theMenuItemSettings setEnabled:YES];
    [self.theMenuItemQuit setEnabled:YES];

    self.theStatusBar                   = [[NSStatusBar systemStatusBar]
                                           statusItemWithLength:NSVariableStatusItemLength];
    self.theStatusBar.attributedTitle   = [[NSAttributedString alloc] initWithString:@"HCC"
                                                                          attributes:nil];
    self.theStatusBar.menu              = self.theMenu;
    self.theStatusBar.highlightMode     = YES;
    self.prefCountdownField.delegate    = self;
    self.thePanel.title                 = @"Preferences";
    self.countdownBig.textColor         = [NSColor greenColor];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    // init app defaults
    NSDictionary *appDefaults = @{ kPrefKeyDuration: @300, kPrefKeyShowPane : @YES };
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    // register as listener for the socket thread's messages
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(processCommand:)
                                                name:@"DidGetCommand" object:nil];

    // start the socket listener thread
    [self startServerNow:nil];

    // sync UI with prefs
    self.prefCountdownField.integerValue = [[NSUserDefaults standardUserDefaults]
                                            integerForKey:kPrefKeyDuration];
    self.prefShowPanelButton.state = [[NSUserDefaults standardUserDefaults]
                                      integerForKey:kPrefKeyShowPane];

    // show countdown panel according to prefs (default is hidden)
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kPrefKeyShowPane]) {
        [self showCountdownPanel];
    }
}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - ApplicationDelegate protocol methods
/* ---------------------------------------------------------------------------------------------- */
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults]synchronize];
    // Insert code here to tear down your application
}


/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Show/hide countdown panel
/* ---------------------------------------------------------------------------------------------- */
- (void) showCountdownPanel {
    [self.theCountdownPanel makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    [self.theCountdownPanel becomeKeyWindow];
    self.theCountdownPanel.title = @"HCC";
}

- (void) hideCountdownPanel {
    [self.theCountdownPanel setIsVisible:YES];
}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Open settings panel
/* ---------------------------------------------------------------------------------------------- */
- (IBAction)openSettingsPanel:(id)sender {

    // set panel's position
    NSPoint pos;
    pos.x = [NSScreen mainScreen].frame.size.width - self.thePanel.frame.size.width - 50;
    pos.y = [NSScreen mainScreen].frame.size.height - self.thePanel.frame.size.height - 50;
    [self.thePanel setFrameOrigin:pos];

    // show panel and give 'em focus
    [self.thePanel makeKeyAndOrderFront:sender];
    [NSApp activateIgnoringOtherApps:YES];
    [self.thePanel becomeKeyWindow];
}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Start & stop socket thread (stop is not currently used, TODO)
/* ---------------------------------------------------------------------------------------------- */
- (IBAction)startServerNow:(id)sender {
    obj_server_thread=[[ServerThread alloc]init];
    [obj_server_thread initializeServer];
    [obj_server_thread start];
}

- (IBAction)stopServerNow:(id)sender {
    [obj_server_thread stopServer];
    [obj_server_thread cancel];
}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Command handling & start countdown
/* ---------------------------------------------------------------------------------------------- */
- (void)processCommand:(NSNotification *) aNotification {
    if ([aNotification.object isEqualToString:@"START\n"]) {
        [self startCountdown];
    }
    if ([aNotification.object isEqualToString:@"STOP\n"]) {
        [self.countdownTimer invalidate];
        self.countdownBig.stringValue = @"";
        self.theStatusBar.attributedTitle = [[NSAttributedString alloc] initWithString:@"HCC"
                                                                            attributes:nil];
    }
}

- (void)startCountdown {
    // invalidate a possibly running timer
    [self.countdownTimer invalidate];

    // get countdown's duration from prefs
    _counter = (int)[[NSUserDefaults standardUserDefaults]integerForKey:kPrefKeyDuration];

    // start the timer which fires every second!
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                           target:self
                                                         selector:@selector(advanceTimer:)
                                                         userInfo:nil
                                                          repeats:YES];
}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Timer's payload
/* ---------------------------------------------------------------------------------------------- */
- (void)advanceTimer:(NSTimer *)timer {

    // decrement
    [self setCounter:(_counter -1)];

    // colorize the semaphor
    if (_counter < 120) {
        self.countdownBig.textColor = [NSColor yellowColor];
    }
    if (_counter < 61 ) {
        self.countdownBig.textColor = [NSColor redColor];
    }

    // update UI on panel
    self.countdownBig.stringValue = [NSString stringWithFormat:@"%d", _counter];

    // update UI on menu bar
    self.theStatusBar.attributedTitle = [[NSAttributedString alloc]
                                         initWithString:[NSString stringWithFormat:@"%d", _counter]
                                         attributes:nil];

    // invalidate at zero
    if (_counter <= 0) { [_countdownTimer invalidate]; }
}

/* ---------------------------------------------------------------------------------------------- */
#pragma mark - Preferences handling
/* ---------------------------------------------------------------------------------------------- */
- (IBAction)clickShowButton:(id)sender {
    long state = (long)((NSButton *)sender).state;

    if (state == 0) {
        [self.theCountdownPanel setIsVisible:NO];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kPrefKeyShowPane];
    } else {
        [self.theCountdownPanel setIsVisible:YES];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kPrefKeyShowPane];

    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"controlTextDidChange: stringValue == %@", [textField stringValue]);
    [[NSUserDefaults standardUserDefaults]setInteger:[textField integerValue]
                                              forKey:kPrefKeyDuration];
}

@end
