extends SceneTree

## Isolated graphical evidence driver for BCM-M32 tutorial V05.
## It uses production input, GameManager spawn/merge/target collection, the
## campaign result overlay, and the actual Retry button. The only seeded state
## is a disposable test campaign unlocking Sunny Cove Level 4 (VIP is active
## there) plus one matching merge partner and one real To-Go target drink.

const APPLICATION_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const MAX_WAIT_FRAMES := 900

var failures: Array[String] = []
var trace_lines: Array[String] = []
var output_directory := ""
var resolution_label := "unknown"
var shell: Node
var gameplay: Node
var tutorial: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var window_size := get_root().size
	resolution_label = "%dx%d" % [window_size.x, window_size.y]
	output_directory = ProjectSettings.globalize_path("user://tutorial_v05_capture")
	DirAccess.make_dir_recursive_absolute(output_directory)
	var application := APPLICATION_SCENE.instantiate()
	application.name = "ApplicationShellV05Evidence"
	get_root().add_child(application)
	shell = application
	await process_frame
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	var navigation = shell.get("campaign_navigation")
	if not is_instance_valid(navigation):
		_fail("ApplicationShell did not expose CampaignNavigationController")
		return
	var campaign = navigation.get("campaign_manager")
	for level_id in range(1, 4):
		var seeded: Dictionary = campaign.mark_level_completed("sunny_cove", level_id, {"stars": 1})
		if not bool(seeded.get("ok", false)):
			_fail("Test-only setup could not unlock Sunny Cove Level 4")
			return
	_trace("TEST_SETUP: disposable save unlocks Levels 1-3 to expose the real Level 4 VIP HUD")
	if not shell.press_play_continue():
		_fail("ApplicationShell could not launch the production campaign gameplay")
		return
	await process_frame
	await process_frame
	gameplay = navigation.get_node_or_null("CampaignGameplay")
	if not is_instance_valid(gameplay) or not gameplay.start_guided_tutorial(true):
		_fail("Production gameplay tutorial did not start")
		return
	tutorial = gameplay.get("gameplay_tutorial")
	if not is_instance_valid(tutorial):
		_fail("Production tutorial node is missing")
		return
	_trace("TUTORIAL_START: production Level 4; actual To-Go L6 and optional VIP L5")
	await _capture_step(1, "launch")

	var shot_controller = gameplay.get("shot_controller")
	var held: Drink = shot_controller.get("_current_drink")
	if not is_instance_valid(held):
		_fail("No real held drink was available for the launch input")
		return
	var first_level := held.level
	var launched_position := held.global_position
	await _drag_to_fire(launched_position, launched_position + Vector2(32.0, 0.0))
	if not await _wait_for_step(1):
		_fail("Real ShotController input did not advance the LAUNCH step")
		return
	_trace("LAUNCH: dragged and released the real held L%d drink; production shot event advanced to MERGE" % first_level)
	await _wait_until_settled(held)
	if tutorial.current_step != 1 or not is_instance_valid(held):
		_fail("The first launched drink did not settle on the production board")
		return
	var merge_position := held.position + Vector2(0.0, held.radius * 2.6 + 10.0)
	var merge_partner: Drink = gameplay.spawn_drink(first_level, merge_position, false)
	if not is_instance_valid(merge_partner):
		_fail("Could not seed the reversible matching merge partner")
		return
	await process_frame
	await process_frame
	if tutorial.current_step != 1:
		_fail("The merge partner collided before the MERGE evidence frame")
		return
	await _capture_step(2, "merge")
	_trace("MERGE_SETUP: second actual L%d drink spawned beneath the settled launch; both real drink bounds are highlighted" % first_level)
	merge_partner.launch_up(260.0)
	if not await _wait_for_step(2):
		_fail("The real MergeQueue/on_merged production path did not advance MERGE")
		return
	_trace("MERGE: second matching drink moved through production physics and GameManager.on_merged advanced to DELIVER")
	await _capture_step(3, "deliver")

	var required_level := int(gameplay.get("_target_level"))
	var target_root: Node2D = gameplay.get("_target_root")
	var target_drink: Drink = gameplay.spawn_drink(required_level, target_root.position + Vector2(0.0, 90.0), false)
	if not is_instance_valid(target_drink):
		_fail("Could not seed the reversible matching To-Go drink")
		return
	await process_frame
	gameplay._try_collect_stocked_target()
	if not await _wait_for_step(3):
		_fail("Production To-Go target collection did not advance DELIVER")
		return
	_trace("DELIVER: test-only L%d drink entered production target capture/tween, order recorder, and tutorial delivery hook" % required_level)
	await _capture_step(4, "vip_bonus")
	var vip_state: Dictionary = gameplay.campaign_session_bridge.get_vip_state()
	if not bool(vip_state.get("enabled", false)):
		_fail("Level 4 did not expose a live optional VIP order")
		return
	var vip_sprite: Sprite2D = gameplay.get("_vip_target_sprite")
	if not is_instance_valid(vip_sprite) or not vip_sprite.visible:
		_fail("The actual VIP cocktail HUD target was not visible")
		return
	var tutorial_root := tutorial.get_node("TutorialOverlay") as Control
	var continue_button := tutorial_root.find_child("TutorialContinue", true, false) as Button
	await _click_control(continue_button)
	if tutorial.current_step != 4:
		_fail("The actual Continue button did not advance VIP BONUS to MOVES & STARS")
		return
	_trace("VIP_BONUS: actual optional L5 HUD order shown; Continue tapped without delivering/required VIP")
	await _capture_step(5, "moves_stars")
	await _click_control(continue_button)
	if tutorial.current_step != 5:
		_fail("The actual Continue button did not advance MOVES & STARS to PLAY AGAIN")
		return
	await process_frame
	await process_frame
	var result_overlay = navigation.get_result_feedback_overlay()
	if not result_overlay.visible or not result_overlay.get_visible_actions().has("RETRY"):
		_fail("The actual Results panel with Retry was not shown at step six")
		return
	var retry_button := result_overlay.get_action_presentation_target("RETRY") as Control
	if not is_instance_valid(retry_button):
		_fail("The actual Retry button control is missing")
		return
	var retry_rect := retry_button.get_global_rect()
	var viewport_rect := get_root().get_visible_rect()
	if retry_rect.size.x < 80.0 or retry_rect.size.y < 48.0 or not viewport_rect.encloses(retry_rect):
		_fail("The actual Retry touch target is outside safe viewport bounds: %s" % str(retry_rect))
		return
	_trace("PLAY_AGAIN: actual Results panel visible; RETRY bounds=%s" % str(retry_rect))
	await _capture_step(6, "play_again")
	await _click_control(retry_button)
	await process_frame
	await process_frame
	gameplay = navigation.get_node_or_null("CampaignGameplay")
	tutorial = gameplay.get("gameplay_tutorial") if is_instance_valid(gameplay) else null
	if not is_instance_valid(tutorial) or not tutorial.completed or tutorial.visible:
		_fail("Actual Retry action did not complete and persist the tutorial")
		return
	_trace("RETRY: real result button click invoked production retry callback and completed the tutorial")
	var trace_file := FileAccess.open(output_directory.path_join("tutorial_interaction_trace.txt"), FileAccess.WRITE)
	trace_file.store_string("BCM-M32-TUTORIAL-V05\nRESOLUTION=%s\nRENDERER=%s\n" % [resolution_label, RenderingServer.get_video_adapter_name()])
	trace_file.store_string("\n".join(trace_lines) + "\nRESULT=PASS\n")
	trace_file.close()
	print("TUTORIAL_V05_CAPTURE_RESULT=PASS resolution=%s evidence=%s" % [resolution_label, output_directory])
	quit(0)


