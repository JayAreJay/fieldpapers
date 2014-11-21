Using Vagrant for development
===

To make Field Papers easier to install and test, you can use [Vagrant](vagrantup.com).

Requirements
---
For development on OSX, you need to install:

* [Vagrant](vagrantup.com)
* [VirtualBox](https://www.virtualbox.org)
* ansible (`brew install ansible`)

Setup
---
From the root fieldpapers directory, run `vagrant up`.

This will create, provision, and launch the virtual machine.

_This part will take a while..._

Log into the virtual machine with `vagrant ssh`

You will need to fix one thing (we will fix this in the Vagrant installer soon):

```
sudo pip install --upgrade requests 
```

When it is done go to:
`http://localhost:8999` where you will see a directory listing. If so, you are ready to head over to [the Field Papers section of INSTALL.md](https://github.com/stamen/fieldpapers/blob/master/INSTALL.md#field-papers). Do everything those instructions tell you to do after the "Field Papers" section (after the first `git clone` instructions, which will already be done.)


Logging
-------
From the fieldpapers checkout on your host machine

*Apache error log:*
`vagrant ssh -c "tail -f /var/log/apache2/error.log"`

*System log file:*
`vagrant ssh -c "tail -f /var/log/syslog"`

*Celery logging*
`vagrant ssh -c "screen -r celery"`

