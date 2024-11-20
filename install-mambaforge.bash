#!/bin/bash
# This downloads and installs a pinned version of mambaforge
set -ex

cd $(dirname $0)
MAMBAFORGE_VERSION=24.9.2-0

URL="https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Miniforge3-${MAMBAFORGE_VERSION}-Linux-x86_64.sh"
INSTALLER_PATH=/tmp/mambaforge-installer.sh

# make sure we don't do anything funky with user's $HOME
# since this is run as root
#unset HOME

export XDG_CACHE_HOME=$(mktemp)

wget --quiet $URL -O ${INSTALLER_PATH}
chmod +x ${INSTALLER_PATH}

bash ${INSTALLER_PATH} -f -b -p ${CONDA_DIR}
export PATH="${CONDA_DIR}/bin:$PATH"

# Do not attempt to auto update conda or dependencies
conda config --system --set auto_update_conda false
conda config --system --set show_channel_urls true

# empty conda history file,
# which seems to result in some effective pinning of packages in the initial env,
# which we don't intend.
# this file must not be *removed*, however
echo '' > ${CONDA_DIR}/conda-meta/history

# Clean things out!
conda clean --all -f -y

# Remove the big installer so we don't increase docker image size too much
rm ${INSTALLER_PATH}

# Remove the pip cache created as part of installing mambaforge
rm -rf ${XDG_CACHE_HOME}

conda list -n root
