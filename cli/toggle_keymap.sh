echo "hihihi"

source $basepath/alive_cli/.venv/bin/activate
echo "Press ctrl-c to stop recording..."

# good
# ffmpeg -f alsa -channels 1 -sample_rate 44100 -i default -f wav - | python whisper.py
python $basepath/alive_cli/whisper.py
