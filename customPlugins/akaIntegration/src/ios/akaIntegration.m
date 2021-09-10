/********* akaIntegration.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

#import <AkaCommon/AkaCommon.h>
#import <AkaMAP/AkaMap.h>
#import <Aka-mPulse/MPulse.h>

@interface akaIntegration : CDVPlugin {
	// Member variables go here.
}

- (void)echo:(CDVInvokedUrlCommand*)command;
- (void)printConfig:(CDVInvokedUrlCommand*)command;
- (void)printCache:(CDVInvokedUrlCommand*)command;
- (void)registerSegment:(CDVInvokedUrlCommand*)command;
- (void)startAction:(CDVInvokedUrlCommand*)command;
- (void)stopAction:(CDVInvokedUrlCommand*)command;
- (void)handleNotification:(CDVInvokedUrlCommand*)command;
@end

@implementation akaIntegration

- (void)pluginInitialize
{
	AkaCommon *akaCommon = [AkaCommon shared];
	akaCommon.debugConsoleEnabled = YES;
	[AkaCommon configure];

	[[AkaMap shared] setDebugConsoleLog:YES];

	[MPulse setDebug:YES];
}

- (void)echo:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult *pluginResult = nil;
	NSString* echo = [command.arguments objectAtIndex:0];

	if (echo != nil && [echo length] > 0) {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
	} else {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"nil or empty param"];
	}

	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)printConfig:(CDVInvokedUrlCommand*)command
{
	[[AkaMap shared] printCurrentConfiguration];

	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"config printed"];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)printCache:(CDVInvokedUrlCommand*)command
{
	[[AkaMap shared] printCache];

	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"cache printed"];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)registerSegment:(CDVInvokedUrlCommand*)command
{
	NSString *segmentsString = [command.arguments objectAtIndex:0];
	if (segmentsString == nil) {
		CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"nil segment param"];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		return ;
	}

	NSArray<NSString *> *segments = [segmentsString componentsSeparatedByString:@","];

	[[AkaMap shared] subscribeSegments:[NSSet setWithArray:segments]];

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"subscribed to new segments"];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)startAction:(CDVInvokedUrlCommand*)command
{
	NSString *actionName = [command.arguments objectAtIndex:0];
	if (actionName == nil || [actionName length] < 1) {
		CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"nil or empty actionName param"];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		return ;
	}


	MPulse *mPulseService = [MPulse sharedInstance];
	[mPulseService startActionWithName:actionName];

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"action started"];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stopAction:(CDVInvokedUrlCommand*)command
{
	MPulse *mPulseService = [MPulse sharedInstance];
	[mPulseService stopAction];

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"action stopped"];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)handleNotification:(CDVInvokedUrlCommand*)command
{
	NSDictionary *dictionary = [command.arguments objectAtIndex:0];
	if (dictionary == nil) {
		CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"nil or empty notification dictionary param"];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		return ;
	}

	BOOL mapHandledNotification = [[AkaCommon shared] didReceiveRemoteNotification:dictionary fetchCompletionHandler:^(UIBackgroundFetchResult result) {
		//already called by firebase
	}];

	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:mapHandledNotification];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
