FROM sebp/lighttpd

RUN /bin/sh -c "apk add --update --no-cache ffmpeg && rm -rf /var/cache/apk/*"

COPY mod_cgi.conf /etc/lighttpd/mod_cgi.conf
RUN ["sh", "-c", "echo -e 'include \"mod_cgi.conf\"' >> /etc/lighttpd/lighttpd.conf"]
RUN mkdir -p /var/www/cgi-bin

COPY stream.template /
COPY build_stream.sh /
RUN chmod +x /build_stream.sh
CMD ["sh", "-c", "/build_stream.sh > /var/www/cgi-bin/stream && chmod +x /var/www/cgi-bin/stream &&/usr/local/bin/start.sh"]
