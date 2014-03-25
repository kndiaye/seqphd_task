Windows Vista/7 Installation Notes (64-bit)

Although our lab does not yet have much experience with Windows Vista/7, we were able to successfully install the software described above using the procedure described below (using MATLAB 7.7-R2008b):

1. Log in as a user with Administrator privileges.
2. Disable UAC (User Account Control).  An easy way to do this in Windows Vista is to: Start-Run-MSCONFIG. Select the Tools tab, scroll down to the option for "Disable UAC" and select it. Next, press the "Launch" button. You must then RESTART the system for this change to take effect.
3. Download and copy the inpoutx64.dll file to the C:\WINDOWS\SYSTEM32 directory.
4. Download the io64.mexw64, config_io.m, inp.m and outp,m files to a working directory of your choice. This directory will be added to your MATLAB path in step-6 below.
5. Start MATLAB in "Run as Administrator" mode (Right-click icon and select "Run as Administrator").
6. Add the directory containing the downloaded m-files to your MATLAB path via the File|Set Path|Add with Subfiles... menu command.
7. Run "config_io" from the MATLAB command window.  If there's no error message at this point, you've successfully installed the software.
8. Optional: If you need to re-enable UAC (User Account Control), follow the instructions in step-2 but select "Enable UAC" instead of "Disable UAC".

2014-02-26, KND:
It also works on Win7 as a mere non-admin user without steps 1,2,5(run matlab normally),8
