from os import getenv
from enum import StrEnum
from RealtimeSTT import AudioToTextRecorder
import pyautogui
from random import choice
import hnswlib

model_size = "turbo"
device = "cuda"

BASEPATH = f"{getenv('basepath')}/alive_cli"

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

class VectorManagementSystem:
    def __init__(self):
        self.dimension = 128  # Default vector dimension
        self.index = hnswlib.Index(space='l2', dim=self.dimension)
        self.index.init_index(max_elements=10000, ef_construction=200, M=16)

class Sounds(StrEnum):
    beep = "beep"
    boop = "boop"

class Player():
    def __init__(self, sound: Sounds = Sounds.beep):
        self.files = self.get_files()
        self.sounds= self.get_sounds()

    def get_files(self, sound: Sounds | None = None):
        import os
        return os.listdir(f"{BASEPATH}/mp3_files")

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
    computerbox(text)
    # pyautogui.hotkey('ctrl', 'i')
    pyautogui.typewrite(text)
    pyautogui.hotkey('enter')

class ComputerBox:
    SIDE_BORDER = "│"
    TEXT_FORMAT = "\033[1;32;4m"
    TEXT_RESET = "\033[0m"
    INDENT = "        "
    BOX_WIDTH = 53

    def __init__(self, text: str, box_width: int = BOX_WIDTH):
        print("\n\n")
        self.box_width = box_width
        self.print_box(text)

    def get_border(self):
        return ''.join(['─' for i in range(self.box_width)])

    def print_top(self):
        print(f"\n{self.INDENT}┌{self.get_border()}┐")
        return self

    def print_bottom(self):
        print(f"{self.INDENT}└{self.get_border()}┘\n")
        return self

    def print_line(self, text, length):
        text_length = len(text)
        padding = (self.box_width- text_length - 2) // 2
        left_padding = padding + 2
        right_padding = self.box_width- text_length - left_padding
        print(f"{self.INDENT}{self.SIDE_BORDER}{' ' * left_padding}{self.TEXT_FORMAT}{text}{self.TEXT_RESET}{' ' * right_padding}{self.SIDE_BORDER}")
        return self

    def print_text(self, text, chunk_size):
        if not text:
            return self
        segment = text[:chunk_size]
        remaining_text = text[chunk_size:]
        self.print_line(segment, len(segment))
        return self.print_text(remaining_text, chunk_size)

    def print_section(self, text):
        for line in text.split('\n'):
            self.print_text(line, self.box_width-4)
        return self

    def print_box(self, text):
        return self.print_top().print_section(text).print_bottom()
        return self

def computerbox(text):
    import shutil
    terminal_width = shutil.get_terminal_size().columns
    return ComputerBox(text, box_width=terminal_width - 16) # Account for indent

if __name__ == '__main__':

    computerbox('say "Computer"')
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
