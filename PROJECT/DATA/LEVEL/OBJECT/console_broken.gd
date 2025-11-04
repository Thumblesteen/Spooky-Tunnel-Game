extends StaticBody3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var spark_timer: Timer = $SparkTimer


func _on_spark_timer_timeout() -> void:
	gpu_particles_3d.amount_ratio = randf_range(0.1, 1)
	gpu_particles_3d.emitting = true
	spark_timer.start(randf_range(0.5, 25))
