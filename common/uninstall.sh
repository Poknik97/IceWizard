if ! $MAGISK || $SYSOVERRIDE; then
  for OFILE in ${CFGS}; do
    FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
    case $FILE in
      *.conf) sed -i "/icepower { #$MODID/,/} #$MODID/d" $FILE         
                    sed -i "/icepower_algo { #$MODID/,/} #$MODID/d" $FILE      
                    sed -i "/icepower_null { #$MODID/,/} #$MODID/d" $FILE                  
                    sed -i "/icepower_load { #$MODID/,/} #$MODID/d" $FILE   
                    sed -i "/icepower_test { #$MODID/,/} #$MODID/d" $FILE;;                                
      *.xml) sed -i "/<!--$MODID-->/d" $FILE;;
    esac
  done
fi

rm -f $SDCARD/IceWizard