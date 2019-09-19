# syntax = docker/dockerfile:experimental

FROM python:3.5 as py35

RUN mkdir sacred
WORKDIR sacred
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY dev-requirements.txt ./
RUN pip install -r dev-requirements.txt
COPY ./ ./
RUN pytest

#------------------------------------------------------------------------------
FROM python:3.6 as py36

RUN mkdir  sacred
WORKDIR sacred
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY dev-requirements.txt ./
RUN pip install -r dev-requirements.txt
COPY ./ ./
RUN pytest

#------------------------------------------------------------------------------
FROM python:3.7 as py37

RUN mkdir  sacred
WORKDIR sacred
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY dev-requirements.txt ./
RUN pip install -r dev-requirements.txt
COPY ./ ./
RUN pytest

#------------------------------------------------------------------------------
FROM python

# dummy copy to force all env to run
COPY --from=py35 /sacred/setup.py ./
COPY --from=py36 /sacred/setup.py ./
COPY --from=py37 /sacred/setup.py ./
