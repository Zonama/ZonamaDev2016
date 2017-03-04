# BaseBox

Tools to build and publish a new basebox for the ZonamaDev environment

## Building the "Base Box" from scratch

Download and install Git, VirtualBox and Vagrant

## Windows Host

### Downloads
* Github's Git for Windows: https://git-for-windows.github.io/
* VirtualBox for Windows: https://www.vagrantup.com/downloads.html
* Vagrant for Windows: https://www.vagrantup.com/downloads.html
 
Launch Git Bash: Start -> Programs -> Git Bash
or
Right click in desired directory -> Bit Bash

# Once you have cloned and have a bash shell:

```
git clone https://github.com/lordkator/ZonamaDev.git
cd ZonamaDev/basebox
# Once to install the plugins
vagrant up
# One more time to get it going
vagrant up
```

Currently this takes about 10 mins on a fairly fast internet connection and nice sized box.

Once you have it up you need to do a couple things to prep for packaging:

1) Resize the virtualbox to 1280x800 using the "Display Size" icon on the bottom of the virtual box window

2) Launch eclipse and clean up any positioning then close it.

3) Launch Chrome and verify it's positioned properly then close it.

4) Clean up the box for packaging: exec sudo ~vagrant/ZonamaDev/basebox/scripts/package-prep.sh "0.0.X" (next box version number)

5) When the box halts from your host run: vagrant package

6) Update the box in Altlas, don't forget to "Release" the version once it's setup.

7) Update ../fasttrack/Vagrant with the new version number

8) Test on a fasttrack setup

9) Update git with new Vagrant files etc: git add ../fasttrack/Vagrantfile;git commit -m "New version 0.0.x"; git push

10) Tell lots of people, good luck!
