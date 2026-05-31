extends CanvasLayer

func _process(_delta):
	# Atualiza o placar do Player 1 / Equipe
	$Player1ScoreLabel.text = "P1: " + str(GameManager.player1_score)
	
	# Controla a exibição dos placares dependendo do modo
	if GameManager.selected_mode == "pvp":
		$Player2ScoreLabel.visible = true
		$BotScoreLabel.visible = false
		$Player2ScoreLabel.text = "P2: " + str(GameManager.player2_score)
	else:
		$Player2ScoreLabel.visible = false
		$BotScoreLabel.visible = true
		# Usando player2_score que é onde o GameManager guarda os pontos dos Bots
		$BotScoreLabel.text = "BOTS: " + str(GameManager.player2_score)
	
	$ModeLabel.text = "MODE: " + GameManager.selected_mode
	
	# 📊 MATEMÁTICA DO ROUND ATUAL:
	# O número do round atual é a soma dos pontos de todo mundo + 1.
	# Exemplo: Se o placar está 2 x 1, significa que já jogaram 3 rounds, então estamos no Round 4!
	var round_atual = GameManager.player1_score + GameManager.player2_score + 1
	
	# Garante que o mostrador visual não passe de 5 se houver uma prorrogação maluca
	if round_atual > GameManager.max_rounds:
		round_atual = GameManager.max_rounds
		
	$RoundLabel.text = "ROUND: " + str(round_atual) + "/" + str(GameManager.max_rounds)
