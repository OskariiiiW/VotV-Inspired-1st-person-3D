extends AudioStreamPlayer

#TODO - maybe fade out fade in when music changes - add a bool is_instant, where if true, music will
# instantly change. otherwise fade out/in

func set_music(music : AudioStream): #AudioStreamWAV maybe?
	stream = music
