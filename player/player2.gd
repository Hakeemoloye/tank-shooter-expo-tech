extends CharacterBody2D

@export_group("Atributos Base")
@export var default_speed: float = 150.0
@export var default_health: int = 20
@export var default_shoot_cooldown: float = 0.4

@export_group("Cenas")
@export var bullet_scene: PackedScene
@export var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")

@onready var gun_point = get_node_or_null("Turret/GunPoint")
@onready var smoke_fx = get_node_or_null("BaseSprite/SmokeFX")

# Nós de buff e UI
@onready var shoot_timer = $ShootTimer
@onready var health_bar = $HealthBar

var current_speed: float
var current_health: int
var is_dead: bool = false
var can_shoot: bool = true

# 🆕 Variáveis de controle para os novos Buffs no Player 2
var tem_espingarda: bool = false
var tem_escudo: bool = false
var tem_gigante: bool = false

func _ready() -> void:
	add_to_group("players")
	if smoke_fx == null: smoke_fx = get_node_or_null("SmokeFX")
	
	current_speed = default_speed
	current_health = default_health
	
	# Configura a barra de vida do P2
	if health_bar:
		health_bar.max_value = default_health
		health_bar.value = current_health

func _physics_process(_delta: float) -> void:
	if is_dead: return
	
	# Mantém os inputs mapeados para o Player 2
	var input_direction = Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
	
	velocity = input_direction * current_speed
	move_and_slide()
	
	if smoke_fx:
		if velocity.length() > 10:
			smoke_fx.visible = true
			smoke_fx.play("smoke")
		else:
			smoke_fx.stop()
			smoke_fx.visible = false
	
	if input_direction.length() > 0.1:
		rotation = lerp_angle(rotation, input_direction.angle(), 0.2)
	
	# Lógica de Metralhadora (segurar botão)
	if Input.is_action_pressed("p2_shoot") and can_shoot:
		shoot()

func shoot() -> void:
	if not bullet_scene: return
	
	can_shoot = false
	instanciar_bala()
	
	shoot_timer.start()
	if not shoot_timer.timeout.is_connected(_on_shoot_timer_timeout):
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

# 🆕 Função de Instanciar modificada para aceitar Espingarda e Gigante no P2
func instanciar_bala() -> void:
	if not bullet_scene: return
	
	# 🔫 Se tiver o buff de espingarda, atira 3 balas com desvios de ângulo
	if tem_espingarda:
		var angulos = [-0.25, 0.0, 0.25] # Em radianos (aprox. -15°, 0° e 15°)
		for angulo in angulos:
			criar_objeto_bala(angulo)
	else:
		# Tiro normal (apenas 1 bala reta)
		criar_objeto_bala(0.0)

# 🆕 Função auxiliar para criar cada bala com o alvo correto do P2
func criar_objeto_bala(desvio_angulo: float) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.quem_atirou = self
	
	if GameManager.selected_mode == "pvp":
		bullet.grupo_alvo = "players"
	else:
		bullet.grupo_alvo = "bots"
		
	get_parent().add_child(bullet)
	
	# Define posição e rotação somando o desvio do ângulo
	if gun_point: 
		bullet.global_position = gun_point.global_position
		bullet.global_rotation = gun_point.global_rotation + desvio_angulo
	else: 
		bullet.global_position = global_position
		bullet.global_rotation = global_rotation + desvio_angulo
		
	# ☄️ Se tiver o buff GIGANTE, aumenta o tamanho e dobra o dano da bala
	if tem_gigante:
		bullet.scale = Vector2(2.5, 2.5)
		if "damage" in bullet:
			bullet.damage *= 2

func take_damage(amount: int) -> void:
	if is_dead: return
	
	# 🛡️ Se o escudo estiver ativo, ignora o dano e perde o escudo!
	if tem_escudo:
		tem_escudo = false
		modulate = Color(1, 1, 1) # Volta o tanque para a cor normal
		print("🛡️ ESCUDO ABSORVEU O DANO NO PLAYER 2!")
		return
	
	current_health -= amount
	if health_bar:
		health_bar.value = current_health
		
	if current_health <= 0:
		die()

func die() -> void:
	is_dead = true
	
	if health_bar: health_bar.visible = false
	
	# 💥 ORDEM DE SPAWN ABSOLUTA: Entra na árvore global ANTES de pegar a posição
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_tree().root.add_child(explosion) # Salvo direto no root para sobreviver ao reload
		explosion.global_position = global_position
		explosion.scale = Vector2(1.5, 1.5)
	
	# 🛑 Desativa o tanque visual e fisicamente
	set_physics_process(false)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	visible = false
	if smoke_fx: smoke_fx.visible = false
	
	# 🎮 Lógica de fim de round centralizada e limpa
	if GameManager.selected_mode == "pvp":
		GameManager.player1_score += 1
		GameManager.start_next_round()
	else:
		var tem_parceiro_vivo = false
		var players = get_tree().get_nodes_in_group("players")
		for p in players:
			if p != self and is_instance_valid(p) and not p.is_dead:
				tem_parceiro_vivo = true
				break
		
		if not tem_parceiro_vivo:
			GameManager.player2_score += 1
			GameManager.start_next_round()
			
	queue_free()

# ==========================================
# 🌟 SISTEMA DE BUFFS P2 EXPANDIDO
# ==========================================
func receber_buff(tipo: String) -> void:
	if tipo == "velocidade":
		current_speed = default_speed + 100.0
		shoot_timer.wait_time = 0.1 
		
		print("🔥 TURBO ATIVADO NO PLAYER 2! Metralhadora ligada!")
		
		var duration_timer = get_tree().create_timer(6.0)
		duration_timer.timeout.connect(_on_turbo_timeout)
		
	elif tipo == "vida":
		current_health = mini(current_health + 10, default_health)
		if health_bar:
			health_bar.value = current_health
		print("❤️ VIDA RECUPERADA NO PLAYER 2! Vida atual: ", current_health)
		
	elif tipo == "espingarda":
		# 🔫 ATIVA ESPINGARDA (Tiro Triplo por 7 segundos)
		tem_espingarda = true
		print("🔫 ESPINGARDA ATIVADA NO PLAYER 2! 3 tiros em cone!")
		
		await get_tree().create_timer(7.0).timeout
		tem_espingarda = false
		print("🔙 Espingarda desativada no ", name)
		
	elif tipo == "escudo":
		# 🛡️ ATIVA ESCUDO PROTETOR (Até levar o próximo tiro)
		tem_escudo = true
		modulate = Color(0.3, 0.8, 1.0) # Brilho azul de escudo
		print("🛡️ ESCUDO PROTETOR ATIVADO NO PLAYER 2!")
		
	elif tipo == "gigante":
		# ☄️ ATIVA TIROS GIGANTES (Dano duplo por 6 segundos)
		tem_gigante = true
		print("☄️ BULLETS GIGANTES ATIVADAS NO PLAYER 2!")
		
		await get_tree().create_timer(6.0).timeout
		tem_gigante = false
		print("🔙 Modo gigante desativado no ", name)

func _on_turbo_timeout() -> void:
	current_speed = default_speed
	shoot_timer.wait_time = default_shoot_cooldown
	print("🔙 Turbo do Player 2 acabou. Voltando ao normal.")
