# Using NbViewer in a corporate setting

Using the original nbviewer in a corporate setting as is might prove difficult,
as access to the outside world is not necessarily open and everything not necessarily available form the start

Here is a list of modifications we had to do to run NbViewer in our own environment,
hoping it might save some time to other people.

## Base image

The debian base image, while great, was not available.
We used a Redhat image instead, and changed the package installation/dependencies (see Dockerfile)

The image also contains the ca certificate used in our company.

## Python

Python 3 is preinstalled on the base image, and configured to hit an
internal mirror to Pypi. The config file is not provided, but check for pip.conf on Google

## Node

Node is installed in the Dockerfile, and we had to resort to set the PATH and LD_LIBRARY_PATH by hand,
as the command ```scl enable rh-nodejs4 bash``` does not work during the build.

CF http://developers.redhat.com/products/softwarecollections/get-started-rhel7-nodejs/

We also provide a .npmrc file to hit an internal mirror.

## Bower

Again, with bower, we provided a config file .bowerrc to hit an internal mirror instead
of the outside world. We used Artifactory for this, hence the bower-art-resolver added
in the package.json

We also had to remove components/bootstrap# in the bower.json file to make the install work

I'll be honest here : I have no idea why it did not work with components/bootstrap set up,
and if this piece is actually important, but it seems to work fine like that.

## Invoke

Invoke is installed via pip, hence added in the requirements.txt file

## Tasks.py

There was a call to pypi hardcoded in tasks.py, we changed it to use pip instead :
this way, the conf of pip is used. I'll probably to a PR on this.

## The end

I think I covered everything, let me know if you want more infos or details.
