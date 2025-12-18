import wave
import math
import struct
import random
import os
import json

CONFIG_PATH = "tools/audio/audio_config.json"
BASE_PATH = "assets/audio"

def load_config():
    if not os.path.exists(CONFIG_PATH):
        print(f"Config not found at {CONFIG_PATH}")
        return {}
    with open(CONFIG_PATH, 'r') as f:
        return json.load(f)

def generate_oscillator(wave_type, freq, t):
    if wave_type == 'sine':
        return math.sin(2 * math.pi * freq * t)
    elif wave_type == 'square':
        return 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
    elif wave_type == 'sawtooth':
        return 2.0 * (t * freq - math.floor(t * freq + 0.5))
    elif wave_type == 'noise':
        return random.uniform(-1, 1)
    return 0.0

def generate_track_data(track_def, sample_rate=44100):
    duration = track_def.get("duration", 0.1)
    start_freq = track_def.get("start_freq", 440)
    end_freq = track_def.get("end_freq", start_freq)
    vol = track_def.get("vol", 0.5)
    wave_type = track_def.get("wave", "sine")
    
    n_samples = int(sample_rate * duration)
    data = []
    
    for i in range(n_samples):
        t = float(i) / sample_rate
        # Linear frequency interpretation (Slide)
        freq = start_freq + (end_freq - start_freq) * (i / n_samples)
        
        val = generate_oscillator(wave_type, freq, t)
        
        # Simple Decay Envelope
        envelope = 1.0 - (i / n_samples)
        
        final_val = val * envelope * vol
        data.append(final_val)
        
    return data

def process_sound_def(name, sound_def, sample_rate=44100):
    sound_type = sound_def.get("type", "sequence")
    
    # Handle Custom Generators separately
    if sound_type == "custom":
        gen_id = sound_def.get("generator_id")
        params = sound_def.get("params", {})
        dur = sound_def.get("duration", 1.0)
        if gen_id == "warp_sfx":
            return generate_warp(dur, params)
        elif gen_id == "intro_music":
            return generate_intro(dur, params)
        else:
            return []

    # Handle Standard Sequencer/Mixer
    tracks = sound_def.get("tracks", [])
    
    # Sequence: Append one after another
    # Mix: Add together (simplification: we'll just do Sequence for now as "mix" in JSON example `life` was used but logic implies overlap?)
    # Wait, "Life" definition I wrote has "delay". Mix logic is needed for accurate timing if overlapping.
    # For simplicity, if type is 'sequence', we concat. If type is 'mix', we add.
    
    final_buffer = []
    
    if sound_type == "sequence":
        for track in tracks:
            track_data = generate_track_data(track, sample_rate)
            final_buffer.extend(track_data)
            
    elif sound_type == "mix":
        # Determine total length
        # This is uniform sampling, a bit harder.
        # Let's simplify: Just render each track and add them to a buffer.
         # Find max duration
        max_len = 0
        rendered_tracks = []
        for track in tracks:
            pcm = generate_track_data(track, sample_rate)
            delay_samples = int(track.get("delay", 0) * sample_rate)
            total_len = delay_samples + len(pcm)
            if total_len > max_len:
                max_len = total_len
            rendered_tracks.append((delay_samples, pcm))
            
        final_buffer = [0.0] * max_len
        for delay, pcm in rendered_tracks:
            for i, val in enumerate(pcm):
                final_buffer[delay + i] += val
                
    return final_buffer

# --- Custom Generators (Ported/Adapted) ---

def generate_warp(duration, params):
    samples = int(44100 * duration)
    buffer = []
    start_f = params.get("freq_start", 100)
    end_f = params.get("freq_end", 800)
    lfo_f = params.get("lfo_freq", 15)
    
    for i in range(samples):
        t = float(i) / 44100
        freq = start_f + ((end_f - start_f) * (t / duration))
        lfo = 0.5 + 0.5 * math.sin(2 * math.pi * lfo_f * t)
        val = (2.0 * (t * freq - math.floor(t * freq + 0.5))) * lfo * 0.5
        # Fade out
        if t > duration - 0.2:
            val *= (duration - t) / 0.2
        buffer.append(val)
    return buffer

def generate_intro(duration, params):
    samples = int(44100 * duration)
    buffer = []
    bass_notes = [55, 55, 55, 55, 58, 58, 62, 62]
    
    for i in range(samples):
        t = float(i) / 44100
        val = 0.0
        
        # Drone
        drone_freq = 55.0
        drone = (math.sin(2 * math.pi * drone_freq * t) * 0.5) + \
                (0.5 if math.sin(2 * math.pi * (drone_freq * 2) * t) > 0 else -0.5) * 0.2
                
        if t < 4.0:
            pulse = 0.5 + 0.5 * math.sin(2 * math.pi * 2.0 * t) 
            val = drone * pulse
        elif t < 9.0:
            noise = random.uniform(-0.5, 0.5) * 0.3
            alarm = math.sin(2 * math.pi * 440 * t) * (1.0 if t % 0.5 < 0.25 else 0.0) * 0.2
            val = drone + noise + alarm
        else:
            tempo = 8.0
            note_idx = int(t * tempo) % len(bass_notes)
            bass_freq = bass_notes[note_idx]
            bass = (1.0 if math.sin(2 * math.pi * bass_freq * t) > 0 else -1.0) * 0.4
            wind = random.uniform(-0.1, 0.1) * 0.2
            val = bass + wind
            
        buffer.append(max(-1.0, min(1.0, val)))
        
    return buffer

def save_wav_from_floats(filename, float_data, sample_rate=44100):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    # Convert floats to 16-bit PCM (bytes)
    byte_data = bytearray()
    for val in float_data:
        # Hard clip
        clamped = max(-1.0, min(1.0, val))
        byte_data.extend(struct.pack('h', int(clamped * 32767.0)))
        
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        f.writeframes(byte_data)
    print(f"Generated {filename}")

def main():
    print("Loading Audio Config...")
    config = load_config()
    
    for name, definition in config.items():
        print(f"Synthesizing {name}...")
        audio_buffer = process_sound_def(name, definition)
        save_wav_from_floats(f"{BASE_PATH}/{name}.wav", audio_buffer)

if __name__ == "__main__":
    main()
