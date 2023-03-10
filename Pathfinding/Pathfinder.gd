# A class to handle pathfinding on a given set of Tiles
extends Node

class_name Pathfinder

# A node2D containing columns, each containing tiles
var tiles : Node2D

func _init(tileMatrix : Node2D):
	tiles = tileMatrix

# might change to just return actual steps needed to take later
# return a list of coordinates from currentCoordinates -> newCoordinates (inclusive)
func findPathTo(newCoordinates : Vector2i, currentCoordinates : Vector2i) -> Array[Vector2i]:
	if currentCoordinates == newCoordinates:
		return []
	var queue : PriorityQueue = PriorityQueue.new()
	queue.put(currentCoordinates, 0)
	var came_from = {}
	var cost_so_far = {}
	came_from[currentCoordinates] = 0
	cost_so_far[currentCoordinates] = 0

# https://www.redblobgames.com/pathfinding/a-star/introduction.html
	while not queue.queue.is_empty():
		var currentLoc : Vector2i = queue.dequeue()
		if currentLoc == newCoordinates:
			break
		for tile in findOpenNeighbors(currentLoc):
			var currentMovementCost : float = tile.movementCost
			if isDiagNeighbor(tile.coordinates, currentLoc):
				currentMovementCost *= 1.2

			var new_cost = cost_so_far[currentLoc] \
			+ currentMovementCost # tile -> new tile
			
			if not tile.coordinates in cost_so_far or \
			new_cost < cost_so_far[tile.coordinates]:
				cost_so_far[tile.coordinates] = new_cost
				queue.put(tile.coordinates, new_cost)
				came_from[tile.coordinates] = currentLoc
	
	# check if destination is in map
	if not came_from.has(newCoordinates):
		return []
	
	# calculate specific path to destination
	var path : Array[Vector2i] = []
	path.append(newCoordinates)
	var nextStep = came_from[newCoordinates]
	while nextStep is Vector2i:
		path.push_front(nextStep) # now current Character loc -> destination
		nextStep = came_from[nextStep]
	return path 

func isDiagNeighbor(loc1: Vector2i, loc2: Vector2i) -> bool:
	var dx = loc2.x - loc1.x
	var dy = loc2.y - loc1.y
	if abs(dx) == abs(dy):
		return true
	return false

func findOpenNeighbors(currentLoc: Vector2i) -> Array[Tile]:
	var neighborTiles: Array[Tile] = []
	for i in [-1, 0, 1]:
		if currentLoc.x+i < 0 or currentLoc.x+i > tiles.get_child_count()-1:
			continue
		var currentColumn : Node2D = tiles.get_child(currentLoc.x+i)
		for j in [-1, 0, 1]:
			# the 0,0 tile is where currentLoc is
			if (i == 0 and j == 0) or currentLoc.y+j < 0 or \
			currentLoc.y+j > currentColumn.get_child_count()-1:
				continue
			var tile : Tile = currentColumn.get_child(currentLoc.y+j)
			# check impassibleness here
			if tile.tooltipText != "Rock":
				neighborTiles.append(tile)
			
	return neighborTiles


# HELPER CLASSES below

# the lower the priority number the quicker recieved
class DictionaryType:
	var priority : int
	var thing # could be anything oooo

	func _init(t, p: int):
		priority = p
		thing = t

# if I need to upgrade this check here: 
# https://www.geeksforgeeks.org/priority-queue-set-1-introduction/
class PriorityQueue:
	var queue: Array[DictionaryType]

	func _init():
		queue = []

	func put(thing, priority : int) -> void:
		var dict : DictionaryType = DictionaryType.new(thing, priority)
		queue.append(dict)
		
	func peek() -> DictionaryType:
		var nextOff : DictionaryType = null
		for item in queue:
	#                                changing < to > fixed everything!!!!
			if nextOff == null or nextOff.priority > item.priority:
				nextOff = item
		return nextOff

	func dequeue():
		if queue.size() == 0:
			return null
		var boutToLeave : DictionaryType = peek()
		queue.erase(boutToLeave)
		return boutToLeave.thing
	
