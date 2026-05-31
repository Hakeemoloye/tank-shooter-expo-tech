extends Node2D

# 📦 Alinhe estes caminhos com as pastas reais do seu projeto!
const PLAYER_1_SCENE = preload("res://player/Player.tscn")
const PLAYER_2_SCENE = preload("res://player/Player2.tscn")
const BOT_SCENE = preload("res://enemies/Enemy_ai.tscn") 

@onready var current_map_node = $CurrentMap

func _ready() -> void:
	load_selected_map()

func load_selected_map() -> void:
	# Limpa resquícios de mapas antigos
	for child in current_map_node.get_children():
		child.queue_free()
		
	var map_scene_path: String = ""
	
	# Escolhe o arquivo do mapa baseado no modo ativo
	if GameManager.selected_mode == "pvp":
		map_scene_path = "res://maps/Map_PvP.tscn"
	elif GameManager.selected_mode == "solo_bots":
		map_scene_path = "res://maps/Map_VsBots.tscn"
	elif GameManager.selected_mode == "coop_bots":
		map_scene_path = "res://maps/Map_CoopBots.tscn"
		
	if map_scene_path == "":
		print("Erro: Modo de jogo inválido ou não selecionado!")
		return
		
	var map_instance = load(map_scene_path).instantiate()
	current_map_node.add_child(map_instance)
	
	# Invoca os tanques no mapa novo
	setup_spawns(map_instance)

func setup_spawns(map_instance: Node) -> void:
	# --- SPAWN PLAYER 1 ---
	if map_instance.has_node("Spawn_Player1"):
		var p1 = PLAYER_1_SCENE.instantiate()
		map_instance.add_child(p1)
		p1.global_position = map_instance.get_node("Spawn_Player1").global_position
		
	# --- SPAWN PLAYER 2 (Apenas PvP ou Coop) ---
	if GameManager.selected_mode in ["pvp", "coop_bots"]:
		if map_instance.has_node("Spawn_Player2"):
			var p2 = PLAYER_2_SCENE.instantiate()
			map_instance.add_child(p2)
			p2.global_position = map_instance.get_node("Spawn_Player2").global_position

	# --- SPAWN BOTS (Apenas Solo ou Coop) ---
	if GameManager.selected_mode in ["solo_bots", "coop_bots"]:
		if map_instance.has_node("Spawn_Bot1") and map_instance.get_node("Spawn_Bot1") != null:
			var bot1 = BOT_SCENE.instantiate()
			map_instance.add_child(bot1)
			bot1.global_position = map_instance.get_node("Spawn_Bot1").global_position
			
		if map_instance.has_node("Spawn_Bot2") and map_instance.get_node("Spawn_Bot2") != null:
			var bot2 = BOT_SCENE.instantiate()
			map_instance.add_child(bot2)
			bot2.global_position = map_instance.get_node("Spawn_Bot2").global_position
