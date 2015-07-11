//
//  ACAudioInput.m
//  
//
//  Created by Andrew Cavanagh on 7/11/15.
//
//

#import "ACAudioInput.h"
@import AVFoundation;

AudioUnit *voiceAudioUnit = NULL;
float *voiceConvertedSampleBuffer = NULL;

@implementation ACAudioInput

//
//int initAudioStreams(AudioUnit *audioUnit, void *sourceFrameRef)
//{
//    AudioComponentDescription componentDescription;
//    componentDescription.componentType = kAudioUnitType_Output;
//    componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
//    componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
//    componentDescription.componentFlags = 0;
//    componentDescription.componentFlagsMask = 0;
//    
//    AudioComponent component = AudioComponentFindNext(NULL, &componentDescription);
//    if (AudioComponentInstanceNew(component, audioUnit) != noErr) {
//        return 1;
//    }
//    
//    UInt32 enable = 1;
//    if (AudioUnitSetProperty(*audioUnit, kAudioOutputUnitProperty_EnableIO,
//                             kAudioUnitScope_Input, 1, &enable, sizeof(UInt32)) != noErr) {
//        return 1;
//    }
//    
//    AURenderCallbackStruct callbackStruct;
//    callbackStruct.inputProc = renderCallback; // Render function
//    callbackStruct.inputProcRefCon = sourceFrameRef;
//    
//    if (AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(AURenderCallbackStruct)) != noErr) {
//        return 1;
//    }
//    
//    AudioStreamBasicDescription streamDescription;
//    streamDescription.mSampleRate = 44100;
//    streamDescription.mFormatID = kAudioFormatLinearPCM;
//    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
//    streamDescription.mBitsPerChannel = 16;
//    streamDescription.mBytesPerFrame = 2;
//    streamDescription.mChannelsPerFrame = 1;
//    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame * streamDescription.mChannelsPerFrame;
//    streamDescription.mFramesPerPacket = 1;
//    streamDescription.mReserved = 0;
//    
//    // Set up input stream with above properties
//    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
//                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
//        return 1;
//    }
//    
//    // Ditto for the output stream, which we will be sending the processed audio to
//    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
//                            kAudioUnitScope_Output, 1, &streamDescription, sizeof(streamDescription)) != noErr) {
//        return 1;
//    }
//    
//    return noErr;
//}
//
//OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags, const AudioTimeStamp *audioTimeStamp, UInt32 busNumber, UInt32 numFrames, AudioBufferList *buffers)
//{
//    ACAudioInput *engine = (__bridge ACAudioInput *)userData;
//    
//    NSLog(@"yolo");
//    
//    OSStatus status = AudioUnitRender(*voiceAudioUnit, actionFlags, audioTimeStamp, 1, numFrames, buffers);
//    if (status != noErr) {
//        NSLog(@"shit: %i", status);
//        return status;
//    }
//    
//    if (voiceConvertedSampleBuffer == NULL) {
//        voiceConvertedSampleBuffer = (float*)malloc(sizeof(float) * numFrames);
//    }
//    
//    SInt16 *inputFrames = (SInt16*)(buffers->mBuffers->mData);
//    for(int i = 0; i < numFrames; i++) {
//        voiceConvertedSampleBuffer[i] = (float)inputFrames[i] / 32768.0f;
//    }
//    
//    NSData *floatBuffer = [NSData dataWithBytes:voiceConvertedSampleBuffer length:sizeof(float) * numFrames];
//    [engine renderCallback:floatBuffer];
//    
//    return noErr;
//}
//
//- (void)renderCallback:(NSData *)floatBuffer {
//    NSLog(@"Buffer (%lu)", (unsigned long)floatBuffer.length);
//}

@end
