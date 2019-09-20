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
FROM python:3.6 as base_py36
RUN mkdir sacred
WORKDIR sacred
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY dev-requirements.txt ./
RUN pip install -r dev-requirements.txt

#------------------------------------------------------------------------------
FROM base_py36 as py36
COPY ./ ./
RUN pytest

#------------------------------------------------------------------------------
FROM python:3.7 as minimal_install_py37
RUN mkdir sacred
WORKDIR sacred
COPY requirements.txt ./
RUN pip install -r requirements.txt

#------------------------------------------------------------------------------
FROM minimal_install_py37 as py37
COPY dev-requirements.txt ./
RUN pip install -r dev-requirements.txt
COPY ./ ./
RUN pytest

#------------------------------------------------------------------------------
FROM base_py36 as tensorflow_112
RUN pip install tensorflow==1.12.3
COPY ./ ./
RUN pytest tests/test_stflow tests/test_optional.py

#------------------------------------------------------------------------------
FROM base_py36 as tensorflow_113
RUN pip install tensorflow==1.13.2
COPY ./ ./
RUN pytest tests/test_stflow tests/test_optional.py

#------------------------------------------------------------------------------
FROM base_py36 as tensorflow_114
RUN pip install tensorflow==1.14.0
COPY ./ ./
RUN pytest tests/test_stflow tests/test_optional.py

#------------------------------------------------------------------------------
FROM base_py36 as tensorflow_2
RUN pip install tensorflow==2.0.0-rc0
COPY ./ ./
RUN pytest tests/test_stflow

#------------------------------------------------------------------------------
FROM minimal_install_py37 as setup
RUN pip install pytest==4.3.0 mock==2.0.0 moto==1.3.13
COPY ./ ./
RUN pytest

#------------------------------------------------------------------------------
FROM minimal_install_py37 as flake8
RUN pip install flake8 pep8-naming mccabe flake8-docstrings
COPY ./ ./
RUN flake8 sacred

#------------------------------------------------------------------------------
FROM minimal_install_py37 as black
RUN pip install git+https://github.com/psf/black
COPY ./ ./
RUN black --check sacred/ tests/

#------------------------------------------------------------------------------
FROM python

# dummy copy to force all env to run
COPY --from=py35 /sacred/setup.py ./
COPY --from=py36 /sacred/setup.py ./
COPY --from=py37 /sacred/setup.py ./
COPY --from=tensorflow_112 /sacred/setup.py ./
COPY --from=tensorflow_113 /sacred/setup.py ./
COPY --from=tensorflow_114 /sacred/setup.py ./
COPY --from=tensorflow_2 /sacred/setup.py ./
COPY --from=setup /sacred/setup.py ./
COPY --from=flake8 /sacred/setup.py ./
COPY --from=black /sacred/setup.py ./
