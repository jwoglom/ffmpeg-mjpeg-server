# ffmpeg-mjpeg-server
A low-latency MJPEG server for RTSP and other ffmpeg sources.

Uses lighttpd with a CGI script to wrap ffmpeg's MJPEG output, to provide a quick-and-dirty solution to viewing
a video stream on older browsers and devices.

[View on Docker Hub](https://hub.docker.com/r/jwoglom/ffmpeg-mjpeg-server)

## Example

Basic invocation, launching a server listening on port 8888:
```bash
docker run \
    -p 8888:80/tcp \
    -e STREAM_URL=rtsp://192.168.x.x:8554/stream.m3u8 \
    jwoglom/ffmpeg-mjpeg-server 
```

http://localhost:8888 will serve a basic HTML page, with an `<img>` tag and some basic JavaScript which automatically reloads the MJPEG stream as needed.

http://localhost:8888/cgi-bin/stream will return the raw MJPEG output.

A more advanced example:
```bash
docker run \
    -p 8888:80/tcp \
    -e STREAM_URL=rtsp://192.168.x.x:8554/stream.m3u8 \
    -e FFMPEG_INPUT_OPTIONS="-rtsp_transport tcp -re" \
    -e FFMPEG_OUTPUT_OPTIONS="-c:v mjpeg -q:v 1 -f mpjpeg" \
    jwoglom/ffmpeg-mjpeg-server 
```

## Options

ffmpeg is invoked with `ffmpeg $FFMPEG_INPUT_OPTIONS -i "$STREAM_URL" $FFMPEG_OUTPUT_OPTIONS -`

| Environment variable | Default value | Description                          |
|----------------------|---------------|--------------------------------------|
| **STREAM_URL**       | `<none>`        | The URL to your video stream. e.g., `rtsp://192.168.x.x:8554/stream.m3u8`
| **FFMPEG_INPUT_OPTIONS**| `-re`        | Options placed before the `STREAM_URL` in the ffmpeg command. Typically used to control the parameters to fetch the origin stream. 
| **FFMPEG_OUTPUT_OPTIONS**| `-preset veryfast -c:v mjpeg -q:v 1 -f mpjpeg -an`        | Options placed after the `STREAM_URL` in the ffmpeg command. Typically used to control the MJPEG output stream options.

### Default ffmpeg options

`-re` configures ffmpeg to fetch the stream at its provided FPS, rather than speed-through every frame as soon as it can fetch it.

`-preset veryfast` configures ffmpeg with a fast encoding preset. Generating mjpeg streams can be CPU intensive.

`-q:v 1` configures ffmpeg to pass through the same scaling options as the input.

`-f mpjpeg` configures ffmpeg to output in [mjpeg format](https://en.wikipedia.org/wiki/Motion_JPEG).

`-an` disables audio.
