import wave
import math
import struct
import random
import os

def generate_tone(frequency, duration, volume=0.5, sample_rate=44100, wave_type='sine'):
    n_samples = int(sample_rate * duration)
    data = []
    
    for i in range(n_samples):
        t = float(i) / sample_rate
        
        if wave_type == 'sine':
            value = math.sin(2 * math.pi * frequency * t)
        elif wave_type == 'square':
            value = 1.0 if math.sin(2 * math.pi * frequency * t) > 0 else -1.0
        elif wave_type == 'sawtooth':
            value = 2.0 * (t * frequency - math.floor(t * frequency + 0.5))
        elif wave_type == 'noise':
            value = random.uniform(-1, 1)
        else:
            value = 0.0
            
        # Apply envelope (simple decay)
        envelope = 1.0 - (i / n_samples)
        value *= envelope * volume
        
        # Pack as 16-bit PCM
        packed_value = struct.pack('h', int(value * 32767.0))
        data.append(packed_value)
        
    return b''.join(data)

def save_wav(filename, data, sample_rate=44100):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        f.writeframes(data)
    print(f"Generated {filename}")

def main():
    base_path = "assets/audio"
    
    # Paddle Hit (High ping)
    data = generate_tone(880, 0.1, wave_type='square')
    save_wav(f"{base_path}/paddle_hit.wav", data)
    
    # Brick Hit (Crunchy noise/square mix)
    data = generate_tone(220, 0.1, wave_type='square')
    save_wav(f"{base_path}/brick_hit.wav", data)
    
    # Metal Brick (Metallic ting)
    data = generate_tone(1200, 0.05, wave_type='sine')
    save_wav(f"{base_path}/brick_hit_metal.wav", data)
    
    # Laser (Descending slide)
    data = bytearray()
    for i in range(4410): # 0.1s
        freq = 880 - (i / 10)
        t = float(i) / 44100
        val = math.sin(2 * math.pi * freq * t) * (1.0 - i/4410) * 0.5
        data.extend(struct.pack('h', int(val * 32767.0)))
    save_wav(f"{base_path}/laser.wav", bytes(data))
    
    # Explosion (Noise)
    data = generate_tone(0, 0.3, wave_type='noise')
    save_wav(f"{base_path}/explosion.wav", data)
    
    # Powerup (Ascending slide)
    data = bytearray()
    for i in range(8820): # 0.2s
        freq = 440 + (i / 10)
        t = float(i) / 44100
        val = (1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0) * (1.0 - i/8820) * 0.5
        data.extend(struct.pack('h', int(val * 32767.0)))
    save_wav(f"{base_path}/powerup.wav", bytes(data))
    
    # Life (Two tones)
    data = generate_tone(660, 0.1, wave_type='square') + generate_tone(880, 0.2, wave_type='square')
    save_wav(f"{base_path}/life.wav", data)
    
    # Game Over (Descending tristone)
    data = generate_tone(440, 0.3, wave_type='sawtooth') + generate_tone(330, 0.3, wave_type='sawtooth') + generate_tone(220, 0.5, wave_type='sawtooth')
    save_wav(f"{base_path}/game_over.wav", data)

    # Game Start (Ascending scale)
    data = b''
    for f in [440, 550, 660, 880]:
        data += generate_tone(f, 0.1, wave_type='square')
    save_wav(f"{base_path}/game_start.wav", data)

    # Warp (Rising sci-fi tone with tremolo)
    data = bytearray()
    duration = 2.0
    samples = int(44100 * duration)
    for i in range(samples):
        t = float(i) / 44100
        # Rising pitch 100Hz -> 800Hz
        freq = 100 + (700 * (t / duration))
        # Tremolo LFO (15Hz)
        lfo = 0.5 + 0.5 * math.sin(2 * math.pi * 15 * t)
        
        # Audio signal (Sawtooth-ish)
        val = (2.0 * (t * freq - math.floor(t * freq + 0.5))) * lfo * 0.5
        
        # Fade out at end
        if t > duration - 0.2:
            val *= (duration - t) / 0.2
            
        data.extend(struct.pack('h', int(val * 32767.0)))
    save_wav(f"{base_path}/warp.wav", bytes(data))

    # Intro Music (Cinematic sequence: Drone -> Chaos -> Driving)
    data = bytearray()
    duration = 14.0 # 14 seconds total
    samples = int(44100 * duration)
    
    # Bass line frequencies
    bass_notes = [55, 55, 55, 55, 58, 58, 62, 62] # A, C, D
    
    for i in range(samples):
        t = float(i) / 44100
        
        # Part 1: Ominous Drone (0-4s)
        # Part 2: Chaos/Destruction (4-9s)
        # Part 3: Warp/Speed (9-14s)
        
        val = 0.0
        
        # 1. Base Drone (Rich low end)
        drone_freq = 55.0 # A1
        # Mix 55Hz sine + 110Hz square (low volume) for presence
        drone = (math.sin(2 * math.pi * drone_freq * t) * 0.5) + \
                (0.5 if math.sin(2 * math.pi * (drone_freq * 2) * t) > 0 else -0.5) * 0.2
        
        # 2. Melody/Texture
        if t < 4.0:
            # Slow pulse
            # Offset pulse 0.5 to keep it positive mostly -> amplitude modulation instead of ring mod
            pulse = 0.5 + 0.5 * math.sin(2 * math.pi * 2.0 * t) 
            val = drone * pulse
        elif t < 9.0:
            # Chaos - DOH appears
            # Add noise and higher dissonant tones
            noise = random.uniform(-0.5, 0.5) * 0.3
            alarm = math.sin(2 * math.pi * 440 * t) * (1.0 if t % 0.5 < 0.25 else 0.0) * 0.2
            val = drone + noise + alarm
        else:
            # Warp - Driving sequence
            # Arpeggio
            tempo = 8.0 # notes per second
            note_idx = int(t * tempo) % len(bass_notes)
            bass_freq = bass_notes[note_idx]
            bass = (1.0 if math.sin(2 * math.pi * bass_freq * t) > 0 else -1.0) * 0.4
            
            # High speed wind
            wind = random.uniform(-0.1, 0.1) * 0.2
            val = bass + wind
            
        data.extend(struct.pack('h', int(max(-1.0, min(1.0, val)) * 32767.0)))
        
    save_wav(f"{base_path}/intro_music.wav", bytes(data))

if __name__ == "__main__":
    main()
