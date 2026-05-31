extends Node

# 🎵 CONFIGURAÇÃO DA MÚSICA DE FUNDO
var musica_fundo = preload("res://sounds/Intense.ogg")
var audio_player: AudioStreamPlayer

# 📑 TELA DE INSTRUÇÕES
var instructions_scene = preload("res://scenes/instructions_screen.tscn")

var selected_mode: String = "solo_bots" # pvp, solo_bots, coop_bots
var player1_score: int = 0  # Placar do P1 (PvP) ou da Equipe (Solo/Coop)
var player2_score: int = 0  # Placar do P2 (PvP) ou dos Bots (Solo/Coop)

# 🏆 CONFIGURAÇÃO DE ROUNDS (Melhor de 5: quem faz 3 pontos primeiro ganha)
var pontos_para_vencer: int = 3 # Fixo em 3 pontos para ganhar a MD5
var max_rounds: int = 5         # Limite visual máximo de rounds (ex: 1/5, 2/5)

# Carrega a cena do seu Game Over na memória do script
var game_over_scene = preload("res://scenes/game_over_screen.tscn") 

# Inicializa o tocador de som assim que o jogo abre
func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	audio_player.stream = musica_fundo
	audio_player.bus = "Master" 
	audio_player.play() 

# FUNÇÃO PARA CARREGAR O JOGO EXIBINDO AS INSTRUÇÕES POR 5 SEGUNDOS
func iniciar_jogo_com_instrucoes(caminho_do_mapa: String) -> void:
	var tela = instructions_scene.instantiate()
	get_tree().root.add_child(tela)
	await tela.tree_exited
	get_tree().change_scene_to_file(caminho_do_mapa)

func start_next_round() -> void:
	# Aguarda 3 segundos para os jogadores verem a explosão e o placar mudar
	await get_tree().create_timer(3.0).timeout
	
	# 🏆 1. CHECA FIM DE JOGO (Alguém atingiu os 3 pontos necessários na MD5?)
	if player1_score >= pontos_para_vencer or player2_score >= pontos_para_vencer:
		chamar_fim_de_jogo()
		return
		
	# ⚔️ 2. REGRA EXTRA DE EMPATE (Caso chegue a um placar maluco além do limite)
	if player1_score >= pontos_para_vencer - 1 and player2_score >= pontos_para_vencer - 1 and player1_score == player2_score:
		print("🚨 EMPATE NO TIROTEIO! Prorrogação ativada...")
		# Se empatarem em 2x2, quem abrir 2 pontos de vantagem ou fizer o próximo ganha (opcional)
	
	# Se ninguém ganhou a partida ainda, recarrega o mapa para o próximo round
	get_tree().reload_current_scene()

# Função interna que calcula quem ganhou e joga a tela de Game Over no mapa
func chamar_fim_de_jogo() -> void:
	var instancia_game_over = game_over_scene.instantiate()
	get_tree().root.add_child(instancia_game_over)
	
	var mensagem: String = ""
	var cor_texto: Color = Color(1, 1, 1) 
	
	if selected_mode == "pvp":
		if player1_score > player2_score:
			mensagem = "PLAYER 1 VENCEU A PARTIDA!"
			cor_texto = Color(0.2, 0.6, 1.0) 
		else:
			mensagem = "PLAYER 2 VENCEU A PARTIDA!"
			cor_texto = Color(1.0, 0.4, 0.4) 
			
	else: # Modos solo_bots ou coop_bots
		if player1_score > player2_score:
			mensagem = "VITÓRIA! OS JOGADORES VENCERAM!"
			cor_texto = Color(0.2, 1.0, 0.4) 
		else:
			mensagem = "DERROTA! OS BOTS VENCERAM!"
			cor_texto = Color(0.8, 0.1, 0.1) 
	
	if instancia_game_over.has_method("definir_vencedor"):
		instancia_game_over.definir_vencedor(mensagem, cor_texto)

# Botão "Jogar Novamente"
func reset_game() -> void:
	reset_scores()
	get_tree().reload_current_scene() 

# Botão "Menu Principal"
func go_to_menu() -> void:
	reset_scores()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn") 

func reset_scores() -> void:
	player1_score = 0
	player2_score = 0
