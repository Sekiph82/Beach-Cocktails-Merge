extends Node

## Test-only entrypoint copied into the isolated owner-review project.
## It launches the real application shell and Campaign level, then opens the
## production tutorial. The owner's normal project and campaign saves are not
## touched because the launcher changes the copied project's application name.

const APPLICATION_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")


func _ready() -> void:
	var application := APPLICATION_SCENE.instantiate()
	application.name = "ApplicationShell"
	add_child(application)
	await get_tree().process_frame

	if application.is_onboarding_visible():
		application.skip_onboarding()
	if not application.press_play_continue():
		push_error("Tutorial review bootstrap could not open the first campaign level.")
		return

	await get_tree().process_frame
	var gameplay = application.campaign_navigation.get_node_or_null("CampaignGameplay")
	if not is_instance_valid(gameplay) or not gameplay.has_method("start_guided_tutorial"):
		push_error("Tutorial review bootstrap could not find production campaign gameplay.")
		return
	if not gameplay.start_guided_tutorial(true):
		push_error("Tutorial review bootstrap could not start the production tutorial.")
		return
	var tutorial = gameplay.get_node_or_null("GameplayTutorial")
	if not is_instance_valid(tutorial) or not tutorial.visible:
		push_error("Tutorial review bootstrap started without a visible production tutorial overlay.")
		return
	print("TUTORIAL_OWNER_REVIEW_VISIBLE=true step=%d" % tutorial.current_step)

	if OS.get_cmdline_user_args().has("--capture-only"):
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var screenshot := get_viewport().get_texture().get_image()
		var screenshot_path := ProjectSettings.globalize_path("user://tutorial_owner_review_capture.png")
		var error := screenshot.save_png(screenshot_path)
		if error != OK:
			push_error("Tutorial review screenshot failed with error %d." % error)
		else:
			print("TUTORIAL_OWNER_REVIEW_CAPTURE=%s" % screenshot_path)
		get_tree().quit(0 if error == OK else 1)
