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
org.lineageos.eleven
com.kabouzeid.gramophon
com.tbig.playerprotrial
com.thrift.pulsar
com.rhmsoft.pulsar
com.sonyericsson.music
com.kodarkooperativet.blackplayerfree
com.kodarkooperativet.blackplayerex
com.Project100Pi.themusicplayer
deezer.android.app
org.schabi.newpipe
au.com.shiftyjelly.pocketcasts
com.doubleTwist.androidPlayer
com.doubleTwist.androidPlayerPro
com.maxfour.music
com.onkyo.jp.musicplayer
org.moire.ultrasonic
com.jetappfactory.jetaudio
com.jetappfactory.jetaudioplus
com.mrgreensoft.nrg.player
org.fitchfamily.android.symphony
com.google.android.youtube
com.google.android.apps.podcasts
io.stellio.player
org.videolan.vlc
another.music.player
com.poupa.vinylmusicplayer
com.n7mobile.player
net.programmierecke.radiodroid2
com.tbig.playerpro
org.gateshipone.odyssey
pt.ipleiria.mymusicqoe
org.deadbeef.android
ch.blinkenlights.android.vanilla
com.doubleTwist.cloudPlayer
com.spotify.lite
com.soundcloud.android
com.bandcamp.android
com.rhapsody.napster
ru.yandex.music
ru.yandex.radio
com.zvoo.openplay
am.radiogr
com.zvooq.openplay
tunein.player
radiotime.player
com.sec.android.app.music
com.uma.musicvk
com.mixcloud.player
com.andrew.apollo
de.xorg.henrymp.backport
com.kapp.youtube.final
mp3player.audioplayer.audiobeats
com.shaiban.audioplayer.mplayer
in.krosbits.musicolet
com.simplecity.amp_pro
com.asus.music
com.amazon.mp3
)
XML=/data/system/packages.xml

if [ "$SEINJECT" != "/sbin/sepolicy-inject" ]; then
  $SEINJECT --live "create AW_file" "create opdiagnose_service" "create hal_broadcastradio_hwservice" "create system_server untrusted_app_all_devpts" "create system_server untrusted_25_devpts" "create system_server untrusted_app_devpts" "allow priv_app opdiagnose_service service_manager find" "allow audioserver AW_file file { read write open }" "allow priv_app AW_file file { read open }" "allow priv_app AW_file file { read getattr open }" "allow priv_app proc_modules file { open read getattr }" "allow priv_app proc_interrupts file { open read }" "allow { audioserver hal_audio_default } { default_android_service audioserver_service } service_manager *" "allow { audioserver hal_audio_default priv_app servicemanager } { audio_data_file dts_data_file hal_audio_default system_data_file } dir *" "allow audioserver hal_broadcastradio_hwservice hwservice_manager *" "allow dts_data_file labeledfs filesystem *" "allow { hal_audio_default servicemanager } hal_audio_default process *" "allow hal_audio_default servicemanager binder *" "allow priv_app init unix_stream_socket *" "allow priv_app property_socket sock_file *" "allow priv_app system_prop property_service *" "permissive priv_app" "allow priv_app system_data_file file { open read }" "allow priv_app proc_stat file { read open getattr }" "allow hal_perf_default kernel dir { read open }" "allow hal_perf_default kernel file { ioctl read open write getattr lock }" "allow hal_memtrack_default qti_debugfs file { open read }" "allow priv_app unlabeled file { open read write getattr execute }" "allow untrusted_app unlabeled file { open read write getattr execute }" "allow system_server devpts chr_file { read write }" "allow system_server untrusted_app_devpts chr_file { read write }" "allow system_server untrusted_app_25_devpts chr_file { read write }" "allow system_server untrusted_app_all_devpts chr_file { read write }"
else
  $SEINJECT -Z audioserver -l
  $SEINJECT -Z hal_audio_default -l
  $SEINJECT -Z mediaserver -l
  $SEINJECT -Z priv_app -l
  $SEINJECT -Z servicemanager -l
  $SEINJECT -Z system_server -l
  $SEINJECT -Z dts_data_file -l  
fi

enforce() {
getenforce >> /data/media/0/iceenforce.txt
}

enforce2() {
if grep -q Enforcing /data/media/0/iceenforce.txt; then
 setenforce 1
else 
 setenforce 0
fi

rm -f /data/media/0/iceenforce.txt
}

	enforce
	setenforce 0
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
	enforce2
	su -c killall dk.icepower.icesound
