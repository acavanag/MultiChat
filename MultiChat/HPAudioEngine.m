//
//  HPAudioEngine.m
//  
//
//  Created by Andrew Cavanagh on 7/9/15.
//
//

#define kOutputBus 0
#define kInputBus 1

#import "HPAudioEngine.h"
@import AVFoundation;

AudioUnit *audioUnit = NULL;
float *convertedSampleBuffer = NULL;

@implementation HPAudioEngine

- (void)configureAudioSession
{
    NSError *error = nil;
    
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"%@", error);
        error = nil;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"%@", error);
        error = nil;
    }
    
    [[AVAudioSession sharedInstance] setPreferredIOBufferDuration:0.02f error:&error];
    if (error) {
        NSLog(@"%@", error);
        error = nil;
    }

    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (error) {
        NSLog(@"%@", error);
        error = nil;
    }
    
    audioUnit = (AudioUnit*)malloc(sizeof(AudioUnit));
    
    initAudioStreams(audioUnit, (__bridge void *)(self));
    //yolo(audioUnit, (__bridge void *)(self));
    
    if (startAudioUnit(audioUnit)) {
        NSLog(@"Error starting audio unit");
    }
}

int initAudioStreams(AudioUnit *audioUnit, void *sourceFrameRef)
{
    AudioComponentDescription componentDescription;
    componentDescription.componentType = kAudioUnitType_Output;
    componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    componentDescription.componentFlags = 0;
    componentDescription.componentFlagsMask = 0;
    
    AudioComponent component = AudioComponentFindNext(NULL, &componentDescription);
    if (AudioComponentInstanceNew(component, audioUnit) != noErr) {
        return 1;
    }
    
    UInt32 enable = 1;
    if (AudioUnitSetProperty(*audioUnit, kAudioOutputUnitProperty_EnableIO,
                            kAudioUnitScope_Input, 1, &enable, sizeof(UInt32)) != noErr) {
        return 1;
    }
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback; // Render function
    callbackStruct.inputProcRefCon = sourceFrameRef;
    
    if (AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(AURenderCallbackStruct)) != noErr) {
        return 1;
    }
    
    AudioStreamBasicDescription streamDescription;
    streamDescription.mSampleRate = 44100;
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    streamDescription.mBitsPerChannel = 16;
    streamDescription.mBytesPerFrame = 2;
    streamDescription.mChannelsPerFrame = 1;
    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame * streamDescription.mChannelsPerFrame;
    streamDescription.mFramesPerPacket = 1;
    streamDescription.mReserved = 0;
    
    // Set up input stream with above properties
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    
    // Ditto for the output stream, which we will be sending the processed audio to
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Output, 1, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    
    return noErr;
}

int startAudioUnit(AudioUnit *audioUnit)
{
    if (AudioUnitInitialize(*audioUnit) != noErr) {
        return 1;
    }
    
    if (AudioOutputUnitStart(*audioUnit) != noErr) {
        return 1;
    }
    
    return noErr;
}

OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags, const AudioTimeStamp *audioTimeStamp, UInt32 busNumber, UInt32 numFrames, AudioBufferList *buffers)
{
    HPAudioEngine *engine = (__bridge HPAudioEngine *)userData;
    
    NSLog(@"yolo");
    
    OSStatus status = AudioUnitRender(*audioUnit, actionFlags, audioTimeStamp, 1, numFrames, buffers);
    if (status != noErr) {
        NSLog(@"shit: %i", status);
        return status;
    }
    
    if (convertedSampleBuffer == NULL) {
        convertedSampleBuffer = (float*)malloc(sizeof(float) * numFrames);
    }
    
    SInt16 *inputFrames = (SInt16*)(buffers->mBuffers->mData);
    for(int i = 0; i < numFrames; i++) {
        convertedSampleBuffer[i] = (float)inputFrames[i] / 32768.0f;
    }
    
    NSData *floatBuffer = [NSData dataWithBytes:convertedSampleBuffer length:sizeof(float) * numFrames];
    [engine renderCallback:floatBuffer];
    
    return noErr;
}

- (void)renderCallback:(NSData *)floatBuffer {
    NSLog(@"Buffer (%lu)", (unsigned long)floatBuffer.length);
}













































/*************************** EXPERIMENTAL ************************************/
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/



int yolo(AudioUnit *audioUnit, void *sourceFrameRef)
{
    OSStatus status;
    
    // Describe audio component
    AudioComponentDescription componentDescription;
    componentDescription.componentType = kAudioUnitType_Output;
    componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    componentDescription.componentFlags = 0;
    componentDescription.componentFlagsMask = 0;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &componentDescription);
    // Get audio units
    AudioComponentInstanceNew(inputComponent, audioUnit);
    
    // Enable IO for recording
    UInt32 flag = 1;
    AudioUnitSetProperty(*audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, kInputBus, &flag, sizeof(flag));
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback;
    callbackStruct.inputProcRefCon = sourceFrameRef;
//    status = AudioUnitSetProperty(*audioUnit,
//                                  kAudioOutputUnitProperty_SetInputCallback,
//                                  kAudioUnitScope_Global,
//                                  kInputBus,
//                                  &callbackStruct,
//                                  sizeof(callbackStruct));
    
    
    
    AudioUnitSetProperty(*audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(AURenderCallbackStruct));
    
    
    
    // Describe format
    AudioStreamBasicDescription streamDescription;
    streamDescription.mSampleRate = 44100;
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    streamDescription.mBitsPerChannel = 16;
    streamDescription.mBytesPerFrame = 2;
    streamDescription.mChannelsPerFrame = 1;
    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame * streamDescription.mChannelsPerFrame;
    streamDescription.mFramesPerPacket = 1;
    streamDescription.mReserved = 0;
    
    // Apply format
    status = AudioUnitSetProperty(*audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &streamDescription,
                                  sizeof(streamDescription));
    
    status = AudioUnitSetProperty(*audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &streamDescription,
                                  sizeof(streamDescription));
    
    
    
    // Enable IO for playback
    status = AudioUnitSetProperty(*audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    

    
    
    return noErr;
    
    
    
    // Set output callback
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = sourceFrameRef;
    status = AudioUnitSetProperty(*audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    
    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    status = AudioUnitSetProperty(*audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output, 
                                  kInputBus,
                                  &flag, 
                                  sizeof(flag));
    
    // TODO: Allocate our own buffers if we want
    
    // Initialise
    status = AudioUnitInitialize(*audioUnit);
    AudioOutputUnitStart(*audioUnit);
    
    return noErr;
}





static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    
    NSLog(@"playback");
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    return noErr;
}


/*************************** EXPERIMENTAL ************************************/
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/


@end
