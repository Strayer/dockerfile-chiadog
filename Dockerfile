FROM python:3.9-buster AS install

ARG CHIADOG_GIT_REF=da1a904466e6df25b930d58cefb70eca6dce4a3a
ARG VIRTUAL_ENV=/venv
ARG WORKDIR=/chiadog

ARG YQ_VERSION=v4.7.1
ARG YQ_BINARY=yq_linux_amd64
ARG YQ_HASH=16a443be2913c206b95e7bf53c086ba213a77955a31f2f134f41a529c5c62aa4

# Install yq
RUN curl -L -O "https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/$YQ_BINARY" \
  && echo "$YQ_HASH  $YQ_BINARY" > checksum \
  && shasum -c checksum \
  && mv "$YQ_BINARY" /usr/local/bin/yq \
  && chmod +x /usr/local/bin/yq \
  && rm checksum

# Setup virtualenv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install --no-cache-dir -U pip setuptools

# Clone chiadog
RUN git clone https://github.com/martomi/chiadog.git $WORKDIR
WORKDIR $WORKDIR
RUN git checkout "$CHIADOG_GIT_REF"

# Install chiadog dependencies
RUN pip install --no-cache-dir -r requirements.txt

###

FROM python:3.9-slim-buster AS production

ARG VIRTUAL_ENV=/venv
ARG WORKDIR=/chiadog
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY --from=install $VIRTUAL_ENV/ $VIRTUAL_ENV/
COPY --from=install $WORKDIR/ $WORKDIR/
COPY --from=install /usr/local/bin/yq /usr/local/bin/yq
COPY entrypoint.sh /entrypoint.sh

WORKDIR $WORKDIR

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "python3", "main.py", "--config", "/tmp/config.yaml" ]
