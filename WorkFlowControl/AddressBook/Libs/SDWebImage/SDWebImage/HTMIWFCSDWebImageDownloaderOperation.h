/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "HTMIWFCSDWebImageDownloader.h"
#import "HTMIWFCSDWebImageOperation.h"

extern NSString *const HTMIWFCSDWebImageDownloadStartNotification;
extern NSString *const HTMIWFCSDWebImageDownloadReceiveResponseNotification;
extern NSString *const HTMIWFCSDWebImageDownloadStopNotification;
extern NSString *const HTMIWFCSDWebImageDownloadFinishNotification;

@interface HTMIWFCSDWebImageDownloaderOperation : NSOperation <HTMIWFCSDWebImageOperation>

/**
 * The request used by the operation's connection.
 */
@property (strong, nonatomic, readonly) NSURLRequest *request;


@property (assign, nonatomic) BOOL shouldDecompressImages;

/**
 * Whether the URL connection should consult the credential storage for authenticating the connection. `YES` by default.
 *
 * This is the value that is returned in the `NSURLConnectionDelegate` method `-connectionShouldUseCredentialStorage:`.
 */
@property (nonatomic, assign) BOOL shouldUseCredentialStorage;

/**
 * The credential used for authentication challenges in `-connection:didReceiveAuthenticationChallenge:`.
 *
 * This will be overridden by any shared credentials that exist for the username or password of the request URL, if present.
 */
@property (nonatomic, strong) NSURLCredential *credential;

/**
 * The HTMIWFCSDWebImageDownloaderOptions for the receiver.
 */
@property (assign, nonatomic, readonly) HTMIWFCSDWebImageDownloaderOptions options;

/**
 * The expected size of data.
 */
@property (assign, nonatomic) NSInteger expectedSize;

/**
 * The response returned by the operation's connection.
 */
@property (strong, nonatomic) NSURLResponse *response;

/**
 *  Initializes a `HTMIWFCSDWebImageDownloaderOperation` object
 *
 *  @see HTMIWFCSDWebImageDownloaderOperation
 *
 *  @param request        the URL request
 *  @param options        downloader options
 *  @param progressBlock  the block executed when a new chunk of data arrives. 
 *                        @note the progress block is executed on a background queue
 *  @param completedBlock the block executed when the download is done. 
 *                        @note the completed block is executed on the main queue for success. If errors are found, there is a chance the block will be executed on a background queue
 *  @param cancelBlock    the block executed if the download (operation) is cancelled
 *
 *  @return the initialized instance
 */
- (id)initWithRequest:(NSURLRequest *)request
              options:(HTMIWFCSDWebImageDownloaderOptions)options
             progress:(HTMIWFCSDWebImageDownloaderProgressBlock)progressBlock
            completed:(HTMIWFCSDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(SDWebImageNoParamsBlock)cancelBlock;

@end
