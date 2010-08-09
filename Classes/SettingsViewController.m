//
//  SettingsViewController.m
//  iSub
//
//  Created by Ben Baron on 3/3/10.
//  Copyright 2010 Ben Baron. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, 
//  are permitted provided that the following conditions are met:
//  
//  * Redistributions of source code must retain the above copyright notice, this 
//    list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the my name nor the names of my contributors may be used to endorse
//    or promote products derived from this software without specific prior written 
//    permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
//  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
//  DAMAGE.

#import "SettingsViewController.h"
#import "iSubAppDelegate.h"
#import "RootViewController.h"


@implementation SettingsViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	CGRect frame = self.view.frame;
	frame.origin.y = 20;
	self.view.frame = frame;
	
	appDelegate = (iSubAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if([defaults objectForKey:@"username"])
	{
		urlField.text = [defaults objectForKey:@"url"];
		usernameField.text = [defaults objectForKey:@"username"];
		passwordField.text = [defaults objectForKey:@"password"];
	}
}


- (BOOL) checkUrl:(NSString *)url
{
	if ([url length] < 7)
		return NO;
	if ([[url substringFromIndex:([url length] - 1)] isEqualToString:@"/"])
		return NO;
	if ([[url substringToIndex:7] isEqualToString:@"http://"])
		return YES;
	else
		return NO;
}


- (BOOL) checkUsername:(NSString *)username
{
	if ([username length] > 0)
		return YES;
	else
		return NO;
}

- (BOOL) checkPassword:(NSString *)password
{
	if ([password length] > 0)
		return YES;
	else
		return NO;
}


- (IBAction) saveButtonPressed:(id)sender
{
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	
	//BOOL success = [self checkUrl:urlField.text];
	if (![self checkUrl:urlField.text])
	{
		alert.message = @"The URL must be in the format: http://mywebsite.com or http://mywebsite.com:port";
		[alert show];
	}
	
	if (![self checkUsername:usernameField.text])
	{
		alert.message = @"Please enter a username";
		[alert show];
	}
	
	if (![self checkPassword:passwordField.text])
	{
		alert.message = @"Please enter a password";
		[alert show];
	}
	
	if ([self checkUrl:urlField.text] && [self checkUsername:usernameField.text] && [self checkPassword:passwordField.text])
	{
		// Check if the subsonic URL is valid by attempting to access the ping.view page, if it's not then display an alert and allow user to change settings if they want.
		// This is in case the user is, for instance, connected to a wifi network but does not have internet access or if the host url entered was wrong.
		if(![appDelegate isURLValid:[NSString stringWithFormat:@"%@/rest/ping.view", urlField.text]])
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Either the Subsonic URL is incorrect or you are connected to Wifi but do not have internet access." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		else
		{	
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:urlField.text forKey:@"url"];
			[defaults setObject:usernameField.text forKey:@"username"];
			[defaults setObject:passwordField.text forKey:@"password"];
			[defaults synchronize];
		
			appDelegate.defaultUrl = urlField.text;
			appDelegate.defaultUserName = usernameField.text;
			appDelegate.defaultPassword = passwordField.text;
			if ([[appDelegate.defaultUrl componentsSeparatedByString:@"."] count] == 1)
			{
				appDelegate.cachedIP = [appDelegate getIPAddressForHost:appDelegate.defaultUrl];
				appDelegate.cachedIPHour = [appDelegate getHour];
			}
				
			CGRect frame = self.view.frame;
			[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:.25];
				frame.origin.x = -320;
				self.view.frame = frame;
			[UIView commitAnimations];
		
			[appDelegate.window addSubview:[appDelegate.navigationController view]];
			RootViewController *rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
			[appDelegate.navigationController pushViewController:rootViewController animated:YES];
			[rootViewController release];
		}
	}
	[alert release];
}


// This dismisses the keyboard when the "done" button is pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[urlField resignFirstResponder];
	[usernameField resignFirstResponder];
	[passwordField resignFirstResponder];
	return YES;
}

// This dismisses the keyboard when any area outside the keyboard is touched
- (void) touchesBegan :(NSSet *) touches withEvent:(UIEvent *)event
{
	[urlField resignFirstResponder];
	[usernameField resignFirstResponder];
	[passwordField resignFirstResponder];
	[super touchesBegan:touches withEvent:event ];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
