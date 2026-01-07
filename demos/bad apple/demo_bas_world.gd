extends Node3D
var count : int = 0;
var mscount : float = 0.0;
var exponant : int = 1;

@onready var world : RID

@onready var multi_mesh_instance_3d = $MultiMeshInstance3D
var multimesh : MultiMesh

@export var video : VideoStreamPlayer
@export var vid_resolution : Vector2i = Vector2i(460,360)
@export var z_dist : int = 4000
@export var gap : float = 2.0

@export var start : bool = false
var mode : int = 0
var finished : bool = true

var bas_started = false

var mmentity : RID
var badapplesystem : BadAppleSystem

var script_system_rid : RID

var frame_count : int = 0

func _process(delta: float) -> void:
	mscount = mscount + delta;
	frame_count += 1
	if(Input.is_key_pressed(KEY_ENTER)):
		start = true
		pass
	if(Input.is_key_pressed(KEY_0)):
		mode = 0
		pass
	if(Input.is_key_pressed(KEY_1)):
		mode = 1
		pass
	if(Input.is_key_pressed(KEY_2)):
		mode = 2
		pass
	badapplesystem.mode = mode;
	if(video && !video.is_playing() and start and finished):

		if(!bas_started):
			var result = SceneObjectUtility.get_singleton().create_entity(world, multi_mesh_instance_3d)
			mmentity = result[0]
			badapplesystem.set_world_id(world)
			badapplesystem.set_mm_entity(mmentity)
			badapplesystem.set_video_player(video)
			finished = false
			badapplesystem.start()
			bas_started = true
		video.play()
		pass
	if(video && !video.is_playing() and start && !finished):
		start = false;
		finished = true;

		pass
	FlecsServer.progress_world(world,delta)
	if(frame_count < -10000):
		var sys_info = FlecsServer.get_script_system_info(world, script_system_rid)
		for key in sys_info:
			var variant : Variant = sys_info[key]
			print("{0} : {1}".format([key,variant]))
					
				

func test(e) -> void:
	count += 1;
	if(count == 10 || count == 100 || count == 1000 || count == 10000 || count == 100000 || count == 1000000):
		print("print","iterated: " + String.num_int64(count) + " times in: " + String.num(mscount* pow(10,9),2) + "ns.");
		print("iterated: " + String.num_int64(count) + " times in: " + String.num(mscount* pow(10,3),2) + "ms.");
		print("iterated: " + String.num_int64(count) + " times in: " + String.num(mscount,2) + "s.");
		return;
	if(count == 10000000):
		print("iterated: 10000000 times in: " + String.num(mscount* pow(10,9),2) + "ns.");
		print("iterated: 10000000 times in: " + String.num(mscount* pow(10,3),2) + "ms.");
		print("iterated: 10000000 times in: " + String.num(mscount,2) + "s.");
		return;
	if(count == 100000000):
		print("iterated: 100000000 times in: " + String.num(mscount* pow(10,9),2) + "ns.");
		print("iterated: 100000000 times in: " + String.num(mscount* pow(10,3),2) + "ms.");
		print("iterated: 100000000 times in: " + String.num(mscount,2) + "s.");
		return;
	if(count == 1000000000):
		print("iterated: 1000000000 times in: " + String.num(mscount* pow(10,9),2) + "ns.");
		print("iterated: 1000000000 times in: " + String.num(mscount* pow(10,3),2) + "ms.");
		print("iterated: 1000000000 times in: " + String.num(mscount,2) + "s.");
		return;

@warning_ignore("unused_parameter")
func test2(entity : RID) -> void:
	count += 1
	if(count == 1000000):
		print("iterated: 1000000 times in:" + String.num(mscount,2)+ "s.");

func _ready() -> void:
	world = FlecsServer.create_world()
	print("GDSCRIPT: create_world returned (decimal): ", world.get_id())
	# Also call C++ debug helper that prints owners/worlds immediately:
	#FlecsServer.debug_check_rid(world)
	FlecsServer.init_world(world)
	#FlecsServer.debug_check_rid(world)
	var progress_result = FlecsServer.progress_world(world, 0.016)
	print("GDSCRIPT: progress_world returned: ", progress_result)
	vid_resolution = video.get_video_texture().get_size()
	multimesh = multi_mesh_instance_3d.multimesh
	var instance_transform : Transform3D = Transform3D()
	var x : float = 0
	var y : float = 0
	instance_transform.origin = Vector3(x, y, z_dist)

	for i in range(1,multimesh.instance_count):
		x = i % vid_resolution.x
		@warning_ignore("integer_division")
		y = i / vid_resolution.x

		instance_transform.origin = Vector3(x, y, 0) * gap + Vector3(0,0,z_dist)
		multimesh.set_instance_transform(i, instance_transform)
		multimesh.set_instance_color(i, Color.BLACK)

	var world3ddict : Dictionary = {

	}
	FlecsServer.set_world_singleton_with_name(world, "World3DComponent", world3ddict )
	badapplesystem = BadAppleSystem.new()
	# disabled because it is currently broken
	script_system_rid = FlecsServer.add_script_system(world, Array(), Callable(self, "test"))
	#FlecsServer.set_script_system_multi_threaded(world, script_system_rid, true)
	#FlecsServer.set_script_system_instrumentation(world, script_system_rid, true)
	FlecsServer.set_script_system_dispatch_mode(world, script_system_rid, 1)
	return
