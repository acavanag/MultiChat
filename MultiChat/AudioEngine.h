//
//  AudioEngine.h
//  
//
//  Created by Andrew Cavanagh on 7/3/15.
//
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@protocol AudioEngineDelegateProtocol <NSObject>
- (void)didOutputAudioBuffer:(NSData * __nonnull)audioBuffer;
@end

@interface AudioEngine : NSObject
@property (nonatomic, weak, nullable) id<AudioEngineDelegateProtocol> delegate;
+ (nonnull instancetype)sharedInstance;
- (void)playBuffer:(NSData * __nonnull)data;
- (void)startRecording;
- (void)stopRecording;
- (void)startEngine;
- (void)stopEngine;
@end
