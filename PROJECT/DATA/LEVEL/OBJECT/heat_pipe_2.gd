extends StaticBody3D
@onready var heat_pipe_2: CSGCylinder3D = $HeatPipe2

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var omni_light_3d_2: OmniLight3D = $OmniLight3D2
@onready var gpu_particles_3d_2: GPUParticles3D = $GPUParticles3D2
@onready var heat_cycler: Timer = $HeatCycler

var rRoomParent:Area3D

func _ready() -> void:
	ConnectParent()

func _physics_process(delta: float) -> void:
	gpu_particles_3d.amount_ratio = PlayerHome.SpeedRate(1)
	if PlayerHome.fTravel_Speed > 0: gpu_particles_3d.lifetime = PlayerHome.SpeedRate(0.49)
	if !gpu_particles_3d_2.emitting: gpu_particles_3d.explosiveness = 1 * PlayerHome.fTravel_Speed
	heat_pipe_2.material.emission_energy_multiplier = PlayerHome.SpeedRate(16)
	omni_light_3d.light_energy = PlayerHome.SpeedRate(10)
	omni_light_3d_2.light_energy = PlayerHome.SpeedRate(10)
	if PlayerHome.fTravel_Speed > 0.5 && !gpu_particles_3d_2.emitting:
		#gpu_particles_3d_2.amount_ratio = PlayerHome.SpeedRate(1)
		gpu_particles_3d_2.emitting = true
		gpu_particles_3d.explosiveness = 0
	if !PlayerHome.fTravel_Speed > 0.5 && gpu_particles_3d_2.emitting:
		gpu_particles_3d_2.emitting = false

func ConnectRoom(rRoom:Area3D):
	rRoomParent = rRoom

func ConnectParent():
	if self.get_parent().has_method("ConnectRoom"): 
		print("Connecting "+str(self.get_parent())+" to "+str(self))
		rRoomParent = self.get_parent()

func EmitSmoke():
	if rRoomParent == null: return
	if rRoomParent.has_method("AddSmoke"): 
		print("Smoking it up at "+str(rRoomParent)+" "+str(PlayerHome.fTravel_Speed / 250))
		rRoomParent.AddSmoke(PlayerHome.fTravel_Speed / 250)


func _on_heat_cycler_timeout() -> void:
	if PlayerHome.fTravel_Speed > 0: 
		print("Smoke cycle!")
		EmitSmoke()
	heat_cycler.start(0.25)
