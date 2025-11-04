@tool
extends Area3D

@onready var fog_volume: FogVolume = $FogVolume
@onready var room_zone: CollisionShape3D = $ROOM_ZONE
@onready var ventilation_timer: Timer = $VentilationTimer
#@onready var dustFX: GPUParticles3D = $DUST

#MEMO: 
#The dust function doesn't work, I think it's the information
#access that causes issues. I get a lot of errors in editor
#and the physics interpolator stops working right. 

@export var V3RoomDimensions:Vector3 = Vector3(5, 5, 5)
@onready var particle_collision: GPUParticlesCollisionBox3D = $ParticleCollision

@export var fSmokeDensity:float = 0
@export var fVentilationValue:float = 0.001
@export var fSmokeDensityMax:float = 0.35
@export var fSmokeToDisplace:float = 0
#@export var fDustRate:float = 0

@export var CSGTemplate:CSGBox3D

func _process(delta: float) -> void:
	EditorProcess()
	GameProcess()

func _ready() -> void:
	ConnectObjects()

func CSGFabrication():
	if CSGTemplate == null: return
	else:
		V3RoomDimensions = CSGTemplate.size
		self.global_position = CSGTemplate.global_position
		self.global_rotation = CSGTemplate.global_rotation
		CSGTemplate = null

func EditorProcess():
	if !Engine.is_editor_hint(): return
	CSGFabrication()
	if particle_collision.size != V3RoomDimensions: 
		particle_collision.size = V3RoomDimensions
	if room_zone.shape.size != V3RoomDimensions:
		room_zone.shape.size = V3RoomDimensions
	if fog_volume.size != V3RoomDimensions:
		fog_volume.size = V3RoomDimensions

func AddSmoke(fValue):
	if fSmokeDensity > fSmokeDensityMax: return
	print("Smoke density is now "+str(fSmokeDensity+fValue))
	fSmokeDensity += fValue

func DisplaceSmoke(fValue):
	fSmokeToDisplace += fValue
	fSmokeDensity -= fValue

func SmokeProcess():
	if fSmokeDensity < (fVentilationValue): 
		fSmokeDensity = 0
		return
	if fog_volume.material.density != fSmokeDensity: 
		if fog_volume.material.density <= fSmokeDensity: fog_volume.material.density = fog_volume.material.density + (fSmokeDensity * 0.01)
		if fog_volume.material.density > fSmokeDensity: fog_volume.material.density = fog_volume.material.density - (fSmokeDensity * 0.01)
	if fog_volume.material.density > 2: fog_volume.material.density = 2
	if fog_volume.material.density < 0: fog_volume.material.density = 0

func CutDecimals():
	fSmokeDensity = float(str("%0.4f" % fSmokeDensity," s"))

func GameProcess():
	if Engine.is_editor_hint(): return
	CutDecimals()
	if particle_collision.size != V3RoomDimensions: 
		particle_collision.size = V3RoomDimensions
	if fog_volume.size != V3RoomDimensions * 1.1:
		fog_volume.size = V3RoomDimensions * 1.1
	SmokeProcess()
#	var DustPM:ParticleProcessMaterial = dustFX.process_material
#	if DustPM.emission_box_extents != V3RoomDimensions:
#		DustPM.emission_box_extents = V3RoomDimensions
#		dustFX.amount = (V3RoomDimensions.x + V3RoomDimensions.y + V3RoomDimensions.z) * 10
#		dustFX.amount_ratio = 1

func ConnectObjects():
	for thing in self.get_overlapping_bodies():
		ConnectRoom(thing)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("ConnectRoom"): body.ConnectRoom(self)
	print("Connecting "+str(body)+" to "+str(self))

func Ventilate():
	if fVentilationValue == 0: return
	if fSmokeDensity > 0: fSmokeDensity = fSmokeDensity - randf_range(0.00001, fVentilationValue)
	if fSmokeDensity < 0: fSmokeDensity = 0
#	if fDustRate > 0: fDustRate = fDustRate - randf_range(0.00001, fVentilationValue)

func _on_ventilation_timer_timeout() -> void:
	Ventilate()
#	DustProcess()
	ventilation_timer.start(randf_range(0.55, 1.5))

func ConnectRoom(body:CollisionObject3D):
	if body.has_method("ConnectRoom"): body.ConnectRoom(self)
	print("Connecting "+str(body)+" to "+str(self))

func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("ConnectRoom"): body.ConnectRoom(self)
	print("Connecting "+str(body)+" to "+str(self))

#func DustProcess():
#	if fDustRate <= 1: fDustRate = fDustRate + randf_range(0.001, 0.005)
#	if dustFX.amount_ratio != fDustRate && fDustRate >= 0.1: dustFX.amount_ratio = fDustRate
#	if fDustRate < 0.1: dustFX.amount_ratio = 0
#	print("Dust rate @ "+str(self)+": "+str(fDustRate))
