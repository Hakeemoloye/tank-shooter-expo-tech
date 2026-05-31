extends Node2D

@export var buff_item_scene: PackedScene = preload("res://assets/items/BuffItem.tscn")
@export var tempo_de_spawn: float = 12.0 # Nasce um buff a cada 12 segundos

var pontos_de_spawn: Array[Vector2] = []

func _ready() -> void:
	# Coleta a posição exata de todos os Marker2Ds que você espalhou
	for child in get_children():
		if child is Marker2D:
			pontos_de_spawn.append(child.global_position)
	
	if pontos_de_spawn.is_empty():
		pontos_de_spawn = [Vector2(800, 450)]
	
	# Cria o relógio do spawn
	var timer = Timer.new()
	timer.wait_time = tempo_de_spawn
	timer.autostart = true
	timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(timer)
	
	# CORREÇÃO 1: Pede para a Godot esperar o mapa terminar de carregar antes de spawnar o primeiro!
	call_deferred("spawn_buff")

func _on_spawn_timer_timeout() -> void:
	spawn_buff()

func spawn_buff() -> void:
	if not buff_item_scene or pontos_de_spawn.is_empty(): return
	
	var posicao_sorteada = pontos_de_spawn.pick_random()
	var buff = buff_item_scene.instantiate()
	
	# CORREÇÃO 2: Primeiro adicionamos ao mapa, DEPOIS cravamos a posição global exata.
	get_parent().add_child(buff)
	buff.global_position = posicao_sorteada
