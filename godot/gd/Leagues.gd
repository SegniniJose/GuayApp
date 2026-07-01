extends Node
class_name Leagues

@onready var publicas: PanelContainer = %Publicas
@onready var codigo: PanelContainer = %Codigo
@onready var crear: PanelContainer = %Crear
@onready var publicas_button: Button = %PublicasButton
@onready var codigo_button: Button = %CodigoButton
@onready var crear_button: Button = %CrearButton

@onready var days: Button = %Dias
@onready var express: Button = %Express

@onready var duration_days_section: VBoxContainer = %DurationDaysSection
@onready var duration_express_section: VBoxContainer = %DurationExpressSection

@onready var public_private_switch: CheckButton = %PublicPrivateSwitch
@onready var days_duration_option_button: OptionButton = %DaysDurationOptionButton
@onready var express_duration_option_button: OptionButton = %ExpressDurationOptionButton
@onready var express_location_option_button: OptionButton = %ExpressLocationOptionButton2
@onready var league_name: LineEdit = %LeagueName

@onready var code_input: LineEdit = %CodeInput

@onready var public_leagues: VBoxContainer = %PublicLeaguesList

@export var public_league_scene: PackedScene = preload("res://tscn/cards/PublicLeagueCard.tscn")

enum TabNames { FOR_DAYS, EXPRESS }

var active_tab: TabNames = TabNames.FOR_DAYS


func _ready() -> void:
	await load_public_leagues()
	_on_publicas_pressed()
	_on_dias_pressed()

func refresh_public_leagues() -> void:
	for child in public_leagues.get_children():
		child.free()
	for public_league in Globals.public_leagues:
		var new_public_league = public_league_scene.instantiate()
		public_leagues.add_child(new_public_league)
		new_public_league.set_public_league(public_league)

func load_public_leagues() -> void:
	var callback = func(response: Array):
		print("Public League Success!", response)
		Globals.public_leagues.clear()
		Globals.public_leagues.assign(response)
		refresh_public_leagues()
	var url = Globals.get_api_leagues_public_url()
	await Globals.http_request_callback(self, url, callback)
	
func _on_publicas_pressed() -> void:
	codigo.visible = false
	crear.visible = false
	publicas.visible = true
	codigo_button.flat = true
	crear_button.flat = true
	publicas_button.flat = false


func _on_codigo_pressed() -> void:
	crear.visible = false
	publicas.visible = false
	codigo.visible = true
	crear_button.flat = true
	publicas_button.flat = true
	codigo_button.flat = false


func _on_crear_pressed() -> void:
	publicas.visible = false
	codigo.visible = false
	crear.visible = true
	publicas_button.flat = true
	codigo_button.flat = true
	crear_button.flat = false


func _on_submit_btn_pressed() -> void:
	var callback = func(response: Dictionary):
		print("_on_submit_btn_pressed", response)
		Globals.league_id = response.id
		get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
	var data = {
		"adminId": Globals.user_id,
		"isPublic": !public_private_switch.button_pressed,
		"name": league_name.text
	}

	match active_tab:
		TabNames.FOR_DAYS:
			data.durationDays = days_duration_option_button.get_selected_id()
		TabNames.EXPRESS:
			data.durationMinutes = express_duration_option_button.get_selected_id()
			if express_location_option_button.selected > 0:
				var venue_name = express_location_option_button.get_item_text(
					express_location_option_button.selected
				)
				data.venueName = venue_name

	var url: String = Globals.get_api_leagues_post_url()
	await Globals.http_post_callback(self, url, data, callback)


func _on_dias_pressed() -> void:
	active_tab = TabNames.FOR_DAYS
	duration_days_section.visible = true
	duration_express_section.visible = false


func _on_express_pressed() -> void:
	active_tab = TabNames.EXPRESS
	duration_express_section.visible = true
	duration_days_section.visible = false


func _on_join_button_pressed() -> void:
	get_league_for_code()


func get_league_for_code() -> void:
	var callback = func(response: Dictionary):
		print("get_league_for_code", response)
		Globals.league_id = response.id
		Globals.post_join_league_and_go_to_dashboard(self)
	var url = Globals.get_api_leagues_code_url(code_input.text)
	Globals.http_request_callback(self, url, callback)
