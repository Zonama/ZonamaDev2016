# FAQ

## Login info
> username = vagrant (swgemu)  
> password = vagrant  
> root pw = 12345678  

### How do I open a file type inside Eclipse? 
File associations are done in Eclipse properties.
- Window -> Preferences -> General -> Editors -> File associations. Add..

### How do I build in eclipse?
- Right click on MMOCoreORB -> Make targets -> Build... (Shift +F9). Do this once for each step below.
 - Select configure first
 - Select clean
 - Select all

### How do I enable an admin account?
#### *Deprecated in emuyoda*
- In MySQL Workbench, go to: 
- Schemata -> swgemu -> accounts -> admin_level -> change 0 to 15 -> Apply change -> Execute ->
- Then do build config again.
- Next toon created on that account will be admin.

### How do I enable the admin commands?
To enable these features in the client you will need to edit the user.cfg file in the c:\SWGEMU folder to add these 4 lines:
 > [ClientGame]  
 > 0fd345d9 = true  
 > [ClientUserInterface]  
 > debugExamine=1  
 
If the user.cfg file doesn’t exist, simply copy swgemu.cfg and rename it as user.cfg. Then, replace the contents of the new user.cfg with the contents of the table above.

You might also need to add a line in swgemu.cfg to tell the client to use the new user.cfg file:
> .include "swgemu_login.cfg"  
> .include "swgemu_live.cfg"  
> .include "swgemu_preload.cfg"  
> .include "options.cfg"  
> .include "user.cfg"      <-- THIS LINE MIGHT BE MISSING or Commented out  

Once the config files are done, totally shut down your client (if running) and restart it. 

### How do I  enable other planets?
#### *Deprecated in emuyoda*
Open the 'MMOCoreORB/bin/conf/config.lua' and navigate to the ZonesEnabled section and you will see a list off all the planets. Most are commented out using '--' as a prefix. Simply remove that prefix from the planets you wish to enable. 
Do config build of server.

### HOW TO: Run Unit Tests
SWGEmu has a growing number of unit tests that validate functionality automatically.
Jenkins runs all unit tests as part of the verification build. A commit that breaks a unit test will not be merged into the baseline.
Before pushing changes, you should always run the unit tests in your development environment. 

Run All Unit Tests
> cd /home/!username/workspace/MMOCoreORB/bin  
> ./core3 runUnitTests

Run Specific Unit Tests
>  cd /home/!username/workspace/MMOCoreORB/bin  
> ./core3 runUnitTests --gtest_filter=<FILTERSTRING>

where <FILTERSTRING> is the name of a specific test as defined in the TEST_F call. Wildcards may be used. For example --gtest_filter=LuaMobile* runs all tests in LuaMobileTest.cpp

### How do i push a change to gerrit using Eclipse?
https://www.youtube.com/watch?v=ARSuR7U-piQ

### How to report debug info concerning this devenv?

swgemu postdebug
