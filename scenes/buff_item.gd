extends Area2D

# 🆕 Agora temos 5 poderes incríveis no sorteio!
var tipos_possiveis = ["velocidade", "vida", "espingarda", "escudo", "gigante"]
var tipo_de_buff: String

func _ready() -> void:
	tipo_de_buff = tipos_possiveis.pick_random()
	
	# 🎨 Cores personalizadas para cada tipo de caixa
	match tipo_de_buff:
		"vida":
			modulate = Color(0.2, 1.0, 0.2) # Verde
		"velocidade":
			modulate = Color(1.0, 0.8, 0.0) # Amarelo/Dourado
		"espingarda":
			modulate = Color(0.7, 0.2, 1.0) # Roxo Metálico
		"escudo":
			modulate = Color(0.0, 0.8, 1.0) # Azul Ciano / Escudo
		"gigante":
			modulate = Color(1.0, 0.2, 0.2) # Vermelho Fogo

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("🚨 ALGO ENCOSTOU NO BUFF: ", body.name)
	
	if body.has_method("receber_buff"):
		print("✅ O tanque ", body.name, " pegou o buff de ", tipo_de_buff.to_upper(), " com sucesso!")
		body.receber_buff(tipo_de_buff)
		queue_free()
	else:
		print("❌ AVISO: ", body.name, " não tem a função de receber buffs.")
