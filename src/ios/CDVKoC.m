#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "CDVKoC.h"

@implementation CDVKoC

static NSDictionary* _login(NSString*, NSString*);

- (void)login:(CDVInvokedUrlCommand*)command {
	[self.commandDelegate runInBackground:^{
		NSString* username = [command.arguments objectAtIndex:0];
		NSString* password = [command.arguments objectAtIndex:1];

		NSDictionary* loginResult = _login(username, password);

		CDVPluginResult* pluginResult = [ CDVPluginResult
		                                  resultWithStatus:CDVCommandStatus_OK
		                                  messageAsDictionary:loginResult
		                                ];

		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}];
}

static NSDictionary* _login(NSString* username, NSString* password) {
    BOOL success = false;
    NSDictionary *jsonObj = [ [NSDictionary alloc]
                              initWithObjectsAndKeys:
                                 "Error: TODO", @"error",
                                 succes, @"success",
                                 nil
                            ];
    return jsonObj;
}

@end