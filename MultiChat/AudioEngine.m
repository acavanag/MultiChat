//
//  AudioEngine.m
//  
//
//  Created by Andrew Cavanagh on 7/3/15.
//
//

#import "AudioEngine.h"

@interface AudioEngine()
{
    BOOL recording;
}
@property (nonatomic, strong, nonnull) AVAudioEngine *audioEngine;
@property (nonatomic, strong, nonnull) AVAudioPlayerNode *playerNode;
@property (nonatomic, strong, nonnull) AVAudioFormat *audioFormat;
@end

//66148

static const int kBus = 0;
static const int kBufferSize = 8192;//4096;

@implementation AudioEngine

+ (nonnull instancetype)sharedInstance
{
    static AudioEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AudioEngine alloc] init];
        [sharedInstance setupAudioEngine];
    });
    return sharedInstance;
}

#pragma mark - Setup Audio Engine

- (void)configureAudioSession
{
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:0.1 error:&error];
    
    if (error) {
        NSLog(@"%@", [error description]);
    }
}

- (void)setupAudioEngine
{
    [self configureAudioSession];
    
    AVAudioEngine *audioEngine = [[AVAudioEngine alloc] init];
    
    AVAudioPlayerNode *playerNode = [[AVAudioPlayerNode alloc] init];
    [audioEngine attachNode:playerNode];
    
    AVAudioMixerNode *mixerNode = audioEngine.mainMixerNode;
    [audioEngine connect:playerNode to:mixerNode format:[mixerNode outputFormatForBus:kBus]];
    
    _audioFormat = [audioEngine.inputNode inputFormatForBus:kBus];
    
    [audioEngine prepare];
    
    _audioEngine = audioEngine;
    _playerNode = playerNode;
    recording = NO;
}

#pragma mark - Start / Stop [Public Interface]

- (void)startRecording
{
    if (!recording) {
        [_audioEngine.inputNode installTapOnBus:kBus
                                     bufferSize:kBufferSize
                                         format:[_audioEngine.inputNode inputFormatForBus:kBus]
                                          block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
                                              NSLog(@"%u", buffer.frameLength);
                                              processBuffer(buffer, when, (__bridge void *)(self));
                                          }];
        recording = YES;
    }
}

- (void)stopRecording
{
    if (recording) {
        [_audioEngine.inputNode removeTapOnBus:kBus];
        recording = NO;
    }
}

- (void)startEngine
{
    if (![self.audioEngine isRunning]) {
        NSError *error = nil;
        if (![self.audioEngine startAndReturnError:&error]) {
            NSLog(@"%@", [error description]);
        } else {
            [self.playerNode play];
        }
    }
}

- (void)stopEngine
{
    if ([self.audioEngine isRunning]) {
        [self.playerNode stop];
        [self.audioEngine stop];
    }
}

#pragma mark - AVAudioPCMBUffer <-> NSData Conversions

AVAudioPCMBuffer* audioBufferForData(NSData *data, void *sourceFrameRefCon)
{
    AudioEngine *engine = (__bridge AudioEngine *)sourceFrameRefCon;
    uint32_t frameCapacity = (uint32_t)data.length / engine.audioFormat.streamDescription->mBytesPerFrame;
    AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:engine.audioFormat frameCapacity:frameCapacity];
    buffer.frameLength = buffer.frameCapacity;
    
    [data getBytes:*buffer.floatChannelData length:data.length];
    return buffer;
}

NSData* dataBufferForBuffer(AVAudioPCMBuffer *buffer)
{
    uint32_t length = buffer.frameCapacity * buffer.format.streamDescription->mBytesPerFrame;
    return [NSData dataWithBytes:*buffer.floatChannelData length:length];
}

#pragma mark - Play AVAudioPCMBuffers

- (void)playBuffer:(NSData *)data
{
    
    NSLog(@"playing buffer");
    
    AVAudioPCMBuffer *buffer = audioBufferForData(data, (__bridge void *)(self));
    [self.playerNode scheduleBuffer:buffer completionHandler:nil];
}

#pragma mark - Handle AVAudioPCMBuffers

void processBuffer(AVAudioPCMBuffer *buffer, AVAudioTime *time, void *sourceFrameRefCon)
{
    __block NSData *bufferData = dataBufferForBuffer(buffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        AudioEngine *engine = (__bridge AudioEngine *)sourceFrameRefCon;
        if (engine.delegate) {
            [engine.delegate didOutputAudioBuffer:bufferData];
        }
    });
}

@end
