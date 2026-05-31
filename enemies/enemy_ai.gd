extends CharacterBody2D

@export_group("Atributos Base")
@export var default_speed: float = 120.0
@export var default_health: int = 20
@export var attack_range: float = 550.0 
@export var default_shoot_cooldown: float = 1.0 # Tempo normal de tiro do bot

@export_group("Cenas")
@export var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")
var bullet_scene = preload("res://projectiles/Bullet.tscn")

var target: Node2D = null

@onready var gun_point = get_node_or_null("Turret/GunPoint")
@onready var vision_ray = get_node_or_null("Turret/VisionRay")
@onready var smoke_fx = get_node_or_null("BaseSprite/SmokeFX")
@onready var health_bar = get_node_or_null("HealthBar") # Barra de vida

# Variáveis de estado
var current_speed: float
var current_health: int
var is_dead: bool = false
var shoot_timer: Timer # Guardamos o timer aqui para mudar o tempo depois

# 🆕 Variáveis de controle para os novos Buffs no Bot
var tem_espingarda: bool = false
var tem_escudo: bool = false
var tem_gigante: bool = false

func _ready() -> void:
	add_to_group("bots")
	if smoke_fx == null: smoke_fx = get_node_or_null("SmokeFX")
	
	current_speed = default_speed
	current_health = default_health
	
	# Configura a barra de vida
	if health_bar:
		health_bar.max_value = default_health
		health_bar.value = current_health
	
	if vision_ray:
		vision_ray.enabled = true
		vision_ray.add_exception(self)
	
	# Cria o timer de tiro no código e guarda na variável
	shoot_timer = Timer.new()
	shoot_timer.wait_time = default_shoot_cooldown
	shoot_timer.autostart = true
	shoot_timer.timeout.connect(shoot)
	add_child(shoot_timer)

func _physics_process(_delta: float) -> void:
	if is_dead: return
	
	target = get_closest_player()
	
	if target:
		var target_angle = global_position.direction_to(target.global_position).angle()
		rotation = lerp_angle(rotation, target_angle, 0.1)
		
		if vision_ray:
			vision_ray.target_position = vision_ray.to_local(target.global_position)
		
		var distance_to_target = global_position.distance_to(target.global_position)
			
		if distance_to_target > attack_range:
			var dir_to_target = global_position.direction_to(target.global_position)
			velocity = dir_to_target * current_speed # Usa a velocidade atual
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			
		if smoke_fx:
			if velocity.length() > 10:
				smoke_fx.visible = true
				smoke_fx.play("smoke")
			else:
				smoke_fx.stop()
				smoke_fx.visible = false

