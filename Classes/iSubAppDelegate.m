//
//  iSubAppDelegate.m
//  iSub
//
//  Created by Ben Baron on 2/27/10.
//  Copyright Ben Baron 2010. All rights reserved.
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

#import "iSubAppDelegate.h"
#import "SettingsViewController.h"
#import "RootViewController.h"
#import "Reachability.h"
#import "AudioStreamer.h"
#import "XMLParser.h"
#import "Song.h"
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h> 
#include <netdb.h>
#include <arpa/inet.h>

@implementation iSubAppDelegate

@synthesize window, navigationController;
@synthesize streamer, streamerProgress, repeatMode, isShuffle, isPlaying, seekTime;
@synthesize defaultUrl, defaultUserName, defaultPassword, cachedIP, cachedIPHour;
@synthesize listOfArtists, dictOfArtists, indexes, artistsArray, artistObject;
@synthesize listOfAlbums, dictOfAlbums, albumsArray, albumObject, isDir, hasSubdirs, subItemId, coverArtCache, albumListCache, currentId;
@synthesize listOfSongs, dictOfSongs, songsArray;
@synthesize currentSongObject, currentPlaylist, currentPlaylistDict, shufflePlaylist, shufflePlaylistDict, currentCoverArt, isNewSong, viewHistory, isTopLevel;
@synthesize songUrl, coverArtUrl;
@synthesize parseState;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{   
	//
	// Uncomment to redirect the console output to a log file
	//
	//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    //freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
	

	wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifer];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
		
	if (![self netReachability])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must be connected to the internet." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else 
	{
		[self appInit];
	}
}


- (void)applicationWillResignActive:(UIApplication*)application
{
	//NSLog(@"applicationWillResignActive called");
	
	//NSLog(@"applicationWillResignActive finished");
}


- (void)applicationDidBecomeActive:(UIApplication*)application
{
	//NSLog(@"applicationDidBecomeActive called");
	
	//NSLog(@"applicationDidBecomeActive finished");
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	[self saveDefaults];
}


- (void)appInit
{
	isReachabilityAlertShowing = NO;
	hasSubdirs = NO;
	subItemId = nil;
	repeatMode = 0;
	isShuffle = NO;
	isNewSong = NO;
	coverArtCache = [[NSMutableDictionary alloc] init];
	albumListCache = [[NSMutableDictionary alloc] init];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([defaults objectForKey:@"username"])
	{
		defaultUrl = [defaults objectForKey:@"url"];
		defaultUserName = [defaults objectForKey:@"username"];
		defaultPassword = [defaults objectForKey:@"password"];
		
		// Check if the subsonic URL is valid by attempting to access the ping.view page, 
		// if it's not then display an alert and allow user to change settings if they want.
		// This is in case the user is, for instance, connected to a wifi network but does not 
		// have internet access or if the host url entered was wrong.
		if(![self isURLValid:[NSString stringWithFormat:@"%@/rest/ping.view", defaultUrl]])
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Either the Subsonic URL is incorrect or you are connected to Wifi but do not have internet access." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Settings", nil];
			[alert show];
			[alert release];
		}
		else
		{	
			// First check to see if the user used an IP address or a hostname. If they used a hostname,
			// cache the IP of the host so that it doesn't need to be resolved for every call to the API
			if ([[defaultUrl componentsSeparatedByString:@"."] count] == 1)
			{
				cachedIP = [[NSString alloc] initWithString:[self getIPAddressForHost:defaultUrl]];
				cachedIPHour = [self getHour];
			}
			
			// Recover current state if player was interrupted
			if([[defaults objectForKey:@"recover"] isEqualToString:@"YES"])
			{
				if([[defaults objectForKey:@"isShuffle"] isEqualToString:@"YES"])
				{
					isShuffle = YES;
					shufflePlaylist = [defaults objectForKey:@"shufflePlaylist"];
					shufflePlaylistDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"shufflePlaylistDict"]] retain];
					currentPlaylist = [defaults objectForKey:@"currentPlaylist"];
					currentPlaylistDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentPlaylistDict"]] retain];
				}
				else 
				{
					isShuffle = NO;
					currentPlaylist = [defaults objectForKey:@"currentPlaylist"];
					currentPlaylistDict = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentPlaylistDict"]] retain];
				}
				repeatMode = [[defaults objectForKey:@"repeatMode"] integerValue];
				currentSongObject = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentSongObject"]] retain];
				currentCoverArt = [[UIImage alloc] initWithData:[defaults objectForKey:@"currentCoverArt"]];
				seekTime = [[defaults objectForKey:@"seekTime"] floatValue];
				isPlaying = YES;
				
				[defaults setObject:@"NO" forKey:@"recover"];
				[defaults synchronize];
				
				NSString *urlString = [self getBaseUrl:@"stream.view"];
				NSString *urlString2 = [urlString stringByAppendingString:[currentSongObject songId]];
				songUrl = [[NSURL alloc] initWithString:urlString2];
				[self createStreamer];
				[streamer startWithOffsetInSecs:(UInt32) seekTime];
			}
			else
			{
				// If starting from scratch, initialize the arrays and dictionaries.
				//listOfAlbums = [[NSMutableArray alloc] init];
				//dictOfAlbums = [[NSMutableDictionary alloc] init];
				//listOfSongs = [[NSMutableArray alloc] init];
				//dictOfSongs = [[NSMutableDictionary alloc] init]; 
			}

			[window addSubview:[navigationController view]];
			[window makeKeyAndVisible];
		}
	}
	else
	{
		settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
		[window addSubview:[settingsViewController view]];
		[window makeKeyAndVisible];
	}	
}


