//
//  iSubAppDelegate.h
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

@class Reachability, iPhoneStreamingPlayerViewController, SettingsViewController, AudioStreamer, Index, Artist, Album, Song;

@interface iSubAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
	IBOutlet UIImageView *background;
    UINavigationController *navigationController;
	SettingsViewController *settingsViewController;
	
	Reachability *wwanReach;
    Reachability *wifiReach;
	BOOL isReachabilityAlertShowing;
	
	NSString *defaultUrl;
	NSString *defaultUserName;
	NSString *defaultPassword;
	NSString *cachedIP;
	NSInteger cachedIPHour;
	
	AudioStreamer *streamer;
	double streamerProgress;
	NSTimer *progressUpdateTimer;
	NSInteger repeatMode;
	BOOL isShuffle;
	BOOL isPlaying;
	float seekTime;
		
	NSMutableArray *listOfArtists;
	NSMutableDictionary *dictOfArtists;
	NSMutableArray *indexes;
	NSMutableArray *artistsArray;
	Artist *artistObject;
	
	NSMutableArray *listOfAlbums;
	NSMutableDictionary *dictOfAlbums;
	NSMutableArray *albumsArray;
	Album *albumObject;
	BOOL isDir;
	BOOL hasSubdirs;
	NSString *subItemId;
	NSMutableDictionary *coverArtCache;
	NSMutableDictionary *albumListCache;
	NSString *currentId;
	
	NSMutableArray *listOfSongs;
	NSMutableDictionary *dictOfSongs;
	NSMutableArray *songsArray;
	
	Song *currentSongObject;	
	NSMutableArray *currentPlaylist;
	NSMutableDictionary *currentPlaylistDict;
	NSMutableArray *shufflePlaylist;
	NSMutableDictionary *shufflePlaylistDict;
	UIImage *currentCoverArt;
	BOOL isNewSong;
	NSMutableDictionary *viewHistory;
	BOOL isTopLevel;
	
	NSURL *songUrl;
	NSURL *coverArtUrl;
	
	NSString *parseState; 
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) NSString *defaultUrl;
@property (nonatomic, retain) NSString *defaultUserName;
@property (nonatomic, retain) NSString *defaultPassword;
@property (nonatomic, retain) NSString *cachedIP;
@property NSInteger cachedIPHour;

@property (nonatomic, retain) AudioStreamer *streamer;
@property double streamerProgress;
@property NSInteger repeatMode;
@property BOOL isShuffle;
@property BOOL isPlaying;
@property float seekTime;

@property (nonatomic, retain) NSMutableArray *listOfArtists;
@property (nonatomic, retain) NSMutableDictionary *dictOfArtists;
@property (nonatomic, retain) NSMutableArray *indexes;
@property (nonatomic, retain) NSMutableArray *artistsArray;
@property (nonatomic, retain) Artist *artistObject;

@property (nonatomic, retain) NSMutableArray *listOfAlbums;
@property (nonatomic, retain) NSMutableDictionary *dictOfAlbums;
@property (nonatomic, retain) NSMutableArray *albumsArray;
@property (nonatomic, retain) Album *albumObject;
@property BOOL isDir;
@property BOOL hasSubdirs;
@property (nonatomic, retain) NSString *subItemId;
@property (nonatomic, retain) NSMutableDictionary *coverArtCache;
@property (nonatomic, retain) NSMutableDictionary *albumListCache;
@property (nonatomic, retain) NSString *currentId;

@property (nonatomic, retain) NSMutableArray *listOfSongs;
@property (nonatomic, retain) NSMutableDictionary *dictOfSongs;
@property (nonatomic, retain) NSMutableArray *songsArray;

@property (nonatomic, retain) Song *currentSongObject;
@property (nonatomic, retain) NSMutableArray *currentPlaylist;
@property (nonatomic, retain) NSMutableDictionary *currentPlaylistDict;
@property (nonatomic, retain) NSMutableArray *shufflePlaylist;
@property (nonatomic, retain) NSMutableDictionary *shufflePlaylistDict;
@property (nonatomic, retain) UIImage *currentCoverArt;
@property BOOL isNewSong;
@property (nonatomic, retain) NSMutableDictionary *viewHistory;
@property BOOL isTopLevel;

@property (nonatomic, retain) NSURL *songUrl;
@property (nonatomic, retain) NSURL *coverArtUrl;

@property (nonatomic, retain) NSString *parseState;

- (void)appInit;
- (void)saveDefaults;
- (NSString *)getBaseUrl:(NSString *)action;
- (BOOL)netReachability;
- (void)reachabilityChanged: (NSNotification *)note;
- (BOOL)isURLValid:(NSString *)url;
- (NSString *)getIPAddressForHost:(NSString *)theHost;
- (NSInteger)getHour;
- (void)createStreamer;
- (void)destroyStreamer;
- (void)playPauseSong;
- (void)nextSong;
- (void)nextSongAuto;
- (void)prevSong;
- (void)updateProgress:(NSTimer *)aNotification;

@end

