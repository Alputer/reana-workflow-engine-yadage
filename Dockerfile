# This file is part of REANA.
# Copyright (C) 2017, 2018, 2019, 2020, 2021, 2022, 2023 CERN.
#
# REANA is free software; you can redistribute it and/or modify it
# under the terms of the MIT License; see LICENSE file for more details.

# Use Ubuntu LTS base image
FROM docker.io/library/ubuntu:20.04

# Use default answers in installation commands
ENV DEBIAN_FRONTEND=noninteractive

# Prepare list of Python dependencies
COPY requirements.txt /code/

# Install all system and Python dependencies in one go
# hadolint ignore=DL3008,DL3013
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
      autoconf \
      automake \
      gcc \
      graphviz \
      graphviz-dev \
      imagemagick \
      libffi-dev \
      libtool \
      make \
      openssl \
      python3.8 \
      python3.8-dev \
      python3-pip \
      unzip \
      vim-tiny && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /code/requirements.txt && \
    apt-get remove -y \
      autoconf \
      automake \
      gcc \
      graphviz-dev \
      libffi-dev \
      libtool \
      make \
      python3.8-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy cluster component source code
WORKDIR /code
COPY . /code

# Are we debugging?
ARG DEBUG=0
RUN if [ "${DEBUG}" -gt 0 ]; then pip install --no-cache-dir -e ".[debug]"; else pip install --no-cache-dir .; fi;

# Are we building with locally-checked-out shared modules?
# hadolint ignore=SC2102
RUN if test -e modules/reana-commons; then pip install --no-cache-dir -e modules/reana-commons[kubernetes] --upgrade; fi

# Check for any broken Python dependencies
RUN pip check

# Set useful environment variables
ENV PACKTIVITY_ASYNCBACKEND=reana_workflow_engine_yadage.externalbackend:ExternalBackend:ExternalProxy \
    PYTHONPATH=/workdir \
    TERM=xterm
