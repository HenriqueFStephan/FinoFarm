"""Write short generated tones for harvest, the loom, and order delivery.

These are not recorded sound design. Each file is a labeled sine tone.
"""

import math
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
RATE = 22050


def write_tone(path: Path, notes: list[float], seconds: float) -> None:
    count = int(RATE * seconds)
    frames = bytearray()
    for index in range(count):
        time = index / RATE
        attack = min(1.0, index / (RATE * 0.02))
        release = min(1.0, (count - index) / (RATE * 0.09))
        sample = 0.0
        for note in notes:
            sample += math.sin(2.0 * math.pi * note * time)
        sample = sample / len(notes) * 0.32 * attack * release
        sample = max(-1.0, min(1.0, sample))
        frames += struct.pack("<h", int(sample * 32767))
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        handle.writeframes(frames)
    print(f"generated tone {path.name} {seconds:.2f}s")


def main() -> None:
    write_tone(ROOT / "harvest_tone.wav", [523.25, 659.25, 783.99], 0.42)
    write_tone(ROOT / "loom_tone.wav", [196.0, 246.94], 0.28)
    write_tone(ROOT / "delivery_tone.wav", [659.25, 880.0, 1046.5], 0.48)


if __name__ == "__main__":
    main()
