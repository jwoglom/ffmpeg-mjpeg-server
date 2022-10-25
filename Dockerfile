FROM sebp/lighttpd

RUN /bin/sh -c "apk add --update --no-cache ffmpeg && rm -rf /var/cache/apk/*"

COPY mod_cgi.conf /etc/lighttpd/mod_cgi.conf
RUN ["sh", "-c", "echo -e 'include \"mod_cgi.conf\"' >> /etc/lighttpd/lighttpd.conf"]

RUN mkdir -p /var/www/html
RUN mkdir -p /var/www/cgi-bin

COPY index.html /var/www/html/
COPY stream /var/www/cgi-bin/

RUN chmod +x /var/www/cgi-bin/stream

# Any optional environment variables must be set here,
# otherwise lighttpd will panic on startup because the
# environment variables don't exist.
CMD ["sh", "-c", "FFMPEG_INPUT_OPTIONS=$FFMPEG_INPUT_OPTIONS FFMPEG_OUTPUT_OPTIONS=$FFMPEG_OUTPUT_OPTIONS start.sh"]
