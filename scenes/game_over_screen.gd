extends CanvasLayer


@onready var vencedor_texto = $CaixaVertical/VencedorTexto
@onready var btn_jogar = $CaixaVertical/BtnJogarNovamente
@onready var btn_menu = $CaixaVertical/BtnMenu

func _ready() -> void:
	# 🆕 Garante que os botões funcionem mesmo com o jogo pausado!
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Pausa o jogo no fundo
	get_tree().paused = true
	
	# Conecta os botões
	btn_jogar.pressed.connect(_on_btn_jogar_pressed)
	btn_menu.pressed.connect(_on_btn_menu_pressed)

# Função para o GameManager chamar e definir o texto da vitória
func definir_vencedor(mensagem: String, cor: Color) -> void:
	vencedor_texto.text = mensagem
	vencedor_texto.add_theme_color_override("font_color", cor)

func _on_btn_jogar_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_game() # Zera placares e reinicia a partida
	queue_free() # Remove a tela de vitória antiga da tela

func _on_btn_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.go_to_menu() # Volta para o menu principal
	queue_free() # Remove a tela de vitória antiga da tela
