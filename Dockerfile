# OCRmyPDF
#
FROM      ubuntu:17.04

ENV PUID 1000
ENV PGID 1000
ENV OCRMYPDF_OPTIONS "--rotate-pages --deskew --clean --skip-text"
ENV LANG=C.UTF-8

COPY install-ocrmypdf-watchdog.sh /
RUN chmod +x /install-ocrmypdf-watchdog.sh \
    && /install-ocrmypdf-watchdog.sh
  
# Now copy the application in, mainly to get the test suite.
# Do this now to make the best use of Docker cache.
COPY . /application
RUN . /appenv/bin/activate; \
  pip install -r /application/test_requirements.txt \
  && rm -rf /tmp/* /var/tmp/* /root/* /application/ocrmypdf

RUN useradd docker \
  && mkdir /home/docker \
  && chown docker:docker /home/docker

COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh \
  && echo "" > /home/docker/processfile.sh \
  && chmod +x /home/docker/processfile.sh

VOLUME ["/hot-folder", "/archive"]
WORKDIR /hot-folder

ENTRYPOINT ["/docker-entrypoint.sh"]