#pragma mark -
#pragma mark Helper methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
		settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
		[window addSubview:[settingsViewController view]];
		[window makeKeyAndVisible];
    }
}


- (BOOL)isURLValid:(NSString *)url
{
	NSError *error = [[[NSError alloc] init] autorelease];
	NSURLResponse *response = [[[NSURLResponse alloc] init] autorelease];
	[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0] returningResponse:&response error:&error];
	
	if(error.code)
	{
		//[connection release];
		//[response release];
		return NO;
	}
	else
	{
		//[connection release];
		//[response release];
		return YES;
	}
}


- (void)saveDefaults
{
	if(isPlaying)
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if(isShuffle)
		{
			[defaults setObject:@"YES" forKey:@"isShuffle"];
			[defaults setObject:shufflePlaylist forKey:@"shufflePlaylist"];
			[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:shufflePlaylistDict] forKey:@"shufflePlaylistDict"];
			[defaults setObject:currentPlaylist forKey:@"currentPlaylist"];
			[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:currentPlaylistDict] forKey:@"currentPlaylistDict"];
		}
		else 
		{
			[defaults setObject:@"NO" forKey:@"isShuffle"];
			[defaults setObject:currentPlaylist forKey:@"currentPlaylist"];
			[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:currentPlaylistDict] forKey:@"currentPlaylistDict"];
		}
		[defaults setObject:[NSString stringWithFormat:@"%i", repeatMode] forKey:@"repeatMode"];
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:currentSongObject] forKey:@"currentSongObject"];
		NSData *artData = UIImageJPEGRepresentation(currentCoverArt, 1.0);
		[defaults setObject:artData forKey:@"currentCoverArt"];
		[streamer progress];
		[defaults setObject:[NSString stringWithFormat:@"%f", (seekTime + streamerProgress)] forKey:@"seekTime"];
		[defaults setObject:@"YES" forKey:@"recover"];
		[defaults synchronize];
	}
}


- (BOOL)netReachability
{
	if ([wifiReach currentReachabilityStatus] == NotReachable)
		return NO;

	return YES;
}


- (void)reachabilityChanged: (NSNotification *)note
{

}


- (NSString *) getIPAddressForHost: (NSString *) theHost 
{
	NSArray *subStrings = [theHost componentsSeparatedByString:@"://"];
	theHost = [subStrings objectAtIndex:1];
	subStrings = [theHost componentsSeparatedByString:@":"];
	theHost = [subStrings objectAtIndex:0];
	
	struct hostent *host = gethostbyname([theHost UTF8String]);
	if (host == NULL) 
	{
		herror("resolv");
		return NULL;
	}
	
	struct in_addr **list = (struct in_addr **)host->h_addr_list;
	NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0])];
	return addressString;
}


