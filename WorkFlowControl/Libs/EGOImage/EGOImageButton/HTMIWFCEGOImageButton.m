//
//  HTMIWFCEGOImageButton.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 9/30/09.
//  Copyright (c) 2009-2010 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "HTMIWFCEGOImageButton.h"

//气泡Badge
//#import "WZLBadgeImport.h"

#import "UIImage+HTMIWFCWM.h"


@implementation HTMIWFCEGOImageButton
@synthesize imageURL, placeholderImage, delegate;

//wlq add
- (void)showBadge:(NSString *)strCount{
    
//    int count = [strCount intValue];
//    
//    [self showBadgeWithStyle:WBadgeStyleNumber value:count animationType:WBadgeAnimTypeNone];
//    self.badgeBgColor = [UIColor redColor];
//    self.badgeCenterOffset = CGPointMake(-5, 5);
//    self.badgeTextColor = [UIColor whiteColor];
//    self.clipsToBounds = NO;
}

- (id)initWithPlaceholderImage:(UIImage*)anImage {
	return [self initWithPlaceholderImage:anImage delegate:nil];	
}

- (id)initWithPlaceholderImage:(UIImage*)anImage delegate:(id<HTMIWFCEGOImageButtonDelegate>)aDelegate {
	if((self = [super initWithFrame:CGRectZero])) {
		self.placeholderImage = anImage;
		self.delegate = aDelegate;
		[self setImage:self.placeholderImage forState:UIControlStateNormal];
	}
	
	return self;
}

- (void)setImageURL:(NSURL *)aURL {
	if(imageURL) {
		[[HTMIWFCEGOImageLoader sharedImageLoader] removeObserver:self forURL:imageURL];
		[imageURL release];
		imageURL = nil;
	}
	
	if(!aURL) {
		[self setImage:self.placeholderImage forState:UIControlStateNormal];
		imageURL = nil;
		return;
	} else {
		imageURL = [aURL retain];
	}
	
	UIImage* anImage = [[HTMIWFCEGOImageLoader sharedImageLoader] imageForURL:aURL shouldLoadWithObserver:self];
 
    //将图片切成圆角的
    UIImage  * image = [anImage roundedCornerImageWithCornerRadius:20];
	
	if(image) {
		[self setImage:image forState:UIControlStateNormal];
	} else {
		[self setImage:self.placeholderImage forState:UIControlStateNormal];
	}
}

#pragma mark -
#pragma mark Image loading

- (void)cancelImageLoad {
	[[HTMIWFCEGOImageLoader sharedImageLoader] cancelLoadForURL:self.imageURL];
	[[HTMIWFCEGOImageLoader sharedImageLoader] removeObserver:self forURL:self.imageURL];
}

- (void)imageLoaderDidLoad:(NSNotification*)notification {
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;
	
	UIImage* anImage = [[notification userInfo] objectForKey:@"image"];
	[self setImage:anImage forState:UIControlStateNormal];
	[self setNeedsDisplay];
	
	if([self.delegate respondsToSelector:@selector(imageButtonLoadedImage:)]) {
		[self.delegate imageButtonLoadedImage:self];
	}	
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;
	
	if([self.delegate respondsToSelector:@selector(imageButtonFailedToLoadImage:error:)]) {
		[self.delegate imageButtonFailedToLoadImage:self error:[[notification userInfo] objectForKey:@"error"]];
	}
}

#pragma mark -
- (void)dealloc {
	[[HTMIWFCEGOImageLoader sharedImageLoader] removeObserver:self];
	
	self.imageURL = nil;
	self.placeholderImage = nil;
    [super dealloc];
}

@end
