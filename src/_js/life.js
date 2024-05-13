const DEBUG = (document.location.hostname == "localhost" || document.location.href.includes('debug'));

//ANIMATION MANAGEMENT
var oFPS = {
	fps: 12,
	now: window.performance.now(),
	prev: window.performance.now(),
	timeout: {}
}


// CANVAS MANAGEMENT
const context = document.getElementsByTagName("canvas")[0].getContext("2d");
let width = 150;
let height = 150;

class GameWorld 
{
	static numRows = 60;
	static numColumns = 100;
	static mortalityRate = 1;// % of death each generation
	static intialPopulation = 50;// % of cells to start with
	static maxCells = 1000;
	static numCells = 0;
	static aliveCells = 0;
	static minPopulation = 3;

	static cells = [];

	static neighbourCellsMap = [
	    [-1, -1], [0, -1], [1, -1],
	    [-1, 0],           [1, 0],
	    [-1, 1],  [0, 1],  [1, 1]
	];

	constructor (context) 
	{
		console.log("GameWorld.constructor");
	}

}



class Cell
{
    // Set the default size and color for each cell
    static width = 10;
    static height = 10;
    static colorAlive = '#00CCCC';
    static colorDead = '#00CCCC11';
    static shape = "circle";
    static context = false;
    static isAlive = false;
    static isAliveNextFrame = false;

    constructor (context, gridX, gridY)
    {
        this.context = context;

        // Store the position of this cell in the grid
        this.gridX = gridX;
        this.gridY = gridY;

        // Make random cells alive
        this.isAlive = this.isAliveNextFrame = Math.random() > (1-(GameWorld.intialPopulation / 100));
    }

    draw() {
        this.context.fillStyle = this.isAlive ? Cell.colorAlive : Cell.colorDead;

        switch(Cell.shape) {
        case "circle":
	        var r = (Cell.width/4);
	        var x = (this.gridX * Cell.width) + r;
	        var y = (this.gridY * Cell.height) + r;

			// this.context.translate(x, y);
			this.context.beginPath();
			this.context.arc(x, y, r, 0, 360, false);
			this.context.fill();
    	break;
        default:
	        // this.context.fillRect(this.gridX * Cell.width, this.gridY * Cell.height, Cell.width, Cell.height);
			this.context.beginPath();
	        this.context.roundRect(this.gridX * Cell.width, this.gridY * Cell.height, Cell.width, Cell.height, (Cell.width/4));
	        this.context.fill();
    	break;
        }
    }
}

function createGrid()
{
	console.log("CreateGrid",GameWorld.numRows + "x" + GameWorld.numColumns);
 	GameWorld.cells = [];
    for (let y = 0; y < GameWorld.numRows; y++) {
        for (let x = 0; x < GameWorld.numColumns; x++) {
            GameWorld.cells.push(new Cell(context, x, y));
        }
    }
    GameWorld.numCells = GameWorld.cells.length;
}

function updateCells() {
    // Loop over all cells and calculate the amount of alive neighbours
    for (let x = 0; x < GameWorld.numColumns; x++) {
        for (let y = 0; y < GameWorld.numRows; y++) {
			var r = Math.random(),
				c = GameWorld.mortalityRate/100;
            var numAliveNeighbours = getNumAliveNeighbours(x, y)

		    let centerCell = GameWorld.cells[this.gridToIndex(x, y)];

			if (numAliveNeighbours == 2){
			    // Do nothing
			    centerCell.isAliveNextFrame = centerCell.isAlive;
			}else if (numAliveNeighbours == 3){
			    // Make alive
			    centerCell.isAliveNextFrame = true;
			}else{
			    // Make dead
			    centerCell.isAliveNextFrame = false;
			}

        }
    }
    GameWorld.aliveCells = 0;
	// Apply the new state to all the cells at once
	for(n = 0;n < GameWorld.numCells; n++) {
		GameWorld.cells[n].isAlive = GameWorld.cells[n].isAliveNextFrame;
		GameWorld.aliveCells += (GameWorld.cells[n].isAlive) ? 1 : 0;
	}
}


// chaos generator
// 1 in 10 they split
// 1 in 10 they die
// 8 in 10 status quote

function getNumAliveNeighbours(x, y) {
    // Check every surrounding cell, using the neighbourCellsMap
    return GameWorld.neighbourCellsMap.reduce(
    	(numNeighbours, [dx, dy]) => {
	        return numNeighbours + (isCellAlive(x + dx, y + dy) ? 1 : 0);
    	}, 
	0);
}

function isCellAlive(x, y) {
    // Respect grid boundaries
    if (x < 0 || x >= GameWorld.numColumns || y < 0 || y >= GameWorld.numRows){
        return false;
    }

    return GameWorld.cells[gridToIndex(x, y)].isAlive;
}

function gridToIndex(x, y){
    return x + (y * GameWorld.numColumns);
}

function drawCells () {

    // Clear the screen
    context.clearRect(0, 0, width, height);

    // Draw all the gamecells
    GameWorld.cells.forEach((gameCell) => {
      gameCell.draw();
    });

}

function animationLoop (argument) {

	// FRAME SCHEDULING
	oFPS.now = window.performance.now();
	const msPassed = oFPS.now - oFPS.prev;

	// set FPS to program spec
	oFPS.timeout = setTimeout(animationLoop,oFPS.ms);
	if (msPassed < (1000 / oFPS.fps)) return;
	// set FPS to display refresh rate
	// requestAnimationFrame(animationLoop);

	oFPS.prev = oFPS.now;
	updateStats(1000 / msPassed);

    updateCells();
    drawCells();

	var p = (GameWorld.aliveCells / GameWorld.numCells * 100);
	if(p <= GameWorld.minPopulation) {
		clearTimeout(oFPS.timeout);
		setTimeout(initGame,2000);
	}

}

function updateStats(_fps) {
  var str = "fps: " + Math.round(_fps) + "\n";
      str +="obj: " + GameWorld.numCells + "\n";
      str +="alv: " + Math.round(GameWorld.aliveCells / GameWorld.numCells * 100,2) + "%";

  document.getElementById("fps").textContent = str;
}


function initGame(argument) {
	sizeCanvas();

	createGrid();

	// Schedule the main animation loop
	window.requestAnimationFrame(animationLoop);
}

// Called initially and whenever the window resizes to update the canvas
// size and width/height variables.
function sizeCanvas() {
	if(DEBUG) console.log("sizeCanvas",arguments);

	const canvas = document.getElementsByTagName("canvas")[0];
	width = window.innerWidth;
	height = window.innerHeight;
	canvas.width = width;
	canvas.height = height;

	var pixels = width * height;
	var cellArea = pixels / GameWorld.maxCells;
	//uncomment this if you need to limit the cells due to performance concerns
	// Cell.width = Cell.height = Math.ceil(Math.sqrt(cellArea));

	GameWorld.numColumns = Math.ceil(width / Cell.width);
	GameWorld.numRows = Math.ceil(height / Cell.height);
	// console.log(GameWorld.numRows + "x" + GameWorld.numColumns);
}

window.onload = () => {
	// Make sure the canvas always fills the whole window
	window.addEventListener("resize", sizeCanvas, false);

	initGame();

	if(!DEBUG) {
		document.getElementById("fps").style.display = "none";
	}
};
