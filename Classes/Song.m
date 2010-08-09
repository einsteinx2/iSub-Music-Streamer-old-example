//
//  Song.m
//  iSub
//
//  Created by Ben Baron on 2/28/10.
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

#import "Song.h"


@implementation Song

@synthesize title, songId, artist, album, genre, coverArtId, path;
@synthesize duration, bitRate, track, year, size;


-(void) encodeWithCoder: (NSCoder *) encoder
{
	[encoder encodeObject: title];
	[encoder encodeObject: songId];
	[encoder encodeObject: artist];
	[encoder encodeObject: album];
	[encoder encodeObject: genre];
	[encoder encodeObject: coverArtId];
	[encoder encodeObject: path];
	[encoder encodeObject: duration];
	[encoder encodeObject: bitRate];
	[encoder encodeObject: track];
	[encoder encodeObject: year];
	[encoder encodeObject: size];
}


-(id) initWithCoder: (NSCoder *) decoder
{
	title = [[decoder decodeObject] retain];
	songId = [[decoder decodeObject] retain];
	artist = [[decoder decodeObject] retain];
	album = [[decoder decodeObject] retain];
	genre = [[decoder decodeObject] retain];
	coverArtId = [[decoder decodeObject] retain];
	path = [[decoder decodeObject] retain];
	duration = [[decoder decodeObject] retain];
	bitRate = [[decoder decodeObject] retain];
	track = [[decoder decodeObject] retain];
	year = [[decoder decodeObject] retain];
	size = [[decoder decodeObject] retain];
	
	return self;
}


- (void) dealloc {
	
	[title release];
	[songId release];
	[artist release];
	[album release];
	[genre release];
	[coverArtId release];
	[path release];
	[duration release];
	[bitRate release];
	[track release];
	[year release];
	[size release];
 	[super dealloc];
}

@end
