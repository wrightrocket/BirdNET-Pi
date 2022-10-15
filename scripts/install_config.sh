#!/usr/bin/env bash
# Creates and installs the /etc/birdnet/birdnet.conf file
set -x # Uncomment to enable debugging
set -e
trap 'exit 1' SIGINT SIGHUP

echo "Beginning $0"
birdnet_conf=$my_dir/birdnet.conf

install_config() {
  [ -f $birdnet_conf ] && mv $birdnet_conf ${birdnet_conf}-$(date --iso-8601=seconds) \
  && echo "Backup made of $birdnet_conf with the current timestamp."
  # Kind to users who didn't backup their customized values

  cat << EOF > $birdnet_conf
################################################################################
#                    Configuration settings for BirdNET-Pi                     #
################################################################################

#--------------------- Required: Latitude, and Longitude ----------------------#

## The shell substitution below guesses these based on your network. THESE NEED
## TO BE CHANGED TO STATIC VALUES
## Please only go to 4 decimal places. Example:43.3984

LATITUDE=$(curl -s4 ifconfig.co/json | jq .latitude)
LONGITUDE=$(curl -s4 ifconfig.co/json | jq .longitude)

#---------------------  BirdWeather Station Information -----------------------#
#_____________The variable below can be set to have your BirdNET-Pi____________#
#__________________also act as a BirdWeather listening station_________________#

BIRDWEATHER_ID=

#-----------------------  Web Interface User Password  ------------------------#
#____________________The variable below sets the 'birdnet'_____________________#
#___________________user password for the Live Audio Stream,___________________#
#_________________Tools, System Links, and the Processed files ________________#

## CADDY_PWD is the plaintext password (that will be hashed) and used to access
## certain parts of the web interface

CADDY_PWD=

#-------------------------  Live Audio Stream  --------------------------------#
#_____________The variable below configures/enables the live___________________#
#_____________________________audio stream.____________________________________#


## ICE_PWD is the password that icecast2 will use to authenticate ffmpeg as a
## trusted source for the stream. You will never need to enter this manually
## anywhere other than here and it stays on 'localhost.'

ICE_PWD=birdnetpi

#-----------------------  Web-hosting/Caddy File-server -----------------------#
#_______The three variables below can be set to enable internet access_________#
#____________to your data,(e.g., extractions, raw data, live___________________#
#______________audio stream, BirdNET.selection.txt files)______________________#


## BIRDNETPI_URL is the URL where the extractions, data-set, and live-stream
## will be web-hosted. If you do not own a domain, or would just prefer to keep
## the BirdNET-Pi on your local network, keep this EMPTY.

BIRDNETPI_URL=

#----------------------------  RTSP Stream URL  -------------------------------#

## If RTSP_STREAM is set, the system will use the RTSP stream as its audio
## source instead of recording its own audio. If this variable is kept empty,
## BirdNET-Pi will default to recording its own audio.

RTSP_STREAM=

#-----------------------  Apprise Miscellanous Configuration -------------------#

APPRISE_NOTIFICATION_TITLE="New BirdNET-Pi Detection"
APPRISE_NOTIFICATION_BODY="A \$sciname \$comname was just detected with a confidence of \$confidence"
APPRISE_NOTIFY_EACH_DETECTION=0
APPRISE_NOTIFY_NEW_SPECIES=0
APPRISE_WEEKLY_REPORT=1

#----------------------  Flickr Images API Configuration -----------------------#
## If FLICKR_API_KEY is set, the web interface will try and display bird images 
## for each detection. If FLICKR_FILTER_EMAIL is set, the images will only be 
## displayed from a particular Flickr user (e.g. yourself).

FLICKR_API_KEY=
FLICKR_FILTER_EMAIL=

################################################################################
#--------------------------------  Defaults  ----------------------------------#
################################################################################

## RECS_DIR is the location birdnet_analysis.service will look for the data-set
## it needs to analyze. Be sure this directory is readable and writable for
## the BIRDNET_USER.

RECS_DIR=$HOME/BirdSongs

## REC_CARD is the sound card you would want the birdnet_recording.service to
## use. Leave this as "default" to use PulseAudio (recommended), or use
## the output from "aplay -L" to specify an ALSA device.

REC_CARD=default

## PROCESSED is the directory where the formerly 'Analyzed' files are moved
## after extractions have been made from them. This includes both WAVE and
## BirdNET.selection.txt files.

PROCESSED=$HOME/BirdSongs/Processed

## EXTRACTED is the directory where the extracted audio selections are moved.

EXTRACTED=$HOME/BirdSongs/Extracted

## OVERLAP is the value in seconds which BirdNET should use when analyzing
## the data. The values must be between 0.0-2.9.

OVERLAP=0.0

## CONFIDENCE is the minimum confidence level from 0.0-1.0 BirdNET's analysis
## should reach before creating an entry in the BirdNET.selection.txt file.
## Don't set this to 1.0 or you won't have any results.

CONFIDENCE=0.7

## SENSITIVITY is the detection sensitivity from 0.5-1.5.

SENSITIVITY=1.25

## Configuration of the frequency shifting feature, useful for earing impaired people.

## FREQSHIFT_TOOL

FREQSHIFT_TOOL=sox

## If the tool is ffmpeg, you have to define a freq. shift from HI to LO:
## FREQSHIFT_HI
FREQSHIFT_HI=6000
## FREQSHIFT_LO
FREQSHIFT_LO=3000

## If the tool is sox, you have to define the pitch shift (amount of 100ths of semintone)
## FREQSHIFT_PITCH
FREQSHIFT_PITCH=-1500

## CHANNELS holds the variable that corresponds to the number of channels the
## sound card supports.

CHANNELS=2

## FULL_DISK can be set to configure how the system reacts to a full disk
## purge = Remove the oldest day's worth of recordings
## keep = Keep all data and 'stop_core_services.sh'

FULL_DISK=purge

## PRIVACY_THRESHOLD can be set to enable sensitivity to Human sounds. This
## setting is an effort to introduce privacy into the data collection.
## The PRIVACY_THRESHOLD value represents a percentage of the entire species
## list used during analysis. If a human sound is predicted anywhere within
## the precentile set below, no data is collected for that audio chunk.
## Valid range: 0-3

PRIVACY_THRESHOLD=0

## RECORDING_LENGTH sets the length of the recording that BirdNET-Lite will
## analyze.

RECORDING_LENGTH=15

## EXTRACTION_LENGTH sets the length of the audio extractions that will be made
## from each BirdNET-Lite detection. An empty value will use the default of 6
## seconds.

EXTRACTION_LENGTH=

## AUDIOFMT set the audio format that sox should use for the extractions.
## The default is mp3. Available formats are: 8svx aif aifc aiff aiffc al amb
## amr-nb amr-wb anb au avr awb caf cdda cdr cvs cvsd cvu dat dvms f32 f4 f64 f8
## fap flac fssd gsm gsrt hcom htk ima ircam la lpc lpc10 lu mat mat4 mat5 maud
## mp2 mp3 nist ogg paf prc pvf raw s1 s16 s2 s24 s3 s32 s4 s8 sb sd2 sds sf sl
## sln smp snd sndfile sndr sndt sou sox sph sw txw u1 u16 u2 u24 u3 u32 u4 u8
## ub ul uw vms voc vorbis vox w64 wav wavpcm wv wve xa xi
## Note: Most have not been tested.

AUDIOFMT=mp3

## DATABASE_LANG is the language used for the bird species database
DATABASE_LANG=en

## HEARTBEAT_URL is a location to ping every time some analysis is done
## no information is sent to the the URL, its a heart beat to show that the
## analysis is continuing

HEARTBEAT_URL=

## SILENCE_UPDATE_INDICATOR is for quieting the display of how many commits
## your installation is behind by, relative to the Github repo. This number
## appears next to "Tools" when you're 50 or more commits behind.

SILENCE_UPDATE_INDICATOR=0

## These are just for debugging
LAST_RUN=
THIS_RUN=
IDFILE=$HOME/BirdNET-Pi/IdentifiedSoFar.txt
EOF
}

install_config
chmod g+w $birdnet_conf
[ -d /etc/birdnet ] || sudo mkdir /etc/birdnet
sudo ln -sf $birdnet_conf /etc/birdnet/birdnet.conf
grep -ve '^#' -e '^$' /etc/birdnet/birdnet.conf > $my_dir/firstrun.ini