func get_closest_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return null
		
	var closest_node: Node2D = null
	var min_distance = INF 
	for player in players:
		if is_instance_valid(player) and not player.is_dead:
			var distance = global_position.distance_to(player.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_node = player
	return closest_node

func shoot() -> void:
	if is_dead: return
	
	if bullet_scene and target and not target.is_dead:
		var distance_to_target = global_position.distance_to(target.global_position)
		
		if distance_to_target <= attack_range + 50.0:
			if vision_ray and vision_ray.is_colliding():
				var colisor = vision_ray.get_collider()
				if colisor and (colisor.is_in_group("players") or colisor.get_parent().is_in_group("players")):
					instanciar_bala()

# 🆕 Função de Instanciar modificada para aceitar Espingarda e Gigante no Bot
func instanciar_bala() -> void:
	if not bullet_scene: return
	
	# 🔫 Se o Bot tiver o buff de espingarda, atira 3 balas com desvios de ângulo
	if tem_espingarda:
		var angulos = [-0.25, 0.0, 0.25] # Em radianos (aprox. -15°, 0° e 15°)
		for angulo in angulos:
			criar_objeto_bala(angulo)
	else:
		# Tiro normal (apenas 1 bala reta)
		criar_objeto_bala(0.0)

# 🆕 Função auxiliar para criar cada projétil com o alvo voltado para os Players
func criar_objeto_bala(desvio_angulo: float) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.quem_atirou = self
	bullet.grupo_alvo = "players"
	get_parent().add_child(bullet)
	
	# Define posição e rotação somando o desvio do ângulo
	if gun_point: 
		bullet.global_position = gun_point.global_position
		bullet.global_rotation = gun_point.global_rotation + desvio_angulo
	else: 
		bullet.global_position = global_position
		bullet.global_rotation = global_rotation + desvio_angulo
		
	# ☄️ Se tiver o buff GIGANTE, aumenta o tamanho e dobra o dano da bala do bot
	if tem_gigante:
		bullet.scale = Vector2(2.5, 2.5)
		if "damage" in bullet:
			bullet.damage *= 2

func take_damage(amount: int) -> void:
	if is_dead: return
	
	# 🛡️ Se o escudo do bot estiver ativo, ignora o dano e perde o escudo!
	if tem_escudo:
		tem_escudo = false
		modulate = Color(1, 1, 1) # Volta o bot para a cor normal
		print("🛡️ ESCUDO ABSORVEU O DANO NO BOT!")
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
		get_tree().root.add_child(explosion) # Evita ser destruído junto com o cenário
		explosion.global_position = global_position
		explosion.scale = Vector2(1.5, 1.5)
	
	# 🛑 Desativa o Bot física e visualmente
	set_physics_process(false)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	visible = false
	if smoke_fx: smoke_fx.visible = false
	
	# 🤖 Verifica se é o último bot vivo da partida
	var tem_outro_bot_vivo = false
	var bots = get_tree().get_nodes_in_group("bots")
	for b in bots:
		if b != self and is_instance_valid(b) and not b.is_dead:
			tem_outro_bot_vivo = true
			break
	
	# Se todos os bots do round morreram, os players pontuam e avança o round
	if not tem_outro_bot_vivo:
		if GameManager.selected_mode in ["solo_bots", "coop_bots"]:
			GameManager.player1_score += 1 
			
		GameManager.start_next_round()
		
	queue_free()

# ==========================================
# 🌟 SISTEMA DE BUFFS DO BOT EXPANDIDO
# ==========================================
func receber_buff(tipo: String) -> void:
	if tipo == "velocidade":
		current_speed = default_speed + 80.0 
		shoot_timer.wait_time = 0.2 
		shoot_timer.start()
		
		print("🤖⚠️ ALERTA: BOT PEGOU TURBO E VIROU METRALHADORA!")
		
		var duration_timer = get_tree().create_timer(6.0)
		duration_timer.timeout.connect(_on_turbo_timeout)
		
	elif tipo == "vida":
		current_health = mini(current_health + 20, default_health)
		if health_bar:
			health_bar.value = current_health
		print("🤖 BOT CUROU! Vida atual: ", current_health)
		
	elif tipo == "espingarda":
		# 🔫 ATIVA ESPINGARDA NO BOT (Tiro Triplo por 7 segundos)
		tem_espingarda = true
		print("🤖🔫 ALERTA: BOT PEGOU A ESPINGARDA! 3 tiros em cone!")
		
		await get_tree().create_timer(7.0).timeout
		tem_espingarda = false
		print("🔙 Espingarda do Bot acabou.")
		
	elif tipo == "escudo":
		# 🛡️ ATIVA ESCUDO PROTETOR NO BOT
		tem_escudo = true
		modulate = Color(0.3, 0.8, 1.0) # Brilho azul de escudo também no inimigo
		print("🤖🛡️ ALERTA: BOT ATIVOU UM ESCUDO PROTETOR!")
		
	elif tipo == "gigante":
		# ☄️ ATIVA TIROS GIGANTES NO BOT (Dano duplo por 6 segundos)
		tem_gigante = true
		print("🤖☄️ ALERTA: BOT ESTÁ DISPARANDO TIROS GIGANTES!")
		
		await get_tree().create_timer(6.0).timeout
		tem_gigante = false
		print("🔙 Modo gigante do Bot acabou.")

func _on_turbo_timeout() -> void:
	current_speed = default_speed
	shoot_timer.wait_time = default_shoot_cooldown
	shoot_timer.start()
	print("🔙 Turbo do Bot acabou. Ameaça reduzida.")
