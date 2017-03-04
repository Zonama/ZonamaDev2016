# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -f ~/00README ]; then
  cat ~/00README
fi

if [ -f ~/.firsttime ]; then
  echo
  echo "** Looks like this is your first visit!"
  echo
  echo "** I'm going to run 'getstarted' for you, you can run it again later if you want to restart your setup"
  echo
  if /usr/bin/tty -s; then
    :
  else
    export DISPLAY=':0.0'
  fi
  ~/bin/getstarted fresh
fi
