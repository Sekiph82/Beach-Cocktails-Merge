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
