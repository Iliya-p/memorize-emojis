extends Node2D

var allowed_emojis: String = "🍑🧂🥚🍳🍖🍜🏺🥢🥤💡🧇🥞🍲🍓🥕🌺🌻🌼🌲🍂🍁🐀🐦🐧🐇⚪⬛⬜⚙🦑🦀🦐🐚🔭🗼📺🧺🧊💖❄🔥🌊🐳🐟🦋🐝🎯🔧💾💿📙📦✉📅📏🖋✏🛌🧦🧤🧣🎲🔑📡📷🕯🍪🍰🍺🍻🥭🌾🌳⚗🍬🍫🎁🌷🕓"
var letters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var numbers: String = "1234567890"
var emoji_list: Array[String] = []
var current_emojis: Array[String] = []
var elapsed_time: float = 0.0

var error_sound = preload("res://error.ogg")
var success_sound = preload("res://success.wav")
var results_sound = preload("res://results.wav")

func fill_emoji_list() -> void:
	emoji_list.clear()
	if $view/EnableEmoji.button_pressed:
		emoji_list.append_array(allowed_emojis.rsplit())
		#for icon in allowed_emojis:
			#emoji_list.push_back(icon)
	if $view/EnableLetters.button_pressed:
		emoji_list.append_array(letters.rsplit())
		#for icon in letters:
			#emoji_list.push_back(icon)
	if $view/EnableNumbers.button_pressed:
		emoji_list.append_array(numbers.rsplit())
		#for icon in numbers:
			#emoji_list.push_back(icon)
	if $view/EnableCustom.button_pressed:
		emoji_list.append_array($view/CustomSymbols/TextEdit.text.rsplit())
		#for icon in $view/CustomSymbols/TextEdit.text:
			#emoji_list.push_back(icon)

func on_begin() -> void:
	$RestartButton.visible = true
	$DoneButton.visible = true
	$CurrentStateDisplay.text = "Memorize the emoticons"
	
	$Audio.stream = success_sound
	$Audio.play()
	
	#$BeginButton.visible = false
	#$NmrOfElements.visible = false
	#$TimeToMemorize.visible = false
	#$IdleTime.visible = false
	#$AllowedEmojis.visible = false
	#$AnswerTime.visible = false
	
	$view.visible = false
	$Score.visible = false
	$IconList.visible = false
	
	$Display.visible = true
	
	# This bit adds symbols to display to memorize
	fill_emoji_list()
	emoji_list.shuffle()
	$Display.text = ""
	#$DisplayList.clear()
	for i in $view/NmrOfElements/SpinBox.value: 
		current_emojis.push_back(emoji_list.get(i))
		$Display.text += emoji_list.get(i) 
		#$DisplayList.add_item(emoji_list.get(i),null,false)
	
	# This bit adds symbols to choosing panel
	emoji_list.shuffle()
	for icon in emoji_list:
		$IconList.add_item(icon)
	
	$view/TimeToMemorize/Timer.start($view/TimeToMemorize/SpinBox.value)
	#is_countdown_running_qmrk = true
	

func on_time_to_memorize_timeout() -> void:
	$CurrentStateDisplay.text = "Wait"
	$view/IdleTime/Timer.start($view/IdleTime/SpinBox.value)
	$Display.visible = false
	#$DisplayList.visible = false


func on_idle_timer_timeout() -> void:
	$CurrentStateDisplay.text = "Choose correct emoticons"
	$IconList.visible = true
	$view/AnswerTime/Timer.start($view/AnswerTime/SpinBox.value)

func on_answer_timer_timeout() -> void:
	$DoneButton.visible = false
	$Audio.stream = results_sound
	$Audio.play()
	$Display.visible = true
	#$DisplayList.visible = true
	var output_time = int(($view/AnswerTime/SpinBox.value - final_time)*100)/100.0
	var output_string: String = "time: " + var_to_str(output_time) + " | precision: " + $ScoreDisplay.text
	$Score/List.add_item(output_string)
	$Score.visible = true

func on_done_button_down() -> void:
	#$DoneButton.visible = false
	
	$view/TimeToMemorize/Timer.stop()
	$view/IdleTime/Timer.stop()
	$view/AnswerTime/Timer.stop()
	
	on_answer_timer_timeout()

func _ready() -> void:
	$view/BeginButton.button_down.connect(on_begin)
	$view/TimeToMemorize/Timer.timeout.connect(on_time_to_memorize_timeout)
	$view/IdleTime/Timer.timeout.connect(on_idle_timer_timeout)
	correct_answer.connect(on_correct_answer)
	wrong_answer.connect(on_wrong_answer)
	$view/AnswerTime/Timer.timeout.connect(on_answer_timer_timeout)
	$RestartButton.button_down.connect(on_restart)
	$DoneButton.button_down.connect(on_done_button_down)
	
	#$ScoreDisplay.text = var_to_str(answered_emojis) + "/" + var_to_str(int($NmrOfElements/SpinBox.value))
	set_zero_score_display()
	
	
	
	
	#end


func on_restart() -> void:
	$RestartButton.visible = false
	$DoneButton.visible = false
	
	#$BeginButton.visible = true
	#$NmrOfElements.visible = true
	#$TimeToMemorize.visible = true
	#$IdleTime.visible = true
	#$AllowedEmojis.visible = true
	#$AnswerTime.visible = true
	$view.visible = true
	$Score.visible = true
	$IconList.visible = true
	
	$view/TimeToMemorize/Timer.stop()
	$view/IdleTime/Timer.stop()
	$view/AnswerTime/Timer.stop()
	
	answered_emojis = 0
	nmr_of_correct_answers = 0
	final_time = 0.0
	
	$IconList.clear()
	set_zero_score_display()


func set_zero_score_display() -> void:
	$ScoreDisplay.text = var_to_str(answered_emojis) + "/" + var_to_str(int($view/NmrOfElements/SpinBox.value))




signal correct_answer
signal wrong_answer

var answered_emojis: int = 0
var nmr_of_correct_answers: int = 0
var final_time: float = 0.0

func on_correct_answer() -> void:
	$Audio.stream = success_sound
	$Audio.play()
	answered_emojis += 1
	nmr_of_correct_answers += 1

func on_wrong_answer() -> void:
	$Audio.stream = error_sound
	$Audio.play()
	answered_emojis -= 1

func _process(_delta: float) -> void:
	var display_value = $view/IdleTime/Timer.time_left + $view/TimeToMemorize/Timer.time_left + $view/AnswerTime/Timer.time_left
	$TimeDisplay.text = var_to_str(int(display_value*100)/100.0)
	
	if !$view/AnswerTime/Timer.is_stopped():
		#if $IconList.is_anything_selected():
			#var item = $IconList.get_selected_items().get(0)
		for item in $IconList.get_selected_items():
			if current_emojis.has($IconList.get_item_text(item)):
				emit_signal("correct_answer")
			else:
				emit_signal("wrong_answer")
			$IconList.set_item_disabled(item, true)
			$IconList.deselect_all()
			$ScoreDisplay.text = var_to_str(answered_emojis) + "/" + var_to_str(int($view/NmrOfElements/SpinBox.value))
			
			if nmr_of_correct_answers >= $view/NmrOfElements/SpinBox.value:
				final_time = $view/AnswerTime/Timer.time_left
				$view/AnswerTime/Timer.stop()
				$view/AnswerTime/Timer.timeout.emit()
