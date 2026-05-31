extends Node2D

@export var label_p1: Label
@export var label_p2: Label
@export var label_bots: Label
@export var label_round: Label

func _process(_delta: float) -> void:
	# 1. Calcula o número do Round baseado na soma dos abates
	var round_atual = GameManager.player1_score + GameManager.player2_score + 1
	if round_atual > GameManager.max_rounds:
		round_atual = GameManager.max_rounds
		
	# Formato desejado: "1 / 3"
	if label_round:
		label_round.text = str(round_atual) + " / " + str(GameManager.max_rounds)

	# 2. Atualiza dinamicamente as informações com segurança contra nulos
	if GameManager.selected_mode == "pvp":
		if label_p1: label_p1.text = str(GameManager.player1_score)
		if label_p2: label_p2.text = str(GameManager.player2_score)
		
	elif GameManager.selected_mode == "solo_bots":
		if label_p1: label_p1.text = str(GameManager.player1_score)
		if label_bots: label_bots.text = str(GameManager.player2_score)
		
	elif GameManager.selected_mode == "coop_bots":
		if label_p1: label_p1.text = str(GameManager.player1_score)
		if label_p2: label_p2.text = str(GameManager.player1_score) # Mostra o placar unificado da equipe
		if label_bots: label_bots.text = str(GameManager.player2_score)
