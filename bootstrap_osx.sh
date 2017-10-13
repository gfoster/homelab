#!/bin/bash

# enable passwordless sudo

echo "enabling sudo"
sudo sed -ie 's/^#includedir \(\/private\/etc\/sudoers.d\)/includedir \1/' /etc/sudoers
mkdir /private/etc/sudoers.d
echo "${USER}\t ALL=(ALL) NOPASSWD:ALL" > /private/etc/sudoers.d/${USER}

# set up Apple command line tools
xcode-select -p >/dev/null 2>&1

if [[ $? -ne 0 ]]; then
    echo "Installing Mac OS developer command line tools"
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
    PROD=$(softwareupdate -l |
               grep "\*.*Command Line" | \
               tail -n 1 | awk -F"*" '{print $2}' | \
               sed -e 's/^ *//' | \
               tr -d '\n')
    softwareupdate -i "${PROD}" --verbose;
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
else
    echo "Mac OS developer command line tools already installed skipping..."
fi

# Install Homebrew
if [ -x /usr/local/bin/brew ]; then
  echo "Homebrew is already installed, updating..."
  /usr/local/bin/brew update
else
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install Ansible
DEPS=("ansible")
for DEP in "${DEPS[@]}"; do
  echo "Installing ${DEP}"
  /usr/local/bin/brew install "${DEP}" --force > /dev/null
done

# run the ansible playbook

/usr/local/bin/ansible-playbook -i hosts -c local osx_provision.yml
