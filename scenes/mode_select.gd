extends Control

func _ready():
	$PvP.pressed.connect(_on_pvp_pressed)
	$SoloBots.pressed.connect(_on_solo_bots_pressed)
	$CoopBots.pressed.connect(_on_coop_bots_pressed)
	$Back.pressed.connect(_on_back_pressed)

func _on_pvp_pressed():
	GameManager.selected_mode = "pvp"
	# 🆕 Chama a tela de instruções antes de carregar o jogo
	GameManager.iniciar_jogo_com_instrucoes("res://scenes/Main.tscn")

func _on_solo_bots_pressed():
	GameManager.selected_mode = "solo_bots"
	# 🆕 Chama a tela de instruções antes de carregar o jogo
	GameManager.iniciar_jogo_com_instrucoes("res://scenes/Main.tscn")

func _on_coop_bots_pressed():
	GameManager.selected_mode = "coop_bots"
	# 🆕 Chama a tela de instruções antes de carregar o jogo
	GameManager.iniciar_jogo_com_instrucoes("res://scenes/Main.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
