extends Control

# Lista de resoluções para usarmos na lógica de centralizar a tela
var resolutions: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720)
]

func _ready():
	$Back.pressed.connect(_on_back_pressed)

	# Limpa o seletor antes para não duplicar itens caso mude de cena e volte
	$ResolutionSelector.clear()
	$ResolutionSelector.add_item("1920x1080")
	$ResolutionSelector.add_item("1600x900")
	$ResolutionSelector.add_item("1366x768")
	$ResolutionSelector.add_item("1280x720")

	$MasterVolume.value_changed.connect(_on_volume_changed)
	$FullscreenToggle.toggled.connect(_on_fullscreen_toggled)
	$ResolutionSelector.item_selected.connect(_on_resolution_selected)
	
	# Configuração recomendada para o Slider no Inspector via código:
	$MasterVolume.min_value = 0.0
	$MasterVolume.max_value = 1.0
	$MasterVolume.step = 0.05
	
	# 🆕 Sincroniza o estado inicial do seletor caso o jogo já comece em Fullscreen
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		$ResolutionSelector.disabled = true

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_volume_changed(value):
	var bus_index = 0 # Canal Master
	if value <= 0.05:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _on_fullscreen_toggled(enabled):
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		# 🆕 Desativa o dropdown de resolução (em Fullscreen manda a resolução nativa do monitor)
		$ResolutionSelector.disabled = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# 🆕 Libera a resolução de volta quando estiver em modo janela
		$ResolutionSelector.disabled = false
		
		# Força a janela a voltar para a resolução que está selecionada no momento
		_on_resolution_selected($ResolutionSelector.selected)

func _on_resolution_selected(index):
	# 🆕 Se mudar a resolução manualmente, desliga o Fullscreen e desmarca o botão na UI
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Desconecta temporariamente o sinal para não gerar um loop infinito ao mudar o estado do botão
	$FullscreenToggle.set_block_signals(true)
	$FullscreenToggle.button_pressed = false
	$FullscreenToggle.set_block_signals(false)
	$ResolutionSelector.disabled = false
	
	# Define o novo tamanho baseado na nossa lista
	var target_resolution = resolutions[index]
	DisplayServer.window_set_size(target_resolution)
	
	# Centraliza a janela no meio do monitor do jogador
	var screen_id = DisplayServer.window_get_current_screen()
	var screen_size = DisplayServer.screen_get_size(screen_id)
	DisplayServer.window_set_position((screen_size / 2) - (target_resolution / 2))