- (NSInteger) getHour
{
	// Get the time
	NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDate *date = [NSDate date];
	NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];

	// Turn the date into Integers
	//NSInteger year = [dateComponents year];
	//NSInteger month = [dateComponents month];
	//NSInteger day = [dateComponents day];
	//NSInteger hour = [dateComponents hour];
	//NSInteger min = [dateComponents minute];
	//NSInteger sec = [dateComponents second];
	
	[calendar release];
	return [dateComponents hour];
}


#pragma mark -
#pragma mark Music Streamer


- (NSString *)getBaseUrl:(NSString *)action
{
	NSString *urlString = [[[NSString alloc] init] autorelease];
	// If the user used a hostname, implement the IP address caching and create the urlstring
	if ([[defaultUrl componentsSeparatedByString:@"."] count] == 1)
	{
		// Check to see if it's been an hour since the last IP check. If it has, update the cached IP.
		if ([self getHour] > cachedIPHour)
		{
			cachedIP = [[NSString alloc] initWithString:[self getIPAddressForHost:defaultUrl]];
			cachedIPHour = [self getHour];
		}
	
		// Grab the http (or https for the future) and the port (if there is one)
		NSArray *subStrings = [defaultUrl componentsSeparatedByString:@":"];
		//NSString *urlString = [[[NSString alloc] init] autorelease];
		if ([subStrings count] == 2)
			urlString = [NSString stringWithFormat:@"%@://%@", [subStrings objectAtIndex:0], cachedIP];
		else if ([subStrings count] == 3)
			urlString = [NSString stringWithFormat:@"%@://%@:%@", [subStrings objectAtIndex:0], cachedIP, [subStrings objectAtIndex:2]];
	}
	else 
	{
		// If the user used an IP address, just use the defaultUrl as is.
		urlString = defaultUrl;
	}

	// Return the base URL
	if ([action isEqualToString:@"getIndexes.view"])
		return [NSString stringWithFormat:@"%@/rest/%@?u=%@&p=%@&v=1.1.0&c=iSub", urlString, action, defaultUserName, defaultPassword];
	else
		return [NSString stringWithFormat:@"%@/rest/%@?u=%@&p=%@&v=1.1.0&c=iSub&id=", urlString, action, defaultUserName, defaultPassword];
}


- (void)createStreamer
{
	
	[self destroyStreamer];
	
	streamer = [[AudioStreamer alloc] initWithURL:songUrl];
	
	progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
}


- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}


- (void)playPauseSong
{
	
	if ([streamer isPaused])
	{
		isPlaying = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"setPauseButtonImage" object:nil];
		[streamer start];
	}
	else if ([streamer isPlaying])
	{
		isPlaying = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"setPlayButtonImage" object:nil];
		[streamer pause];
	}
	else 
	{
		isPlaying = YES;
		seekTime = 0.0;
		[self createStreamer];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"setPauseButtonImage" object:nil];
		[streamer start];
	}
}

- (void)prevSong
{
	NSArray *playlist;
	NSDictionary *playlistDict;
	if(isShuffle)
	{
		playlist = [NSArray arrayWithArray:shufflePlaylist];
		playlistDict = [NSDictionary dictionaryWithDictionary:shufflePlaylistDict];
	}
	else
	{
		playlist = [NSArray arrayWithArray:currentPlaylist];
		playlistDict = [NSDictionary dictionaryWithDictionary:currentPlaylistDict];
	}
	
	NSInteger index = [playlist indexOfObject:[currentSongObject title]];
	index = index - 1;
	if (index >= 0)
	{
		NSString *prevSongTitle = [playlist objectAtIndex:index];
		
		currentSongObject = [playlistDict objectForKey:prevSongTitle];
		
		NSString *urlString = [self getBaseUrl:@"stream.view"];
		NSString *urlString2 = [urlString stringByAppendingString:[currentSongObject songId]];
		songUrl = [[NSURL alloc] initWithString:urlString2];
		
		[self playPauseSong];
		[self destroyStreamer];
		[self createStreamer];
		[self playPauseSong];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"setSongTitle" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"initSongInfo" object:nil];
	}
}


