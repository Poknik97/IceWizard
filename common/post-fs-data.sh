### Michi_Nemuritor, Guitardedhero, Zackptg5 script ###
change_module() {
  if [ "$1" ]; then
    for FILE in $1; do
      chmod 666 $FILE
      echo "$2" > $FILE
      chmod 444 $FILE
    done
  fi
}

##Impedance detection by UltraM8@XDA
IDE=$(find $ROOT/sys/module -name impedance_detect_en)
change_module "$IDE" "1"

# if $MAGISK; then
  # ETC=$MODPATH/system/etc
# else
  # ETC=$SYS/etc
# fi

if [ "$ROOT" ]; then mount -o rw,remount $ROOT; else mount -o rw,remount /; fi

# ln -sf $ETC/select_mic.sh /data/data/select_mic
# ln -sf $ETC/select_output.sh /data/data/select_output
  
  AP="$(find /system /vendor -type f -name "audio_policy_configuration*.xml" | head -n 1 2>/dev/null)"

  if [ ! -d "$ROOT/odm" ] && [ "$AP" ]; then
  mkdir -p /odm/etc
  chmod 0755 /odm /odm/etc
  chown 1000.1000 /odm /odm/etc
  chcon -R u:object_r:system_file:s0 /odm
  
  if [ "$(dirname $AP)" == "$VEN/etc/audio" ]; then INC="s|.*=\"(/.*/[a-zA-Z0-9_]*.xml)\".*|\1|g"; else INC="s|.*=\"([a-zA-Z0-9_]*.xml)\".*|$(dirname $AP)/\1|g"; fi

  for POL in $AP $(grep "include href=" $AP | sed -r $INC); do
    [ -f "$POL" -a ! -e "/odm/etc/$(basename $POL)" ] && ln -sf $POL /odm/etc/
  done

 fi

if [ "$ROOT" ]; then mount -o ro,remount $ROOT; else mount -o ro,remount /; fi
