# This file is part of REANA.
# Copyright (C) 2017, 2018, 2019, 2020 CERN.
#
# REANA is free software; you can redistribute it and/or modify it
# under the terms of the MIT License; see LICENSE file for more details.

# Install base image and its dependencies
FROM python:3.8-slim
RUN apt-get update && \
    apt-get install -y \
      autoconf \
      automake \
      gcc \
      graphviz \
      graphviz-dev \
      imagemagick \
      libffi-dev \
      libtool \
      openssl \
      python-dev \
      python-pip \
      unzip \
      vim-tiny && \
    pip install --upgrade pip

# Install dependencies
COPY requirements.txt /code/
RUN pip install -r /code/requirements.txt

# Copy cluster component source code
WORKDIR /code
COPY . /code

# Are we debugging?
ARG DEBUG=0
RUN if [ "${DEBUG}" -gt 0 ]; then pip install -e ".[debug]"; else pip install .; fi;

# Are we building with locally-checked-out shared modules?
RUN if test -e modules/reana-commons; then pip install -e modules/reana-commons[kubernetes] --upgrade; fi

# Check if there are broken requirements
RUN pip check

# Set useful environment variables
ENV PACKTIVITY_ASYNCBACKEND=reana_workflow_engine_yadage.externalbackend:ExternalBackend:ExternalProxy \
    PYTHONPATH=/workdir \
    TERM=xterm
