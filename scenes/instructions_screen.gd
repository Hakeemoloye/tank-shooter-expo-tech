extends CanvasLayer

func _ready() -> void:
	# Aguarda exatamente 5 segundos na tela
	await get_tree().create_timer(5.0).timeout
	
	# Fecha/Destrói a tela de instruções automaticamente
	queue_free()
