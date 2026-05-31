extends CanvasLayer

@onready var menu_painel: Control = $MenuPainel

func _ready() -> void:
	# O menu começa escondido quando o mapa inicia
	menu_painel.visible = false
	
	# 🚨 MUITO IMPORTANTE: Garante que este menu continue funcionando mesmo se o jogo congelar!
	process_mode = Node.PROCESS_MODE_ALWAYS 

func _input(event: InputEvent) -> void:
	# Usa o 'Input' global para evitar crashs e erros no console ao mover o mouse
	if Input.is_action_just_pressed("ui_cancel"): # Tecla ESC por padrão
		toggle_pause()

func toggle_pause() -> void:
	# Inverte o estado atual de pause do motor do jogo
	var novo_estado = not get_tree().paused
	get_tree().paused = novo_estado
	menu_painel.visible = novo_estado

# Botão Continuar
func _on_btn_continuar_pressed() -> void:
	toggle_pause()

# 🔄 Botão Reiniciar: Zera os placares reais de todos os modos e reinicia a PARTIDA
func _on_btn_reiniciar_pressed() -> void:
	get_tree().paused = false # 🚨 CRUCIAL: Despausa o jogo antes de qualquer reinício!
	
	# Zera todas as pontuações encontradas no seu hud.gd e map_hud.gd
	if typeof(GameManager) != TYPE_NIL:
		if "player1_score" in GameManager: GameManager.player1_score = 0
		if "player2_score" in GameManager: GameManager.player2_score = 0
		if "bot_score" in GameManager: GameManager.bot_score = 0
		
	# Recarrega a cena atual. Suas HUDs vão recalcular os rounds e placares do absoluto zero!
	get_tree().reload_current_scene() 

# Botão Voltar ao Menu
func _on_btn_menu_pressed() -> void:
	get_tree().paused = false # Despausa para não congelar o Menu Principal ao mudar de cena
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
