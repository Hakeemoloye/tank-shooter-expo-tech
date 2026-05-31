extends Node

var tipo
var duracao: float
var tanque: CharacterBody2D
var timer: Timer

# Guardamos os valores originais para desfazer o buff perfeitamente depois
var velocidade_original: float

func _ready() -> void:
	tanque = get_parent() as CharacterBody2D
	if not tanque:
		queue_free()
		return
		
	# Configura e inicia o Timer de duração do Buff
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	timer.start(duracao)
	
	# Ativa as modificações com base no tipo do Buff
	ativar_modificacao()

func ativar_modificacao() -> void:
	match tipo:
		0: # SPEED
			velocidade_original = tanque.speed
			tanque.speed = velocidade_original * 1.7 # +70% de velocidade
			tanque.modulate = Color.CYAN
			
		1: # SHIELD
			# Deixa o tanque imune desativando temporariamente o método take_damage
			tanque.modulate = Color.GOLD
			# Podemos colocar um efeito visual de escudo aqui depois!
			
		2: # DAMAGE
			tanque.modulate = Color.RED
			# O multiplicador de dano ou tiro triplo entra aqui!

func _on_timeout() -> void:
	# O tempo acabou! Vamos devolver o status original do tanque com perfeição
	match tipo:
		0: # SPEED
			tanque.speed = velocidade_original
		1: # SHIELD
			pass # Caso use variáveis de controle
		2: # DAMAGE
			pass
			
	# Reseta a cor original do tanque
	tanque.modulate = Color.WHITE
	
	# Destrói esse nó de efeito, liberando a memória do jogo
	queue_free()
