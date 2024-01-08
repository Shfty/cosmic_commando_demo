class_name LoadingScreen
extends ColorRect
tool

signal transition_finished()

enum CornerWidget {
	None,
	Spinner,
	PressButtonArrow
}

export(bool) var hide_loading_bars := false setget set_hide_loading_bars
export(CornerWidget) var corner_widget: int = CornerWidget.Spinner setget set_corner_widget

func set_hide_loading_bars(new_hide_loading_bars: bool) -> void:
	if hide_loading_bars != new_hide_loading_bars:
		hide_loading_bars = new_hide_loading_bars
		if is_inside_tree():
			update_loading_bar_visibility()

func set_corner_widget(new_corner_widget: int) -> void:
	if corner_widget != new_corner_widget:
		corner_widget = new_corner_widget
		if is_inside_tree():
			update_corner_widget_visibility()

func hide() -> void:
	$TransitionAnimationPlayer.play("transition_out")

func show() -> void:
	visible = true
	$TransitionAnimationPlayer.play("transition_in")

func animation_finished(animation: String) -> void:
	match animation:
		"transition_out":
			visible = false
			emit_signal("transition_finished")
		"transition_in":
			emit_signal("transition_finished")

func _ready() -> void:
	var connect_result = $TransitionAnimationPlayer.connect("animation_finished", self, "animation_finished")
	assert(connect_result == OK)

	update_loading_bar_visibility()
	update_corner_widget_visibility()

func update_loading_bar_visibility() -> void:
	$LoadingBarMargin.visible = not hide_loading_bars

func update_corner_widget_visibility() -> void:
	$CornerWidgets/Spinner.visible = corner_widget == CornerWidget.Spinner
	$CornerWidgets/PressButtonArrow.visible = corner_widget == CornerWidget.PressButtonArrow

func reset_progress() -> void:
	set_loading_progress(0.0)
	set_instancing_progress(0.0)
	set_populating_progress(0.0)

func set_loading_progress(progress: float) -> void:
	$LoadingBarMargin/LoadingBarHBox/ProgressBarVBox/LoadingProgress.value = progress

func set_instancing_progress(progress: float) -> void:
	$LoadingBarMargin/LoadingBarHBox/ProgressBarVBox/InstancingProgress.value = progress

func set_populating_progress(progress: float) -> void:
	$LoadingBarMargin/LoadingBarHBox/ProgressBarVBox/PopulatingProgress.value = progress
