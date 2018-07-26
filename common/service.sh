PLAYERS=(
com.spotify.music
com.google.android.music
com.neutroncode.mp
com.neutroncode.mpeval
com.maxmpz.audioplayer
com.pandora.android
com.apple.android.music
com.clearchannel.iheartradio.controller
com.aspiro.tidal
)
XML=/data/system/packages.xml

if [ "$SEINJECT" != "/sbin/sepolicy-inject" ]; then
  $SEINJECT --live "allow priv_app opdiagnose_service service_manager find" "allow audioserver AW_file file { read write open }" "allow priv_app AW_file file { read open }" "allow priv_app AW_file file { read getattr open }" "allow priv_app proc_modules file { open read getattr }" "allow priv_app proc_interrupts file { open read }" "allow { audioserver hal_audio_default } { default_android_service audioserver_service } service_manager *" "allow { audioserver hal_audio_default priv_app servicemanager } { audio_data_file dts_data_file hal_audio_default system_data_file } dir *" "allow audioserver hal_broadcastradio_hwservice hwservice_manager *" "allow dts_data_file labeledfs filesystem *" "allow { hal_audio_default servicemanager } hal_audio_default process *" "allow hal_audio_default servicemanager binder *" "allow priv_app init unix_stream_socket *" "allow priv_app property_socket sock_file *" "allow priv_app system_prop property_service *" "permissive priv_app" "allow priv_app system_data_file file { open read }" "allow priv_app proc_stat file { read open getattr }" "allow hal_perf_default kernel dir { read open }" "allow hal_perf_default kernel file { ioctl read open write getattr lock }" "allow hal_memtrack_default qti_debugfs file { open read }" "allow priv_app unlabeled file { open read write getattr execute }" "allow untrusted_app unlabeled file { open read write getattr execute }" "allow system_server untrusted_app_25_devpts chr_file { read write }"

else
  $SEINJECT -Z audioserver -l
  $SEINJECT -Z hal_audio_default -l
  $SEINJECT -Z mediaserver -l
  $SEINJECT -Z priv_app -l
  $SEINJECT -Z servicemanager -l
  $SEINJECT -Z system_server -l
  $SEINJECT -Z dts_data_file -l  
fi


  su -c killall dk.icepower.icesound
	for i in "${PLAYERS[@]}"; do
		if grep -qF $i $XML; then
      echo " "
			echo "${B}   Closing Out $i to Prevent a Force Reboot...${N}"
			am force-stop $i
		fi
	done
	sleep 4
  su -c stop dk.icepower.icesound
	sleep 2
	su -c start dk.icepower.icesound
	sleep 2
	
