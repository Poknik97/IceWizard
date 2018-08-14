osp_detect() {
  case $1 in
    *.conf) SPACES=$(sed -n "/^output_session_processing {/,/^}/ {/^ *music {/p}" $1 | sed -r "s/( *).*/\1/")
            EFFECTS=$(sed -n "/^output_session_processing {/,/^}/ {/^$SPACES\music {/,/^$SPACES}/p}" $1 | grep -E "^$SPACES +[A-Za-z]+" | sed -r "s/( *.*) .*/\1/g")
            for EFFECT in ${EFFECTS}; do
              SPACES=$(sed -n "/^effects {/,/^}/ {/^ *$EFFECT {/p}" $1 | sed -r "s/( *).*/\1/")
              [ "$EFFECT" != "atmos" ] && sed -i "/^effects {/,/^}/ {/^$SPACES$EFFECT {/,/^$SPACES}/d}" $1
            done;;
     *.xml) EFFECTS=$(sed -n "/^ *<postprocess>$/,/^ *<\/postprocess>$/ {/^ *<stream type=\"music\">$/,/^ *<\/stream>$/ {/<stream type=\"music\">/d; /<\/stream>/d; s/<apply effect=\"//g; s/\"\/>//g; p}}" $1)
            for EFFECT in ${EFFECTS}; do
              [ "$EFFECT" != "atmos" ] && sed -i "s/^( *)<apply effect=\"$EFFECT\"\/>/d" $1
            done;;
  esac
}

keytest() {
  ui_print " - Vol Key Test -"
  ui_print "   Press Vol Up:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseconfig() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while (true); do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseconfigold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $INSTALLER/common/keycheck
  $INSTALLER/common/keycheck
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "   Vol key not detected!"
    abort "   Use name change method in TWRP"
  fi
}

# Tell user aml is needed if applicable
if $MAGISK && ! $SYSOVERRIDE; then
  if $BOOTMODE; then LOC="/sbin/.core/img/*/system $MOUNTPATH/*/system"; else LOC="$MOUNTPATH/*/system"; fi
  FILES=$(find $LOC -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" 2>/dev/null)
  if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
    ui_print " "
    ui_print "   ! Conflicting audio mod found!"
    ui_print "   ! You will need to install !"
    ui_print "   ! Audio Modification Library !"
    sleep 3
  fi
fi

CONF1=false; CONF2=false; CONF3=false; CONF4=false; CONF0=false; FULL=false; PURE=false
# GET STOCK/LIMIT FROM ZIP NAME
case $(basename $ZIP) in
  *conf1*|*Conf1*|*CONF1*) CONF1=true;;
  *conf2*|*Conf2*|*CONF2*) CONF2=true;;
  *conf3*|*Conf3*|*CONF3*) CONF3=true;;
  *conf4*|*Conf4*|*CONF4*) CONF4=true;;
  *conf0*|*Conf0*|*CONF0*) CONF0=true;;
  *full*|*Full*|*FULL*) FULL=true;;
  *pure*|*Pure*|*PURE*) PURE=true;;
esac

# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
KEYCHECK=$INSTALLER/common/keycheck
chmod 755 $KEYCHECK

ui_print " "
ui_print "   Removing remnants from past Ice installs..."
# Uninstall existing Ice installs
ICEAPPS=$(find /data/app -type d -name "*dk.icepower.icesound*" -o -name "*com.asus.maxxaudio*" -o -name "*com.asus.music*")
if [ "$ICEAPPS" ]; then
  if $BOOTMODE; then
    for APP in ${ICEAPPS}; do
      case $APP in
        *dk.icepower.icesound*) pm uninstall dk.icepower.icesound >/dev/null 2>&1;;
        *com.asus.maxxaudio*) pm uninstall *com.asus.maxxaudio* >/dev/null 2>&1;;
        *com.asus.music) pm uninstall *com.asus.music* >/dev/null 2>&1;;
      esac
    done
  else
    for APP in ${ICEAPPS}; do
      rm -rf $APP
    done
  fi
fi
# Remove remnants of any old IceSound installs
for REMNANT in $(find /data -name "*IceSoundService*" -o -name "*AudioWizard*" -o -name "*AsusMusic*" -o -name "*dk.icepower.icesound*" -o -name "*com.asus.maxxaudio*" -o -name "*com.asus.music*"); do
  if [ -d "$REMNANT" ]; then
    rm -rf $REMNANT
  else
    rm -f $REMNANT
  fi
done

