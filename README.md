# ffmpeg-mjpeg-server
A low-latency MJPEG server for RTSP/RTMP and other ffmpeg media sources.

Uses lighttpd with a CGI script to wrap ffmpeg's MJPEG output, to provide a quick-and-dirty solution to viewing
a video stream on older browsers and devices. I've tested it specifically with iOS 9, as a method of bypassing
buggy HLS camera streaming in Safari, but the MJPEG format is supported on nearly every web browser ever made. 

[View on Docker Hub](https://hub.docker.com/r/jwoglom/ffmpeg-mjpeg-server)

## Example

Basic invocation, launching a server listening on port 8888:
```bash
docker run -it \
    -p 8888:80/tcp \
    -e STREAM_URL=rtsp://192.168.x.x:8554/stream.m3u8 \
    jwoglom/ffmpeg-mjpeg-server 
```

http://localhost:8888 will serve a basic HTML page, with an `<img>` tag and some basic JavaScript which automatically reloads the MJPEG stream as needed.

http://localhost:8888/cgi-bin/stream will return the raw MJPEG output.

A more advanced example, which forces using TCP for the RTSP input stream, and limits the output FPS of the MJPEG stream to 5fps to save bandwidth and some processing power:
```bash
docker run -it \
    -p 8888:80/tcp \
    -e STREAM_URL=rtsp://192.168.x.x:8554/stream.m3u8 \
    -e FFMPEG_INPUT_OPTIONS="-rtsp_transport tcp -re" \
    -e FFMPEG_OUTPUT_OPTIONS="-preset ultrafast -c:v mjpeg -q:v 1 -f mpjpeg -an -r 5" \
    jwoglom/ffmpeg-mjpeg-server 
```

## Options

ffmpeg is invoked with `ffmpeg $FFMPEG_INPUT_OPTIONS -i "$STREAM_URL" $FFMPEG_OUTPUT_OPTIONS -`

| Environment variable | Default value | Description                          |
|----------------------|---------------|--------------------------------------|
| **STREAM_URL**       | `<none>`        | The URL to your video stream. e.g., `rtsp://192.168.x.x:8554/stream.m3u8`
| **FFMPEG_INPUT_OPTIONS**| `-re`        | Options placed before the `STREAM_URL` in the ffmpeg command. Typically used to control the parameters to fetch the origin stream. 
| **FFMPEG_OUTPUT_OPTIONS**| `-preset ultrafast -c:v mjpeg -q:v 1 -f mpjpeg -an`        | Options placed after the `STREAM_URL` in the ffmpeg command. Typically used to control the MJPEG output stream options.

### Default ffmpeg options

`-re` configures ffmpeg to fetch the stream at its provided FPS, rather than speed-through every frame as soon as it can fetch it.

`-preset ultrafast` configures ffmpeg with a fast encoding preset. Generating mjpeg streams can be CPU intensive.

`-q:v 1` configures ffmpeg to pass through the same scaling options as the input.

`-f mpjpeg` configures ffmpeg to output in [mjpeg format](https://en.wikipedia.org/wiki/Motion_JPEG).

`-an` disables audio.


## Troubleshooting

If you receive an error launching a container involving `/dev/pts/0`:

```
hmod: /dev/pts/0: No such file or directory
```

Ensure that you are running docker with the `-t` option, since [due to this bug lighttpd-docker requires a TTY to run](https://github.com/spujadas/lighttpd-docker/issues/8).
