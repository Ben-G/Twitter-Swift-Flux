//
//  AVFoundation+PromiseKit.h
//
//  Created by Matthew Loseke on 6/21/14.
//

#import <AVFoundation/AVAudioSession.h>
#import <PromiseKit/fwd.h>


@class PMKPromise;

@interface AVAudioSession (PromiseKit)

- (PMKPromise *)promiseForRequestRecordPermission PMK_DEPRECATED("Use -requestRecordPermission");
- (PMKPromise *)requestRecordPermission;

@end
