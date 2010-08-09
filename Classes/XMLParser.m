//
//  XMLParser.m
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

#import "XMLParser.h"
#import "iSubAppDelegate.h"
#import "Index.h"
#import "Artist.h"
#import "Album.h"
#import "Song.h"

@implementation XMLParser


- (XMLParser *) initXMLParser 
{
	[super init];
	
	appDelegate = (iSubAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	return self;
}


- (void) subsonicErrorCode:(NSString *)errorCode message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict 
{
	if(appDelegate.parseState == @"artists")
	{
		if([elementName isEqualToString:@"error"])
		{
			[self subsonicErrorCode:[attributeDict objectForKey:@"code"] message:[attributeDict objectForKey:@"message"]];
		}
		else if([elementName isEqualToString:@"indexes"]) 
		{
			//Initialize the arrays and lookup dictionaries.
			if (appDelegate.listOfArtists)
				[appDelegate.listOfArtists release];
			if (appDelegate.dictOfArtists)
				[appDelegate.dictOfArtists release];
			if (appDelegate.indexes)
				[appDelegate.indexes release];
			appDelegate.listOfArtists = [[NSMutableArray alloc] init];
			appDelegate.dictOfArtists = [[NSMutableDictionary alloc] init];
			appDelegate.indexes = [[NSMutableArray alloc] init];
		}
		else if([elementName isEqualToString:@"index"]) 
		{
			//Initialize the Index.
			anIndex = [[Index alloc] init];
		
			//Initialize the Artist array for this section
			appDelegate.artistsArray = [[NSMutableArray alloc] init];
		
			//Extract the attribute here.
			anIndex.name = [attributeDict objectForKey:@"name"];
		}
		else if([elementName isEqualToString:@"artist"]) 
		{
			//Initialize the Artist.
			anArtist = [[Artist alloc] init];
	
			//Extract the attribute here.
			anArtist.name = [attributeDict objectForKey:@"name"];
			anArtist.artistId = [attributeDict objectForKey:@"id"];
			
			//Add artist object to lookup dictionary
			if (![anArtist.name isEqualToString:@".AppleDouble"])
				[appDelegate.dictOfArtists setValue:anArtist.artistId forKey:anArtist.name];
		}
	}
	else if(appDelegate.parseState == @"albums")
	{
		if([elementName isEqualToString:@"error"])
		{
			[self subsonicErrorCode:[attributeDict objectForKey:@"code"] message:[attributeDict objectForKey:@"message"]];
		}
		else if([elementName isEqualToString:@"directory"]) 
		{
			//Initialize the arrays and lookup dictionaries.
			if (appDelegate.listOfAlbums)
				[appDelegate.listOfAlbums release];
			if (appDelegate.dictOfAlbums)
				[appDelegate.dictOfAlbums release];
			if (appDelegate.listOfSongs)
				[appDelegate.listOfSongs release];
			if (appDelegate.dictOfSongs)
				[appDelegate.dictOfSongs release];
			appDelegate.listOfAlbums = [[NSMutableArray alloc] init];
			appDelegate.dictOfAlbums = [[NSMutableDictionary alloc] init];
			appDelegate.listOfSongs = [[NSMutableArray alloc] init];
			appDelegate.dictOfSongs = [[NSMutableDictionary alloc] init];
		}
		else if([elementName isEqualToString:@"child"]) 
		{
			if ([[attributeDict objectForKey:@"isDir"] isEqualToString:@"true"])
			{
				//Initialize the Artist.
				anAlbum = [[Album alloc] init];
				appDelegate.isDir = YES;
			
				//Extract the attribute here.
				anAlbum.title = [attributeDict objectForKey:@"title"];
				anAlbum.albumId = [attributeDict objectForKey:@"id"];
				if([attributeDict objectForKey:@"coverArt"])
					anAlbum.coverArtId = [attributeDict objectForKey:@"coverArt"];
				
				//Add album object to lookup dictionary
				//NSLog(@"%i %@", [anAlbum.title length], [anAlbum.title substringFromIndex:1]);
				if (![anAlbum.title isEqualToString:@".AppleDouble"])
					[appDelegate.dictOfAlbums setValue:anAlbum forKey:anAlbum.title];
			}
			else
			{
				//Initialize the Song.
				aSong = [[Song alloc] init];
				appDelegate.isDir = NO;
				
				//Extract the attributes here.
				aSong.title = [attributeDict objectForKey:@"title"];
				aSong.songId = [attributeDict objectForKey:@"id"];
				aSong.artist = [attributeDict objectForKey:@"artist"];
				if([attributeDict objectForKey:@"album"])
					aSong.album = [attributeDict objectForKey:@"album"];
				if([attributeDict objectForKey:@"genre"])
					aSong.genre = [attributeDict objectForKey:@"genre"];
				if([attributeDict objectForKey:@"coverArt"])
					aSong.coverArtId = [attributeDict objectForKey:@"coverArt"];
				aSong.path = [attributeDict objectForKey:@"path"];
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				if([attributeDict objectForKey:@"duration"])
					aSong.duration = [numberFormatter numberFromString:[attributeDict objectForKey:@"duration"]];
				if([attributeDict objectForKey:@"bitRate"])
					aSong.bitRate = [numberFormatter numberFromString:[attributeDict objectForKey:@"bitRate"]];
				if([attributeDict objectForKey:@"track"])
					aSong.track = [numberFormatter numberFromString:[attributeDict objectForKey:@"track"]];
				if([attributeDict objectForKey:@"year"])
					aSong.year = [numberFormatter numberFromString:[attributeDict objectForKey:@"year"]];
				aSong.size = [numberFormatter numberFromString:[attributeDict objectForKey:@"size"]];
					
				//Add song object to lookup dictionary
				[appDelegate.dictOfSongs setValue:aSong forKey:aSong.title];
					
				//Release the memory
				[numberFormatter release];
			}
		}
	}
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{ 
	if(!currentElementValue) 
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if(appDelegate.parseState == @"artists")
	{
		if([elementName isEqualToString:@"artist"]) 
		{
			if (![anArtist.name isEqualToString:@".AppleDouble"])
				[appDelegate.artistsArray addObject:anArtist.name];
			[anArtist release];
		}
		else if([elementName isEqualToString:@"index"]) 
		{
			[appDelegate.indexes addObject:anIndex.name];
			NSDictionary *artistsDict = [NSDictionary dictionaryWithObject:appDelegate.artistsArray forKey:@"Artists"];
			[appDelegate.listOfArtists addObject:artistsDict];
			[anIndex release];
			[appDelegate.artistsArray release];
		}
		else if([elementName isEqualToString:@"indexes"])
		{
		
		}
	}
	else if(appDelegate.parseState == @"albums")
	{
		if([elementName isEqualToString:@"child"]) 
		{
			if (appDelegate.isDir)
			{
				if (![anAlbum.title isEqualToString:@".AppleDouble"])
					[appDelegate.listOfAlbums addObject:[anAlbum.title copy]];
				[anAlbum release];
			}
			else
			{
				[appDelegate.listOfSongs addObject:[aSong.title copy]];
				[aSong release];
			}
		}
		else if([elementName isEqualToString:@"directory"])
		{
			[appDelegate.albumListCache setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:appDelegate.listOfAlbums, appDelegate.dictOfAlbums, appDelegate.listOfSongs, appDelegate.dictOfSongs, nil]] forKey:appDelegate.currentId];
		}
	}
}


- (void) dealloc 
{
	[currentElementValue release];
	[super dealloc];
}

@end
