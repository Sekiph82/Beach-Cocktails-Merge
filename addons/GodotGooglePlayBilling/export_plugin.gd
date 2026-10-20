@tool
extends EditorPlugin

# A class member to hold the editor export plugin during its lifecycle.
var export_plugin : BillingPluginExportPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	export_plugin = BillingPluginExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_export_plugin(export_plugin)
	export_plugin = null


class BillingPluginExportPlugin extends EditorExportPlugin:
	var _plugin_name = "GodotGooglePlayBilling"
	var _native_billing_export_enabled := false

	func _export_begin(features, _is_debug, _path, _flags):
		_native_billing_export_enabled = features.has("m34_store_billing_enabled")

	func _supports_platform(platform):
		if platform is EditorExportPlatformAndroid:
			return true
		return false

	func _get_android_libraries(platform, debug):
		if not _native_billing_export_enabled:
			return PackedStringArray()
		if debug:
			return PackedStringArray([_plugin_name + "/bin/debug/" + _plugin_name + "-debug.aar"])
		else:
			return PackedStringArray([_plugin_name + "/bin/release/" + _plugin_name + "-release.aar"])

	func _get_android_dependencies(platform, debug):
		if not _native_billing_export_enabled:
			return PackedStringArray()
		if debug:
			return PackedStringArray(["com.android.billingclient:billing-ktx:9.1.0"])
		else:
			return PackedStringArray(["com.android.billingclient:billing-ktx:9.1.0"])

	func _export_end():
		_native_billing_export_enabled = false

	func _get_name():
		return _plugin_name