- (void)nextSong
{
	NSArray *playlist;
	NSDictionary *playlistDict;
	if(isShuffle)
	{
		playlist = [NSArray arrayWithArray:shufflePlaylist];
		playlistDict = [NSDictionary dictionaryWithDictionary:shufflePlaylistDict];
	}
	else
	{
		playlist = [NSArray arrayWithArray:currentPlaylist];
		playlistDict = [NSDictionary dictionaryWithDictionary:currentPlaylistDict];
	}

	NSInteger index = [playlist indexOfObject:[currentSongObject title]];
	index = index + 1;
	if (index <= ([playlist count] - 1))
	{
		NSString *nextSongTitle = [playlist objectAtIndex:index];		
		currentSongObject = [playlistDict objectForKey:nextSongTitle];
	 
		NSString *urlString = [self getBaseUrl:@"stream.view"];
		NSString *urlString2 = [urlString stringByAppendingString:[currentSongObject songId]];
		songUrl = [[NSURL alloc] initWithString:urlString2];
	 
		[self playPauseSong];
		[self destroyStreamer];
		[self createStreamer];
		[self playPauseSong];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"setSongTitle" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"initSongInfo" object:nil];
	}	
	else
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPlayButtonImage) name:@"setPlayButtonImage" object:nil];
		[self destroyStreamer];
	}
}


- (void)nextSongAuto
{
	// If it's in regular play mode, then go to the next track.
	if(repeatMode == 0)
	{
		[self nextSong];
	}
	// If it's in repeat-one mode then just restart the streamer
	else if(repeatMode == 1)
	{
		[self playPauseSong];
		[self destroyStreamer];
		[self createStreamer];
		[self playPauseSong];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"setSongTitle" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"initSongInfo" object:nil];
	}
	// If it's in repeat-all mode then check if it's at the end of the playlist and start from the beginning, or just go to the next track.
	else if(repeatMode == 2)
	{
		NSInteger index = [currentPlaylist indexOfObject:[currentSongObject title]];
		index = index + 1;
		if (index <= ([currentPlaylist count] - 1))
			[self nextSong];
		else
		{
			NSArray *playlist;
			NSDictionary *playlistDict;
			if(isShuffle)
			{
				playlist = [NSArray arrayWithArray:shufflePlaylist];
				playlistDict = [NSDictionary dictionaryWithDictionary:shufflePlaylistDict];
			}
			else
			{
				playlist = [NSArray arrayWithArray:currentPlaylist];
				playlistDict = [NSDictionary dictionaryWithDictionary:currentPlaylistDict];
			}			
			
			NSString *firstSongTitle = [playlist objectAtIndex:0];		
			currentSongObject = [playlistDict objectForKey:firstSongTitle];
			
			NSString *urlString = [self getBaseUrl:@"stream.view"];
			NSString *urlString2 = [urlString stringByAppendingString:[currentSongObject songId]];
			songUrl = [[NSURL alloc] initWithString:urlString2];
			
			[self playPauseSong];
			[self destroyStreamer];
			[self createStreamer];
			[self playPauseSong];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"setSongTitle" object:nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"initSongInfo" object:nil];
		}
	}
}
		

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
	}
	else if ([streamer isPlaying])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"setPauseButtonImage" object:nil];
	}
	else if ([streamer isIdle])
	{
		[self nextSongAuto];
	}
}


- (void)updateProgress:(NSTimer *)updatedTimer
{
	// Post an "updateProgress" notification so that SongInfoViewController can update it's progress UISlider.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"updateProgress" object:nil];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[listOfArtists release];
	[dictOfArtists release];
	[indexes release];
	[artistsArray release];
	[artistObject release];
	
	[listOfAlbums release];
	[dictOfAlbums release];
	[albumsArray release];
	[albumObject release];
	[coverArtCache release];
	[albumListCache release];
	
	[listOfSongs release];
	[dictOfSongs release];
	[songsArray release];
	
	[currentSongObject release];
	[currentCoverArt release];
	[currentPlaylist release];
	[viewHistory release];
	
	[parseState release]; 
	
	[navigationController release];
	[window release];
	
	[super dealloc];
}


@end

