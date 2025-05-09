from enum import StrEnum
from RealtimeSTT import AudioToTextRecorder
import pyautogui
from random import choice

model_size = "tiny.en"
device = "cuda"

class Window():
    def __init__(self):
        self.buffer = bytes()

    def __iter__(self):
        BUFFER_SIZE = 44100
        while len(self.buffer) >= BUFFER_SIZE:
            yield self.buffer[:BUFFER_SIZE]
            self.buffer = self.buffer[BUFFER_SIZE:]

    def add(self, buffer: bytes):
        self.buffer += buffer
        return self

class Sounds(StrEnum):
    beep = "beep"
    boop = "boop"

class Player():
    def __init__(self, sound: Sounds = Sounds.beep):
        self.files = self.get_files()
        self.sounds= self.get_sounds()

    def get_files(self, sound: Sounds | None = None):
        import os
        return os.listdir("./mp3_files")

    def magic_file_split(self, sound: Sounds):
        return [name for name in self.files if name.split("__")[0] == sound]

    def get_sounds(self):
        return {
            Sounds.beep: range(0,14),
            Sounds.boop: range(15,27)
        }

    def get_sound_file(self, sound: Sounds) -> str:
        return choice(self.magic_file_split(sound))

    def play(self, sound: Sounds):
        import subprocess
        file = self.get_sound_file(sound)
        print(f"\n\033[32m{file}\033[0m\n")
        subprocess.Popen(['ffplay',
            '-nodisp',
            '-autoexit',
            f"./mp3_files/{file}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

player = Player()

def play_sound(sound: Sounds):
    return lambda: player.play(sound)

# todo(seb): implement modality
def process_text(text):
    # pyautogui.hotkey('ctrl', 'i')
    pyautogui.typewrite(text)
    pyautogui.hotkey('enter')

if __name__ == '__main__':
    print("Wait until it says 'speak now'")
    recorder = AudioToTextRecorder(
        wake_words="computer",
        silero_deactivity_detection=True,
        wakeword_backend="pvporcupine",
        on_wakeword_detected=play_sound(Sounds.beep),
        on_vad_stop=play_sound(Sounds.boop),
        enable_realtime_transcription=True
    )
    while True:
        recorder.text(process_text)
