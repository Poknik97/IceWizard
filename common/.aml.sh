#libicepower~e5456320-5391-11e3-8f96-0800200c9a66.sh
osp_detect() {
  case $1 in
    *.conf) SPACES=$(sed -n "/^output_session_processing {/,/^}/ {/^ *music {/p}" $1 | sed -r "s/( *).*/\1/")
            EFFECTS=$(sed -n "/^output_session_processing {/,/^}/ {/^$SPACES\music {/,/^$SPACES}/p}" $1 | grep -E "^$SPACES +[A-Za-z]+" | sed -r "s/( *.*) .*/\1/g")
            for EFFECT in ${EFFECTS}; do
             SPACES=$(sed -n "/^effects {/,/^}/ {/^ *$EFFECT {/p}" $1 | sed -r "s/( *).*/\1/")
              [ "$EFFECT" != "atmos" ] && sed -i "/^effects {/,/^}/ {/^$SPACES$EFFECT {/,/^$SPACES}/ s/^/#/g}" $1
            done;;
     *.xml) EFFECTS=$(sed -n "/^ *<postprocess>$/,/^ *<\/postprocess>$/ {/^ *<stream type=\"music\">$/,/^ *<\/stream>$/ {/<stream type=\"music\">/d; /<\/stream>/d; s/<apply effect=\"//g; s/\"\/>//g; p}}" $1)
            for EFFECT in ${EFFECTS}; do
              [ "$EFFECT" != "atmos" ] && sed -ri "s/^( *)<apply effect=\"$EFFECT\"\/>/\1<\!--<apply effect=\"$EFFECT\"\/>-->/" $1
            done;;
  esac
}

patch_cfgs $MODPATH/$NAME icepower_test e5456320-5391-11e3-8f96-0800200c9a66 icepower $LIBDIR/libicepower.so
patch_cfgs $MODPATH/$NAME icepower_load bf51a790-512b-11e3-8f96-0800200c9a66 icepower $LIBDIR/libicepower.so
patch_cfgs $MODPATH/$NAME icepower_null 63509430-52aa-11e3-8f96-0800200c9a66 icepower $LIBDIR/libicepower.so
patch_cfgs $MODPATH/$NAME icepower_algo f1c02420-777f-11e3-981f-0800200c9a66 icepower $LIBDIR/libicepower.so

  [ $COUNT -gt 1 ] && return
