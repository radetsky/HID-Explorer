//
//  HXWindowManager.m
//  HID Explorer
//
//  Created by Robert Luis Hoover on 9/18/14.
//  Copyright (c) 2014 ars draconis. All rights reserved.
//

#import "HXWindowManager.h"

#import <HIDKit/HIDKit.h>

//------------------------------------------------------------------------------
#pragma mark Class Extension
//------------------------------------------------------------------------------
@interface HXWindowManager ()

@property NSMutableArray *windowControllers;

@end


//------------------------------------------------------------------------------
#pragma mark Implementation
//------------------------------------------------------------------------------
@implementation HXWindowManager

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_windowControllers = [NSMutableArray array];
	}
	return self;
}

- (void)windowForDevice:(HIDDevice *)device
{
	NSWindowController *wc;
	
	for (NSWindowController *windowController in _windowControllers)
	{
		// Look through our windows to see if we have one open for the device.
		HIDDevice *windowDevice = (HIDDevice *)windowController.window.contentViewController.representedObject;
		if (windowDevice == device)
		{
			wc = windowController;
			break;
		}
	}
	
	// Otherwise create a new window for that device.
	if (!wc)
	{
		NSStoryboard *sb = [NSStoryboard storyboardWithName:@"DeviceWindow" bundle:nil];
		wc = [sb instantiateInitialController];
		[_windowControllers addObject:wc];
		wc.window.contentViewController.representedObject = device;
		wc.window.delegate = self;
		[device open];
	}
	
	[wc showWindow:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
	@autoreleasepool
	{
		for (NSWindowController *wc in _windowControllers)
		{
			if (wc.window == notification.object)
			{
				NSLog(@"Closing window.");
				[(HIDDevice *)wc.window.contentViewController.representedObject close];
				[_windowControllers removeObject:wc];
				break;
			}
		}
		
	}
}

@end