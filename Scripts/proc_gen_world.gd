# Questo script estende Node2D, indicando che è un nodo di tipo 2D nel motore Godot
# Node2D è una classe base per oggetti 2D nel motore Godot, permettendo di posizionare, scalare e ruotare nodi.
extends Node2D

# Dichiarazione di una variabile esportabile (visibile e modificabile dall'editor) di tipo NoiseTexture2D
# Permette di modificare il NoiseTexture2D dall'editor senza dover cambiare il codice.
@export var noise_height_text : NoiseTexture2D

# Dichiarazione di una variabile di tipo Noise
# Noise sarà utilizzato per generare valori di rumore per la creazione del terreno.
var noise : Noise

# Dichiarazione e inizializzazione di due variabili intere per la larghezza e l'altezza
# Specificano le dimensioni dell'area in cui generare il terreno.
var width : int = 200
var height : int = 200

# Dichiarazione e inizializzazione di variabili che fanno riferimento a nodi specifici nella scena tramite il loro path
# @onready assicura che questi nodi siano pronti all'uso quando il nodo principale è pronto.
@onready var tile_map = $TileMap
@onready var camera_2d = $Player/Camera2D

# Dichiarazione e inizializzazione di variabili per identificare la sorgente e le posizioni delle tile nei tile atlas
# Usate per identificare quali tile utilizzare per i diversi tipi di terreno.
var source_id = 0
var water_atlas = Vector2i(6, 13)
var dirt_atlas = Vector2i(6, 0)
var grass_atlas = Vector2i(1, 1)

# Dichiarazione e inizializzazione di variabili per identificare i layer del terreno
# Definisce i layer per i diversi tipi di terreno nel TileMap.
var dirt_layer = 0
var grass_layer = 1
var water_layer = 2

# Dichiarazione e inizializzazione di array per memorizzare le coordinate delle tile di sabbia, erba e scogliera
# Permettono di tenere traccia delle coordinate delle tile per ciascun tipo di terreno.
var dirt_tiles_arr = []
var terrain_dirt_int = 1

var grass_tiles_arr = []
var terrain_grass_int = 2

var water_tiles_arr = []
var terrain_water_int = 3

# Dichiarazione di un array per memorizzare i valori del noise
# Memorizza i valori del noise generati per l'area di terreno.
var noise_val_arr = []

# Funzione chiamata quando il nodo è pronto
# Esegue inizializzazioni che richiedono che tutti i nodi siano pronti.
func _ready():
	# Assegnazione della proprietà noise dell'oggetto NoiseTexture2D alla variabile noise
	# Collega il NoiseTexture2D esportato al noise per generare valori di rumore.
	noise = noise_height_text.noise
	# Chiamata alla funzione per generare il mondo
	# Avvia la generazione del terreno all'avvio del gioco.
	generate_world()
	
# Funzione per generare il mondo
# Genera il terreno basato sui valori di rumore.
func generate_world():
	# Loop attraverso ogni colonna (x) fino alla larghezza specificata
	for x in range(-width/2, width/2):
		# Loop attraverso ogni riga (y) fino all'altezza specificata
		for y in range(-height/2, height/2):
			# Ottiene il valore del noise per le coordinate (x, y)
			# Genera un valore di rumore per le coordinate attuali.
			var noise_val = noise.get_noise_2d(x, y)
			
			# Verifica se il valore del noise è maggiore o uguale a -0.2
			# Determina se la posizione attuale è sabbia.
			if noise_val >= -0.3:
				# Aggiunge le coordinate (x, y) all'array delle tile di sabbia
				
				dirt_tiles_arr.append(Vector2i(x, y))
				
				# Verifica se il valore del noise è maggiore di 0.0
				# Determina se la posizione attuale è erba.
				if noise_val >= 0.32:
					# Aggiunge le coordinate (x, y) all'array delle tile di erba
					grass_tiles_arr.append(Vector2i(x, y))
					
					# Verifica se il valore del noise è maggiore di 0.3
					# Determina se la posizione attuale è una scogliera.
					if noise_val >= 0.5:
						# Aggiunge le coordinate (x, y) all'array delle tile di scogliera
						water_tiles_arr.append(Vector2i(x, y))

			
			tile_map.set_cell(dirt_layer, Vector2(x,y), source_id, dirt_atlas)
			
			# Aggiunge il valore del noise all'array noise_val_arr
			# Memorizza il valore del noise per scopi di debug o ulteriori elaborazioni.
			noise_val_arr.append(noise_val)
	
	# Stampa il valore massimo del noise
	# Debug per vedere il valore massimo del noise generato.
	print("Noise value ++ : ", noise_val_arr.max())
	# Stampa il valore minimo del noise
	# Debug per vedere il valore minimo del noise generato.
	print("Noise value -- : ", noise_val_arr.min())
	
	# Imposta le tile di sabbia nel TileMap usando la connessione delle tile
	# Utilizza il sistema di connessione delle tile per posizionare le tile di sabbia.
	tile_map.set_cells_terrain_connect(dirt_layer, dirt_tiles_arr, terrain_dirt_int, 0)
	# Imposta le tile di erba nel TileMap usando la connessione delle tile
	# Utilizza il sistema di connessione delle tile per posizionare le tile di erba.
	tile_map.set_cells_terrain_connect(grass_layer, grass_tiles_arr, terrain_grass_int, 0)
	# Imposta le tile di scogliera nel TileMap usando la connessione delle tile
	# Utilizza il sistema di connessione delle tile per posizionare le tile di scogliera.
	tile_map.set_cells_terrain_connect(water_layer, water_tiles_arr, terrain_water_int, 0)

# Funzione per gestire l'input dell'utente
# Permette di zoomare avanti e indietro nella scena.
func _input(event):
	# Controlla se l'azione "zoom_in" è stata appena premuta
	if Input.is_action_just_pressed("zoom_in"):
		# Aumenta il valore di zoom della camera di 0.1
		# Incrementa il livello di zoom della camera.
		var zoom_val = camera_2d.zoom.x + 0.1
		# Imposta il nuovo valore di zoom per la camera
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	# Controlla se l'azione "zoom_out" è stata appena premuta
	elif Input.is_action_just_pressed("zoom_out"):
		# Diminuisce il valore di zoom della camera di 0.1
		# Decrementa il livello di zoom della camera.
		var zoom_val = camera_2d.zoom.x - 0.1
		# Se il valore di zoom è 0, lo decrementa ulteriormente di 0.2 per evitare divisione per zero
		# Evita che il valore di zoom diventi zero, il che causerebbe problemi di visualizzazione.
		if zoom_val == 0:
			zoom_val = camera_2d.zoom.x - 0.2
		# Imposta il nuovo valore di zoom per la camera
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
