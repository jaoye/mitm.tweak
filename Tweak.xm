#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <fishhook.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

static NSString *mitmDirectory;

/**
 * Remove cert pinning
 **/
%hook NIATrustedCertificatesAuthenticator

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

%end

/*
	Define the new SecTrustEvaluate function
*/
static OSStatus(*original_SecTrustEvaluate)(SecTrustRef trust, SecTrustResultType *result);
OSStatus new_SecTrustEvaluate(SecTrustRef trust, SecTrustResultType *result)
{
	*result = kSecTrustResultProceed;
	return errSecSuccess;
}

//////////////////////

/**
 * Hook network calls
 **/

%hook __NSCFURLSession

- (id)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSString* host = [request URL].host;
    
    if ([host containsString:@"pgorelease.nianticlabs.com"])
    {
		NSData* body = request.HTTPBody;

		long long timestamp = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
		NSString *fileName = [NSString stringWithFormat:@"%lld.req.raw.bin", timestamp];
		NSLog(@"[mitm] Save to file: %@", fileName);

		NSString *fileWithPath = [NSString stringWithFormat:@"%@/%@", mitmDirectory, fileName];

		[body writeToFile:fileWithPath atomically:NO];

        void (^hacked)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error)
        {
			NSString *resFileName = [NSString stringWithFormat:@"%lld.res.raw.bin", timestamp];
			NSString *resFileWithPath = [NSString stringWithFormat:@"%@/%@", mitmDirectory, resFileName];
			[data writeToFile:resFileWithPath atomically:NO];
			
            // Invoke the original handler
            completionHandler(data, response, error);
        };
        
        // Call the hacked handler
        return %orig(request, hacked);
	}
    
    return %orig(request, completionHandler);
}

%end

////

%ctor {
	NSLog(@"[mitm] Pokemon Go Tweak Initializing...");

	// hook for ssl pinning
	rebind_symbols((struct rebinding[1]){
		{"SecTrustEvaluate", (void *)new_SecTrustEvaluate, (void **)&original_SecTrustEvaluate}
	}, 1);

	// todo: actually handle error :)
	NSError *error = nil;

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documents = [paths objectAtIndex:0];

	// 

	unsigned long slide = _dyld_get_image_vmaddr_slide(0);
	unsigned long pSend = slide + 0x7c9914;
	Dl_info symbolInfo;
	if (dladdr((void *)pSend, &symbolInfo)) {
		NSLog(@"[mitm] dladdr name == %s", symbolInfo.dli_sname);
	} else {
		NSLog(@"[mitm] dladdr == 0");
	}

	//

	NSLog(@"[mitm] Clean old directories");
	NSCalendar *cal = [NSCalendar currentCalendar];    
	NSDate *someDaysAgo = [cal dateByAddingUnit:NSCalendarUnitDay 
											value:-3
											toDate:[NSDate date] 
											options:0];

	NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documents error:&error];
	for (NSString *folder in directoryContents) {
		if ([folder hasPrefix:@"mitm."]) {
			long long timestamp = [[folder substringFromIndex:5] longLongValue];
			NSDate *mitmdate = [NSDate dateWithTimeIntervalSince1970:(long long)(timestamp/1000)];

			if ([mitmdate compare:someDaysAgo] == NSOrderedAscending) {
				NSString *oldFolder = [documents stringByAppendingPathComponent:folder];
				NSLog(@"[mitm] Session too old, deleting %@", oldFolder);
				[[NSFileManager defaultManager] removeItemAtPath:oldFolder error:nil];
			}
		}
	}

	long long timestamp = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
	NSString *dirname = [NSString stringWithFormat:@"/mitm.%lld", timestamp];

	NSLog(@"[mitm] Initializing log writer(s) to %@", dirname);
	
	mitmDirectory = [documents stringByAppendingPathComponent:dirname];
	if (![[NSFileManager defaultManager] fileExistsAtPath:mitmDirectory]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:mitmDirectory
			withIntermediateDirectories:NO
			attributes:nil
			error:&error];
	}

	NSLog(@"[mitm] Init OK.");
}