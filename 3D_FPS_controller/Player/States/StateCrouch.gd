extends State
class_name StateCrouch

export (NodePath) var cameraNode:NodePath
export (NodePath) var headCheckShapeNode:NodePath
var headShape:CollisionShape
var camera:Spatial
var camPos:Vector3
var camPosCrouch:Vector3
var transitionTime: = 0.1
var isGrounded: = true

func on_ready()->void:
	camera = get_node(cameraNode)
	headShape = get_node(headCheckShapeNode)
	camPos = camera.transform.origin
	camPosCrouch = camPos +Vector3(0.0, -1.0, 0.0)


# warning-ignore:unused_argument
func process(delta:float)->void:
	state_check()

# warning-ignore:unused_argument
func physics(delta:float)->void:
	if !isGrounded:
		if entity.isGrounded:
			headShape.disabled = false
			isGrounded = true
	entity.physics(delta)

# warning-ignore:unused_argument
func input(event:InputEvent)->void:
	entity.input(event)

# warning-ignore:unused_argument
func enter(data:Dictionary={})->void:
	entity.spd = entity.crouchSpd
	entity.standShape.disabled = true
	entity.crouchShape.disabled = false
	if entity.isGrounded:
		headShape.disabled = false
		entity.tween.stop_all()
		entity.tween.interpolate_property(camera, "transform:origin", camera.transform.origin, camPosCrouch, transitionTime, Tween.TRANS_QUAD, Tween.EASE_OUT)
		entity.tween.start()
	else:
		isGrounded = false
		camera.transform.origin = camPosCrouch
		entity.transform.origin += (camPos -camPosCrouch)

func exit()->void:
	isGrounded = true
	entity.standShape.disabled = false
	entity.crouchShape.disabled = true
	headShape.disabled = true
	if isGrounded:
		entity.tween.stop_all()
		entity.tween.interpolate_property(camera, "transform:origin", camera.transform.origin, camPos, transitionTime, Tween.TRANS_QUAD, Tween.EASE_OUT)
		entity.tween.start()

func state_check()->void:
	if entity.btnCrouch || !entity.headCheck.get_overlapping_bodies().empty():
		return
	
	if !entity.isGrounded:
		sm.transition("Jump")
		return
	
	if entity.dir.length() < 0.01:
		sm.transition("Idle")
	elif entity.btnRun:
		sm.transition("Run")
	else:
		sm.transition("Walk")
