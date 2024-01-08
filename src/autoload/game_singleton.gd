extends Node

const PLAYER_UI_SIGNALS := {
	"health_changed": "player_health_changed",
	"max_health_changed": "player_max_health_changed",
	"ammo_changed": "player_ammo_changed",
	"max_ammo_changed": "player_max_ammo_changed",
	"weapon_changed": "player_weapon_changed"
}

const BOSS_UI_SIGNALS := {
	"health_changed": "boss_health_changed",
	"max_health_changed": "boss_max_health_changed"
}

var _player: AlienSoldier
var _boss: Node
var _game_ui: AlienSoldierUI

var _onscreen_enemies := [] setget ,get_onscreen_enemies

var _player_ui_connected := false
var _boss_ui_connected := false

func get_player() -> AlienSoldier:
	return _player

func get_onscreen_enemies() -> Array:
	return _onscreen_enemies

func register_player_character(player: AlienSoldier):
	assert(not _player)
	_player = player
	try_connect_player_ui()

func unregister_player_character(player: AlienSoldier):
	assert(player and player == _player)
	try_disconnect_player_ui()
	_player = null

func register_boss_character(boss: Node):
	assert(not _boss)
	_boss = boss
	try_connect_boss_ui()

func unregister_boss_character(boss: Node):
	assert(boss and boss == _boss)
	try_disconnect_boss_ui()
	_boss = null

func register_game_ui(game_ui: AlienSoldierUI):
	assert(not _game_ui)
	_game_ui = game_ui
	try_connect_player_ui()
	try_connect_boss_ui()

func unregister_game_ui(game_ui: AlienSoldierUI):
	assert(game_ui and game_ui == _game_ui)
	try_disconnect_player_ui()
	try_disconnect_boss_ui()
	_game_ui = null

func try_connect_player_ui() -> void:
	if _player_ui_connected:
		return

	if not _player:
		return

	if not _game_ui:
		return

	for signal_name in PLAYER_UI_SIGNALS:
		assert(not _player.is_connected(signal_name, _game_ui, PLAYER_UI_SIGNALS[signal_name]))
		var connect_result = _player.connect(signal_name, _game_ui, PLAYER_UI_SIGNALS[signal_name])
		assert(connect_result == OK)

	_player.init_signals()

	_player_ui_connected = true

func try_disconnect_player_ui() -> void:
	if not _player_ui_connected:
		return

	if not _player:
		return

	if not _game_ui:
		return

	for signal_name in PLAYER_UI_SIGNALS:
		assert(_player.is_connected(signal_name, _game_ui, PLAYER_UI_SIGNALS[signal_name]))
		_player.disconnect(signal_name, _game_ui, PLAYER_UI_SIGNALS[signal_name])

	_player_ui_connected = false

func try_connect_boss_ui() -> void:
	if _boss_ui_connected:
		return

	if not _boss:
		return

	if not _game_ui:
		return

	for signal_name in BOSS_UI_SIGNALS:
		assert(not _boss.is_connected(signal_name, _game_ui, BOSS_UI_SIGNALS[signal_name]))
		var connect_result = _boss.connect(signal_name, _game_ui, BOSS_UI_SIGNALS[signal_name])
		assert(connect_result == OK)

	_boss.init_signals()

	_boss_ui_connected = true

func try_disconnect_boss_ui() -> void:
	if not _boss_ui_connected:
		return

	if not _boss:
		return

	if not _game_ui:
		return

	for signal_name in BOSS_UI_SIGNALS:
		assert(_boss.is_connected(signal_name, _game_ui, BOSS_UI_SIGNALS[signal_name]))
		_boss.disconnect(signal_name, _game_ui, BOSS_UI_SIGNALS[signal_name])

	_boss_ui_connected = false


func register_onscreen_enemy(node: Node) -> void:
	assert(not node in _onscreen_enemies)
	_onscreen_enemies.append(node)

func unregister_onscreen_enemy(node: Node) -> void:
	assert(node in _onscreen_enemies)
	_onscreen_enemies.erase(node)
