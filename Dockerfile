FROM <Redhat image with python3 installed and configured to hit a mirror to pypi>

RUN yum update -y && yum distribution-synchronization -y
RUN yum install -y sqlite libmemcached-devel libcurl-devel rh-nodejs4-npm git

# This is to be able to launch node as scl enable does not work with docker.
# CF : http://developers.redhat.com/products/softwarecollections/get-started-rhel7-nodejs/
ENV PATH /opt/rh/rh-nodejs4/root/usr/bin/:${PATH}
ENV LD_LIBRARY_PATH /opt/rh/rh-nodejs4/root/usr/lib64/

# To change the number of threads use
# docker run -d -e NBVIEWER_THREADS=4 -p 80:8080 nbviewer
ENV NBVIEWER_THREADS 2
EXPOSE 8080

WORKDIR /srv/nbviewer

# asset toolchain
ADD ./package.json /srv/nbviewer/

# Adds npmrc to resolve to custom mirror
ADD ./.npmrc /root/
RUN npm install .

# Python requirements
ADD ./requirements.txt /srv/nbviewer/
# Get reduced validation tracebacks from unreleased nbformat-4.1
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -e git://<path to nbformat repo>/nbformat#egg=nbformat && \
    pip freeze


# Tasks will likely require re-running everything
ADD ./tasks.py /srv/nbviewer/

# Front-end dependencies
ADD ["./nbviewer/static/bower.json", "./nbviewer/static/.bowerrc", \
     "/srv/nbviewer/nbviewer/static/"]

# RUN invoke bower
WORKDIR /srv/nbviewer/nbviewer/static
RUN ../../node_modules/.bin/bower install --allow-root --config.interactive=false

WORKDIR /srv/nbviewer

# build css
ADD . /srv/nbviewer/
RUN invoke less

# root up until now!
USER nobody

CMD ["python", "-m", "nbviewer", "--port=8080"]