func _drag_to_fire(from: Vector2, to: Vector2) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = from
	get_root().push_input(down)
	await process_frame
	var motion := InputEventMouseMotion.new()
	motion.position = to
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	get_root().push_input(motion)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = to
	get_root().push_input(up)
	await process_frame


func _click_control(control: Control) -> void:
	if not is_instance_valid(control):
		_fail("Tutorial or Results button was missing for a real click")
		return
	var position := control.get_global_rect().get_center()
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = position
	get_root().push_input(down)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = position
	get_root().push_input(up)
	await process_frame


func _wait_until_settled(drink: Drink) -> void:
	for _frame in MAX_WAIT_FRAMES:
		if not is_instance_valid(drink) or drink.motion_state == Drink.MotionState.SETTLED:
			return
		await process_frame


func _wait_for_step(expected_step: int) -> bool:
	for _frame in MAX_WAIT_FRAMES:
		if is_instance_valid(tutorial) and int(tutorial.current_step) >= expected_step:
			return int(tutorial.current_step) == expected_step
		await process_frame
	return false


func _capture_step(step: int, name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := get_root().get_texture().get_image()
	if image.is_empty() or image.get_size() != get_root().size:
		_fail("Runtime frame %s had unexpected image size %s" % [name, str(image.get_size())])
		return
	var filename := "tutorial_%02d_%s.png" % [step, name]
	var path := output_directory.path_join(filename)
	if image.save_png(path) != OK:
		_fail("Could not save original runtime frame %s" % filename)
		return
	_trace("CAPTURE: step=%02d name=%s size=%s file=%s" % [step, name, str(image.get_size()), filename])


func _trace(line: String) -> void:
	trace_lines.append(line)
	print("TUTORIAL_V05_TRACE %s" % line)


func _fail(message: String) -> void:
	failures.append(message)
	push_error(message)
	print("TUTORIAL_V05_CAPTURE_RESULT=FAIL resolution=%s" % resolution_label)
	quit(1)
