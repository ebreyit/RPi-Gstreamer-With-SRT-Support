 gst-launch-1.0 -v videotestsrc ! video/x-raw,width=1280,height=720 ! autovideosink
 
 
 gst-launch-1.0 -v rpicamsrc preview=true sensor-mode=5 bitrate=8000000! video/x-h264,width=1640,height=922,framerate=40/1,profile=baseline ! mpegtsmux ! srtsink uri=srt://:8888
 
 
 
 sudo gst-launch-1.0 -v v4l2src device=/dev/video0 do-timestamp=true ! tee name=tee ! capsfilter caps="video/x-raw,width=1920,height=1080,framerate=30/1,bitrate=40000" ! queue ! videoflip method=rotate-180 ! videoconvert ! videorate ! queue ! omxh264enc ! queue ! avimux ! queue ! filesink location = test.h264 qos=true --gst-debug=GST_QOS:5 ! queue ! videoscale method=1 ! videoconvert ! capsfilter caps="video/x-raw,width=256,height=144,framerate=30/1" ! queue ! videoflip method = rotate-180 ! queue ! omxh264enc ! queue ! h264parse ! mpegtsmux ! rtpmp2tpay ! multiudpsink clients=192.168.5.255:1234 ttl=1 auto-multicast=true
 
 
 gst-launch-1.0 -v videotestsrc ! video/x-raw,width=1280,height=720 ! queue ! omxh264enc ! queue ! h264parse ! mpegtsmux ! srtsink uri=srt://:8888
 
 gst-launch-1.0 -v videotestsrc ! video/x-raw,width=1280,height=720 ! queue ! v4l2h264enc output-io-mode=4 ! queue ! h264parse ! mpegtsmux ! srtsink uri=srt://:8888
 
 gst-launch-1.0 -v videotestsrc ! video/x-raw,width=1280,height=720 ! queue ! avenc_h264_omx bitrate=500000 ! video/x-h264,profile=high,stream-format=byte-stream ! queue ! h264parse ! rtph264pay ! udpsink host=10.50.0.29 port=20000
 
 
 sudo apt update && sudo apt upgrade -y
 
 sudo raspi-config
 
 sudo apt install git screen -y
 
 git clone https://github.com/ebreyit/RPi-Gstreamer-With-SRT-Support.git
 
 cd RPi-Gstreamer-With-SRT-Support
 
 chmod u+x gstreamer-build.sh
 
 screen
 
 ./gstreamer-build.sh
 
 
 gst-launch-1.0  -e videotestsrc num-buffers=1500 ! 'video/x-raw,width=720,height=405,framerate=25/1,format=NV12,colorimetry=bt709' !  v4l2h264enc output-io-mode=4  extra-controls="encode,frame_level_rate_control_enable=1,h264_profile=0,h264_level=14,video_bitrate=2500000;"  ! h264parse ! matroskamux ! filesink location=2M.mkv
 
 gst-launch-1.0  -e videotestsrc num-buffers=1500 ! 'video/x-raw,width=720,height=405,framerate=25/1,format=NV12,colorimetry=bt709' !  v4l2h264enc output-io-mode=4  ! h264parse ! matroskamux ! filesink location=3M.mkv
 
 gst-launch-1.0  -e videotestsrc num-buffers=1500 ! 'video/x-raw,width=720,height=405,framerate=25/1,format=NV12,colorimetry=bt709' !  v4l2h264enc output-io-mode=4  ! h264parse ! rtph264pay ! udpsink host=10.50.0.429 port=20000
 
 gst-launch-1.0  -e videotestsrc num-buffers=1500 ! 'video/x-raw,width=720,height=405,framerate=25/1,format=NV12,colorimetry=bt709' !  v4l2h264enc output-io-mode=4  ! h264parse config-interval=1 ! mpegtsmux ! udpsink host=10.50.0.29 port=20000
 
  gst-launch-1.0  -e videotestsrc num-buffers=1500 ! 'video/x-raw,width=720,height=405,framerate=25/1,format=NV12,colorimetry=bt709' !  v4l2h264enc output-io-mode=4  ! h264parse ! mpegtsmux alignment=7 ! srtsink uri=srt://10.50.0.29:20000?mode=caller latency=100
 
 gst-launch-1.0 -v videotestsrc ! video/x-raw, height=1080, width=1920 ! videoconvert ! x264enc tune=zerolatency ! video/x-h264, profile=high, bitrate=2000 ! mpegtsmux ! srtsink uri=srt://10.50.0.29:20000?mode=caller
 
  gst-launch-1.0 srtsrc uri=srt://:8888 ! decodebin ! autovideosink
  
  
  Insert SPS and PPS at IDR
gst-launch-1.0 videotestsrc num-buffers=200 ! \
'video/x-raw, width=(int)1280, height=(int)720, \
format=(string)I420' ! omxh264enc insert-sps-pps=1 ! qtmux ! \
filesink location=test.mp4 -e
Accelerated GStreamer User Guide
Accelerated GStreamer User Guide DA_07303-4.0 | 16
If enabled, a sequence parameter set (SPS) and a picture parameter set (PPS) are inserted
before each IDR frame in the H.264/H.265 stream.


gst-launch-1.0 \
    uridecodebin uri="$uri" \
    ! omxh264enc ! h264parse config-interval=1 \
    ! mpegtsmux \
    ! tcpserversink host=134.202.84.72 port=1234
	
	gst-launch-1.0  -v v4l2src device=/dev/video0 do-timestamp=true ! 'video/x-raw, format=YUY2, width=1920, height=1080, framerate=25/1' ! queue !  v4l2h264enc output-io-mode=4 ! queue ! h264parse config-interval=1 ! queue ! mpegtsmux ! queue ! udpsink host=10.50.0.29 port=20000
  
  
 
 
