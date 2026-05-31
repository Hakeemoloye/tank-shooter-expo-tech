extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10

var quem_atirou = null
var grupo_alvo: String = ""
var eh_teleguiada: bool = false

func _physics_process(delta: float) -> void:
	# (Mantenha a sua lógica de mira teleguiada se houver)
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body == quem_atirou:
		return 
		
	if body.has_method("take_damage") and body.is_in_group(grupo_alvo):
		body.take_damage(damage)
	
	queue_free() # Destrói a bala (sem instanciar explosão)
