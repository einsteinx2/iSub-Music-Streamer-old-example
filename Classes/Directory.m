//
//  Directory.m
//  iSubTESTING
//
//  Created by Ben Baron on 2/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Directory.h"


@implementation Directory

@synthesize name;

- (void) dealloc {
	
	[name release];
	[super dealloc];
}

@end
