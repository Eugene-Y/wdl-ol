#include "IPlugEffectDSPKernel.hpp"

void IPlugEffectDSPKernel::handleOneEvent(AURenderEvent const *event) {
  switch (event->head.eventType) {
    case AURenderEventParameter:
    case AURenderEventParameterRamp: {
      AUParameterEvent const& paramEvent = event->parameter;
      
      startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames);
      break;
    }
      
    case AURenderEventMIDI:
      handleMIDIEvent(event->MIDI);
      break;
    
    default:
      break;
  }
}

void IPlugEffectDSPKernel::performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event) {
  do {
    handleOneEvent(event);

    // Go to next event.
    event = event->head.next;
    
    // While event is not null and is simultaneous (or late).
  } while (event && event->head.eventSampleTime <= now);
}

void IPlugEffectDSPKernel::processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount, AURenderEvent const *events) {

  AUEventSampleTime now = AUEventSampleTime(timestamp->mSampleTime);
  AUAudioFrameCount framesRemaining = frameCount;
  AURenderEvent const *event = events;
  
  while (framesRemaining > 0) {
    // If there are no more events, we can process the entire remaining segment and exit.
    if (event == nullptr) {
      AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
      process(framesRemaining, bufferOffset);
      return;
    }

    // **** start late events late.
    auto timeZero = AUEventSampleTime(0);
    auto headEventTime = event->head.eventSampleTime;
    AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(std::max(timeZero, headEventTime - now));
    
    // Compute everything before the next event.
    if (framesThisSegment > 0) {
      AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
      process(framesThisSegment, bufferOffset);
              
      // Advance frames.
      framesRemaining -= framesThisSegment;

      // Advance time.
      now += AUEventSampleTime(framesThisSegment);
    }
    
    performAllSimultaneousEvents(now, event);
  }
}

void IPlugEffectDSPKernel::init(int channelCount, double inSampleRate) {
}

void IPlugEffectDSPKernel::reset() {
}

void IPlugEffectDSPKernel::setParameter(AUParameterAddress address, AUValue value) {
}

AUValue IPlugEffectDSPKernel::getParameter(AUParameterAddress address) {
  return 0.0;
}

void IPlugEffectDSPKernel::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
}

void IPlugEffectDSPKernel::setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
  inBufferListPtr = inBufferList;
  outBufferListPtr = outBufferList;
}

void IPlugEffectDSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
}
