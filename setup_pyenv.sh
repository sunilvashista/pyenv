#!/bin/bash
# Version 0.1

# Function to install dependencies on Debian and Redhat based systems
installDependentPackages() {
  if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
    liblzma-dev git
  elif [ -f /etc/redhat-release ]; then
    sudo yum install -y gcc zlib-devel bzip2 bzip2-devel readline-devel \
    sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel \
    findutils git
  fi
}

set -e

if [ -z "$PYENV_ROOT" ]; then
  if [ -z "$HOME" ]; then
    printf "$0: %s\n" \
      "Either \$PYENV_ROOT or \$HOME must be set to determine the install location." \
      >&2
    exit 1
  fi
  export PYENV_ROOT="${HOME}/.pyenv"
fi

colorize() {
  if [ -t 1 ]; then printf "\e[%sm%s\e[m" "$1" "$2"
  else echo -n "$2"
  fi
}

# Checks for `.pyenv` file, and suggests to remove it for installing
if [ -d "${PYENV_ROOT}" ]; then
  { echo
    colorize 1 "WARNING"
    echo ": Cannot proceed with installation. Kindly remove the '${PYENV_ROOT}' directory first."
    echo
  } >&2
  exit 1
fi

failedCheckout() {
  echo "Failed to git clone $1"
  exit -1
}

checkout() {
  [ -d "$2" ] || git -c advice.detachedHead=0 clone --branch "$3" --depth 1 "$1" "$2" || failedCheckout "$1"
}

# Function to install pyenv
# Uses standard script provided by Pyenv Documentation
installPyenv() {
  export GITHUB="https://github.com/"
  checkout "${GITHUB}pyenv/pyenv.git"            "${PYENV_ROOT}"                           "${PYENV_GIT_TAG:-master}"
  checkout "${GITHUB}pyenv/pyenv-doctor.git"     "${PYENV_ROOT}/plugins/pyenv-doctor"      "master"
  checkout "${GITHUB}pyenv/pyenv-update.git"     "${PYENV_ROOT}/plugins/pyenv-update"      "master"
  checkout "${GITHUB}pyenv/pyenv-virtualenv.git" "${PYENV_ROOT}/plugins/pyenv-virtualenv"  "master"

  if ! command -v pyenv 1>/dev/null; then
    { echo
      colorize 1 "WARNING"
      echo ": seems you still have not added 'pyenv' to the load path."
      echo
    } >&2

    { # Without args, `init` commands print installation help
      "${PYENV_ROOT}/bin/pyenv" init || true
      "${PYENV_ROOT}/bin/pyenv" virtualenv-init || true
    } >&2
  fi

  # Add pyenv to bashrc
  echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
  echo 'eval "$(pyenv init -)"' >> ~/.bashrc
  echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

  # Apply changes to current shell session
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}

# Main script
main() {
  echo "INFO: pyenv is being installed for User: $(whoami)"
  echo "QUERY: This script will install pyenv in $HOME/.pyenv. Do you want to proceed? (Y/N)"
  read answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    installDependentPackages
    installPyenv
    echo "INFO: pyenv installation completed. Please restart your terminal or run 'source ~/.bashrc' to apply changes."
  else
    echo "INFO: Installation aborted by user."
  fi
}

main