ui_print ""
if [ "$CONF1" == false -a "$CONF2" == false -a "$CONF3" == false -a "$CONF4" == false -a "$CONF0" == false ] || [ "$FULL" == false -a "$PURE" == false ]; then
  if keytest; then
    FUNCTION=chooseconfig
  else
    FUNCTION=chooseconfigold
    ui_print "   ! Legacy device detected! Using old keycheck method"
    ui_print " "
    ui_print "- Vol Key Programming -"
    ui_print "   Press Vol Up Again:"
    $FUNCTION "UP"
    ui_print "   Press Vol Down"
    $FUNCTION "DOWN"
  fi

  if ! $PURE && ! $FULL; then
    if [ $API -ge 26 ] && [ ! "$OP3OOS" ]; then
      ui_print " "
      ui_print "   PureIcesound compatible device "
      PURE=true
    else
      ui_print " "
      ui_print "   Fully compatible device "
      ui_print "   Choose which version of IceSound you want installed:"
      ui_print "   PureIceSound, or IceWizard"
      ui_print " "
      ui_print "   Vol+ = PureICE  Vol- = IceWizard"
      if $FUNCTION; then
        PURE=true
      else
        FULL=true
      fi
    fi
  else
    ui_print "   Version specified in zipname!"
  fi

  if ! $CONF1 && ! $CONF2 && ! $CONF3 && ! $CONF4 && ! $CONF0; then
    ui_print " "
    ui_print "   Choose which config you want installed:"
    ui_print "   Processing may either occur or not occur"
    ui_print "   depending which config is used."
    ui_print " "
    ui_print "   Vol+ = Config 1  Vol- = Config 2, 3 or 4"
    if $FUNCTION; then
      CONF1=true
    else
      ui_print " "
      ui_print "   Choose which config you want installed:"
      ui_print "   Vol+ = Config 2 Vol- = Config 3 or 4"
      if $FUNCTION; then
        CONF2=true
      else
        ui_print " "
        ui_print "   Choose which config you want installed:"
        ui_print "   Vol+ = Config 3 Vol- = Config 4 or No Config"
        if $FUNCTION; then
          CONF3=true
        else
          ui_print " "
          ui_print "   Choose which config you want installed:"
          ui_print "   Vol+ = Config 4 Vol- = No Config"
          if $FUNCTION; then
            CONF4=true
          else
            CONF0=true
          fi
        fi
      fi
    fi
  else
    ui_print "   Config specified in zipname!"
  fi
else
  ui_print "   Version and config specified in zipname!"
fi
# Prep terminal script
sed -i -e "s|<MAGISK>|$MAGISK|" -e "s|<PROP>|$PROP|" -e "s|<MODPROP>|$MOD_VER|" -e "s|<ROOT>|$ROOT|" $INSTALLER/system/xbin/icewizard
if $MAGISK; then
  sed -i -e "s|$MOUNTPATH|/sbin/.core/img|g" -e "s|<MODPATH>|/sbin/.core/img/IceWizard|" $INSTALLER/system/xbin/icewizard
else
  sed -i "s|<MODPATH>|\"\"|" $INSTALLER/system/xbin/icewizard
fi

ui_print " "
ui_print "   Installing Custom Presets (Thanks Arise Team!!!)"
ui_print "   Please Run su icewizard in Terminal to Change"
ui_print "    Presets/Configs/Props"
ui_print "   No Need To Reboot After Changing. IceSound"
ui_print "    will be Killed to Apply Preset/Config"
ui_print "   A Reboot is required to Apply Prop"
cp -rf $INSTALLER/custom/IceWizard $SDCARD
if [ $SDCARD/IceWizard ]; then
  ui_print "   All Custom Presets and Confgs Have Been"
  ui_print "    Successfully Copied to $SDCARD"
fi

if $CONF1; then
  ui_print " - Config1 selected."
  sed -ri "s/version=(.*)/version=\1 Config (1)/" $INSTALLER/module.prop
  sed -ri "s/Config=(.*)/Config=\1 Config = 1/" $INSTALLER/system/etc/icesoundconfig.def
elif $CONF2; then
  ui_print " - Config2 selected."
  sed -ri "s/version=(.*)/version=\1 Config (2)/" $INSTALLER/module.prop
  sed -i "s/session0 false/session0 true/" $INSTALLER/system/etc/icesoundconfig.def
  sed -ri "s/Config=(.*)/Config=\1 Config = 2/" $INSTALLER/system/etc/icesoundconfig.def
elif $CONF3; then
  ui_print " - Config3 selected."
  sed -ri "s/version=(.*)/version=\1 Config (3)/" $INSTALLER/module.prop
  sed -i "s/session0 false/session0 true/" $INSTALLER/system/etc/icesoundconfig.def
  sed -i "s/fasttrack true/fasttrack false/" $INSTALLER/system/etc/icesoundconfig.def
   sed -ri "s/Config=(.*)/Config=\1 Config = 3/" $INSTALLER/system/etc/icesoundconfig.def
