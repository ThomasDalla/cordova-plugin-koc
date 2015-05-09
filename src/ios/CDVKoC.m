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
	
	NSMutableDictionary *dict = [NSMutableDictionary
                             dictionaryWithDictionary:@{
                                 @"success" : [NSNumber numberWithBool:NO],
                                 @"error" : @"Unknown Error Occurred",
                             }];
	
	@try{
	
		NSString *url = @"http://www.kingsofchaos.com/login.php";
		NSURL* loginUrl = [NSURL URLWithString:url];
		NSString *post = [NSString stringWithFormat:@"usrname=%@&peeword=%@",username,password];
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
		NSMutableURLRequest *request = [ [NSMutableURLRequest alloc]
										  initWithURL:loginUrl
										  cachePolicy:NSURLRequestReloadIgnoringCacheData
										  timeoutInterval:10
										];
		[request setHTTPMethod:@"POST"]; 
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		//[request setValue:@"country=XO; gsScrollPos=;" forHTTPHeaderField:@"Cookie"];
		[request setValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
		[request setValue:url forHTTPHeaderField:@"Referer"];
		[request setValue:@"en-US" forHTTPHeaderField:@"Content-Language"];
		[request setHTTPBody:postData];
		
		NSURLResponse * response = nil;
		NSError * error = nil;
		NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
			
		if (error == nil)
		{
			NSURL* url = [(NSHTTPURLResponse *)response URL];
			NSString *path = [url absoluteString];
			
			NSHTTPCookieStorage* sharedCookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
			NSArray* cookies = [sharedCookies cookiesForURL:url];
			
			for (NSHTTPCookie *cookie in cookies) {
				if([cookie.name isEqualToString:@"koc_session"])
				{
					dict[@"session"] = cookie.value;
				}
			}
			
			if ([path rangeOfString:@"bansuspend.php"].location != NSNotFound) {
				[dict setObject:[NSNumber numberWithBool:NO] forKey:@"success"];
				[dict setObject:@"You have been banned!"  forKey:@"error"];
			}
			else if ([path rangeOfString:@"newage.php"].location != NSNotFound) {
				[dict setObject:[NSNumber numberWithBool:NO]                  forKey:@"success"];
				[dict setObject:@"Login from a PC to start the new age!"  forKey:@"error"];
			}
			else if ([path rangeOfString:@"index.php"].location != NSNotFound) {
				[dict setObject:[NSNumber numberWithBool:NO]     forKey:@"success"];
				[dict setObject:@"Error with the session..."  forKey:@"error"];
			}
			else if ([path rangeOfString:@"error.php"].location != NSNotFound) {
				[dict setObject:[NSNumber numberWithBool:NO]     forKey:@"success"];
				[dict setObject:@"Invalid Username/Password"  forKey:@"error"];
			}
			else if ([path rangeOfString:@"base.php"].location != NSNotFound) {
				[dict setObject:[NSNumber numberWithBool:YES]  forKey:@"success"];
				[dict removeObjectForKey:@"error"];
				NSURL *setResUrl = [NSURL URLWithString:@"http://www.kingsofchaos.com/setres.php?width=1280&height=720"];
				NSMutableURLRequest *setResRequest = [[NSMutableURLRequest alloc] initWithURL:setResUrl];
				data = [NSURLConnection sendSynchronousRequest:setResRequest returningResponse:&response error:&error];
			}
			else {
				[dict setObject:[NSNumber numberWithBool:NO]     forKey:@"success"];
				[dict setObject:[NSString stringWithFormat:@"Unknown location: %@", path]  forKey:@"error"];
			}
		}
		else {
			[dict setObject:[NSNumber numberWithBool:NO]     forKey:@"success"];
			[dict setObject:@"Exception occurred"  forKey:@"error"];
			dict[ @"details" ] = [NSString stringWithFormat:@"%@", error];
		}
	}
    @catch (NSException *exception) {
		[dict setObject:[NSNumber numberWithBool:NO]     forKey:@"success"];
		[dict setObject:@"Connection Errors"  forKey:@"error"];
		dict[ @"details" ] = [NSString stringWithFormat:@"%@", exception.reason];
    }
	
    return dict;
}

@end