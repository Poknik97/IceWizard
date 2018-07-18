# Universal ICESound Magisk Module

## Installation instructions
 - Flash module, choose prop/config, profit!
 - Flash module via flashfire will not work. please use zipname to install with flashfire. Otherwise use twrp or magisk

## Troubleshooting
 - If stuck at the bootloader simply reboot once and see if boot resumes. If boot does not occur, power down/enter fastboot then boot again.
 - if flash fails, provide recovery logs .
 - if boot fails, provide device logs and magisk logs.
 - always make a nandroid backup before flashing test-builds.
 - when bootlooping, flash zip a second time to uninstall


## Sources and used/needed tools
 - [Magisk](https://github.com/topjohnwu/Magisk) by [topjohnwu](https://forum.xda-developers.com/member.php?u=4470081)
 - [Magisk module template](https://github.com/topjohnwu/magisk-module-template) by [topjohnwu](https://forum.xda-developers.com/member.php?u=4470081)
 - [AML](https://forum.xda-developers.com/apps/magisk/module-audio-modification-library-t3579612)
 - [Unity](https://github.com/Zackptg5/Unity)
 - [Terminal-Debloater](https://github.com/Magisk-Modules-Repo/terminal_debloater_magisk) by [veez21](https://forum.xda-developers.com/member.php?u=7296895)
 - I used the debloater terminal script as a template for my terminal script. credit to @veez21

## Changelog

v7.5
 - Fix configs not working again (accidentally deleted stock config)
 - Make install.sh more effiecent (thanks zackptg5)
 - Fix the massive service.sh to only include the needed sepolicies
 
v7.4
 - Unity 1.5.5

v7.3
 - hopefully fix configs by reverting config fixes from 7.2

v7.2
 - fix Typos
 - dont kill ice anymore. just stop/start service
 - fix config files
 - forgot to delete .aml.sh
 - fix killall to not lose sound (sorry about that)
 - Added a no config option
 - hopefully fix config/preset stacking in module.prop
 - Add a new Preset (Crystalline) thanks to @DeadRoEd
 - Fix menu not clearing properally
 - add colors,dividers,titles
 - fix killall progessbars
 - fix not installing properally
 - fix mod_head
 - remove not needed .aml.sh
 - comment music_helper under osp
 - fix configs/presets "stacking" in module.prop when changing to different config/preset



v7.1
 - Fixed reading from packages.xml

v7.0
 - Fixed bugs in terminal script 
 - Added sepolicy fix to allow terminal script to work on enforcing

v6.0 (dont know what was changed in 5.1-5.3)
 - Fixed Alot of bugs in terminal script (props work now without workaround)
 - removed zip naming scheme as noone used it anyway
 - removed prop (volume key install again yay)
 - split mod into 2 different mods (less confusing now)
 - fixed typoes/bugs/unneded spaces in installer

v5.0
 - Introduced Terminal Script  (Thanks Veez21 for an awesome terminal script template)
 - Removed everything for force full and audioflinger options
 - Revamped Install
 - New modified AudioWizard apk
 - New Priv-App Permissions for AudioWizardView (UI)
 - Too much to list - BIG UPDATE
 
v4.9
 - Fix post-fs-data finally. (op3 and 3t will finally no longer bootloop. sorry about that)
 - Fix readme
 - Add xda thread for IceWizard for support to module.prop

v4.8
 - Fix Audioflinger zipname
 - Install.sh Fixes

v4.7
 - Fix Full/Audioflinger Install
 - Add Audioflinger option to zipname

v4.6
 - Fixed Post-fs-data script to fix bootloop issues with One Plus 5/5t and kenzo devices
 - Fixed wording on audioflinger install to warn about possible bootloop choosing audioflinger
 - added credits in post-fs-data script

v4.5
 - Unity v1.5.4 update

v4.4
 - Unity v1.5.3 update
 - Remove unneeded stuff handled by unity in service.sh

v4.3
 - Add Marshmallow support. May support lower?

v4.2
 - Fix Full install

v4.1
 - Fix spacing and spacing handled by unity
 - Fix dropped semicolon
 - Fix "FI" for Full install detection

v4.0
 - Fix full install to only show on oreo devices

v3.9
 - Fix One Plus 5 Non-Install Derp

v3.8
 - Remove data/data symlink in post-fs-data
 - Fix conf3 zipname
 - Add Full AudioWizard Install via Volume keys
 - Add One Plus 5 Dectection to Not Allow Install since incompatible

v3.7
 - Add AML detection
 - Remove ALWAYSRW

v3.6
 - Sepolicy Fix

v3.5
 - Fix old Audio Patching Bug

v3.4
 - Unity v1.5.1 update

v3.3
 - Unity v1.5 update
 - fix: forgot to move ice and asusmusic apk to system/app

v3.2
 - Change AudioWizard apk to 32bit version for better compatibility and allow 32 bit devices to use it as well

v3.1
 - Force Oreo libicepower on Nougat to fix AW settings

v3.0
 - Fixed Remove Old Remnants of Past Installs. (Dalvik Cache fix)

v2.9(Beta)
 - added protected system package com.maxxaudio.audiowizard to application.xml
 - edited installer.sh so that audiowizardview app (UI) get just installed for supported devices
 - deleted ICEsoundService nougat app. Oreo app instead.
 - clean up installer
 - fixed volume keys
 - move AsusMusic apk to custom Folder

v2.8
 - fixed bugs

v2.7
 - clean up installer and add config 3
 - add oneplus 5 detection
 - move ICEsoundService apk to new folder in Custom
 - update unity

v2.6
 - fixed bugs
 - support for Wizard on X86 devices

v2.5
 - fixed bugs
 - combined op3/3t OOS addon package into main installer

v2.4
 - fixed bugs

v2.3
 - deleted system/priv-app/Audiowizard.apk
 - deleted audiowizard priv-app permissions
 - edited application.xml -> deleted package ausus Wizard package

v2.2
 - Initial release.