elif $CONF4; then
  ui_print " - Config4 selected."
  sed -ri "s/version=(.*)/version=\1 Config (4)/" $INSTALLER/module.prop
  sed -i "s/session0 false/session0 true/" $INSTALLER/system/etc/icesoundconfig.def
  sed -i "s/a2dpfasttrackoutputs 4/a2dpfasttrackoutputs 8/" $INSTALLER/system/etc/icesoundconfig.def
  sed -i "s/fasttrackoutputs 4/fasttrackoutputs 8/" $INSTALLER/system/etc/icesoundconfig.def
  sed -i "s/usbaudiofasttrackoutputs 4/usbaudiofasttrackoutputs 8/" $INSTALLER/system/etc/icesoundconfig.def
 sed -ri "s/Config=(.*)/Config=\1 Config = 4/" $INSTALLER/system/etc/icesoundconfig.def
elif $CONF0; then
  ui_print " - No Config Selected."
  sed -ri "s/version=(.*)/version=\1 Config (0)/" $INSTALLER/module.prop
  rm -f $INSTALLER/system/etc/icesoundconfig.def
fi

if $FULL; then
  ui_print " - ICEWizard selected."
  sed -ri "s/version=(.*)/version=\1 Preset (STOCK)/" $INSTALLER/module.prop
  sed -ri "s/name=(.*)/name=\1 (ICEWizard)/" $INSTALLER/module.prop
  cp -rf $INSTALLER/custom/AddonApp/AudioWizard $INSTALLER/system/priv-app
  mkdir -p $INSTALLER/system/app
  cp -rf $INSTALLER/custom/AddonApp/AudioWizardView $INSTALLER/system/app
	#cp -rf $INSTALLER/custom/AddonApp/AudioWizardView $INSTALLER/system/priv-app
  cp -rf $INSTALLER/custom/AddonApp/permissions $INSTALLER/system/etc
  if [ $API -ge 26 ]; then
    ui_print "  Full ICEWizard compatible device detected!"
    ui_print "   Installing addon content!"
    sed -ri "s/version=(.*)/version=\1 Preset (STOCK)/" $INSTALLER/module.prop
		sed -ri "s/name=(.*)/name=\1 (ICEWizard)/" $INSTALLER/module.prop
    cp -rf $INSTALLER/custom/Addon/system $INSTALLER
    sed -i "s/icesound_no_aw true/icesound_no_aw false/" $INSTALLER/system/etc/icesoundconfig.def
  elif [ $API -eq 23 ]; then
    ui_print "  Full ICEWizard compatible device detected!"
    ui_print "   Installing addon content!"
    sed -ri "s/version=(.*)/version=\1 Preset (STOCK)/" $INSTALLER/module.prop
		sed -ri "s/name=(.*)/name=\1 (ICEWizard)/" $INSTALLER/module.prop
    rm -rf $INSTALLER/system/lib/soundfx/libicepower.so
    cp -f $INSTALLER/custom/Nougat/lib/$ABI/libicepower.so $INSTALLER/system/lib/soundfx/libicepower.so
    mkdir $INSTALLER/system/app
    cp -rf $INSTALLER/custom/AddonN/system $INSTALLER
    sed -i "s/icesound_no_aw true/icesound_no_aw false/" $INSTALLER/system/etc/icesoundconfig.def
  elif [ $API -le 25 ]; then
    ui_print "  Full ICEWizard compatible device detected!"
    ui_print "   Installing addon content!"
    sed -ri "s/version=(.*)/version=\1 Preset (STOCK)/" $INSTALLER/module.prop
		sed -ri "s/version=(.*)/version=\1 Lib (NOUGAT)/"
    mkdir $INSTALLER/system/app
    cp -rf $INSTALLER/custom/AddonN/system $INSTALLER
    sed -i "s/icesound_no_aw true/icesound_no_aw false/" $INSTALLER/system/etc/icesoundconfig.def
		ui_print "   IF AUDIOWIZARD DOES NOT PROCESS/CHANGE AUDIO WHEN CHANGING PRESETS IN THE
		AUDIOWIZARD APP, PLEASE RUN su icewizard IN TERMINAL AND CHOOSE ICESOUND LIBS AND SWITCH TO THE NOUGAT LIB"
	fi
  if [ "$ABI" == "x86" ] || [ "$ABILONG" == "x86_64" ]; then
    ui_print "  x86 device detected!"
    ui_print "   Installing x86 addon content!"
    sed -ri "s/version=(.*)/version=\1 Preset (STOCK)/" $INSTALLER/module.prop
		sed -ri "s/name=(.*)/name=\1 (ICEWizard)/" $INSTALLER/module.prop
    cp -rf $INSTALLER/custom/WizardX86/app $INSTALLER/system
    cp -f $INSTALLER/custom/Nougat/lib/x86/libicepower.so $INSTALLER/system/lib/soundfx/libicepower.so
    sed -i "s/icesound_no_aw true/icesound_no_aw false/" $INSTALLER/system/etc/icesoundconfig.def
  fi
else
  ui_print " - PureICE selected."
  sed -ri "s/version=(.*)/version=\1 Preset (STOCK)/" $INSTALLER/module.prop
  sed -ri "s/name=(.*)/name=\1 (PUREICE)/" $INSTALLER/module.prop
fi

ui_print "   Patching existing audio_effects files..."
for OFILE in ${CFGS}; do
  FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
  cp_ch_nb $ORIGDIR$OFILE $FILE 0644 false
  osp_detect $FILE
  case $FILE in
    *.conf) sed -i "/icepower {/,/}/d" $FILE
            sed -i "/icepower_algo {/,/}/d" $FILE
#            sed -i "/icepower_eq {/,/}/d" $FILE
            sed -i "/icepower_null {/,/}/d" $FILE
            sed -i "/icepower_load {/,/}/d" $FILE
            sed -i "/icepower_test {/,/}/d" $FILE
            sed -i "/^output_session_processing {/,/^}/ {/music_helper {/,/}/ s/^/#$MODID/g}" $FILE
            sed -i "s/^libraries {/libraries {\n  icepower { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libicepower.so\n  } #$MODID/g" $FILE
            sed -i "s/^effects {/effects {\n  icepower_test { #$MODID\n    library icepower\n    uuid e5456320-5391-11e3-8f96-0800200c9a66\n  } #$MODID/g" $FILE
            sed -i "s/^effects {/effects {\n  icepower_load { #$MODID\n    library icepower\n    uuid bf51a790-512b-11e3-8f96-0800200c9a66\n  } #$MODID/g" $FILE
            sed -i "s/^effects {/effects {\n  icepower_null { #$MODID\n    library icepower\n    uuid 63509430-52aa-11e3-8f96-0800200c9a66\n  } #$MODID/g" $FILE
#            sed -i "s/^effects {/effects {\n  icepower_eq { #$MODID\n    library icepower\n    uuid 50dbef80-4ad4-11e3-8f96-0800200c9a66\n  } #$MODID/g" $FILE
            sed -i "s/^effects {/effects {\n  icepower_algo { #$MODID\n    library icepower\n    uuid f1c02420-777f-11e3-981f-0800200c9a66\n  } #$MODID/g" $FILE;;
    *.xml) sed -i "/icepower/d" $FILE
            sed -i "/icepower_algo {/,/}/d" $FILE
#            sed -i "/icepower_eq {/,/}/d" $FILE
            sed -i "/icepower_null {/,/}/d" $FILE
            sed -i "/icepower_load {/,/}/d" $FILE
            sed -i "/icepower_test {/,/}/d" $FILE
            sed -i "s/^            <apply effect=\"music_helper\"\/>/            <!--apply effect=\"music_helper\"\/-->/g" $FILE
            sed -i "/<libraries>/ a\        <library name=\"icepower\" path=\"libicepower.so\"\/><!--$MODID-->" $FILE
            sed -i "/<effects>/ a\        <effect name=\"icepower_test\" library=\"icepower\" uuid=\"e5456320-5391-11e3-8f96-0800200c9a66\"\/><!--$MODID-->" $FILE
            sed -i "/<effects>/ a\        <effect name=\"icepower_load\" library=\"icepower\" uuid=\"bf51a790-512b-11e3-8f96-0800200c9a66\"\/><!--$MODID-->" $FILE
            sed -i "/<effects>/ a\        <effect name=\"icepower_null\" library=\"icepower\" uuid=\"63509430-52aa-11e3-8f96-0800200c9a66\"\/><!--$MODID-->" $FILE
#            sed -i "/<effects>/ a\        <effect name=\"icepower_eq\" library=\"icepower\" uuid=\"50dbef80-4ad4-11e3-8f96-0800200c9a66\"\/><!--$MODID-->" $FILE
            sed -i "/<effects>/ a\        <effect name=\"icepower_algo\" library=\"icepower\" uuid=\"f1c02420-777f-11e3-981f-0800200c9a66\"\/><!--$MODID-->" $FILE;;
    esac
done

ui_print " " 
ui_print "THANKS FOR USING ICESOUND AND THE SUPPORT"
ui_print "   ENJOY AWESOME SOUND"
ui_print " "
