const DEBUG = (document.location.hostname == "localhost" || document.location.href.includes('debug'));

//ANIMATION MANAGEMENT
var oFPS = {
	fps: 24,
	ms: 1000 / 24,
	now: window.performance.now(),
	prev: window.performance.now()
}


// CANVAS MANAGEMENT
const context = document.getElementsByTagName("canvas")[0].getContext("2d");
// const context = document.getElementsByTagName("canvas")[0].getContext("webgl");


let width = 150;
let height = 150;
let diagnal = Math.sqrt(Math.pow(width,2) + Math.pow(height,2));

class GameWorld 
{
	static numRows = 60;
	static numColumns = 100;
	static mortalityRate = 2;// % of death each generation
	static intialPopulation = 90;// % of cells to start with
	static maxObjects = 1600;

	static objects = [];

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
    static width = 20;
    static height = 20;
    static colorAlive = '#00CCCC';
    static colorDead = '#00CCCC33';
    static shape = "circle";
    static context = false;
    // static isAlive = false;
    // static isAliveNextFrame = false;

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
    for (let y = 0; y < GameWorld.numRows; y++) {
        for (let x = 0; x < GameWorld.numColumns; x++) {
            GameWorld.objects.push(new Cell(context, x, y));
        }
    }
}

function updateCells() {
    // Loop over all cells and calculate the amount of alive neighbours
    for (let x = 0; x < GameWorld.numColumns; x++) {
        for (let y = 0; y < GameWorld.numRows; y++) {
            var numAliveNeighbours = getNumAliveNeighbours(x, y)

		    let centerCell = GameWorld.objects[this.gridToIndex(x, y)];

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

			// // Apply the new state to all the cells at once
			for(n = 0;n < GameWorld.objects.length; n++) {
				GameWorld.objects[n].isAlive = (GameWorld.objects[n].isAliveNextFrame && (Math.random() > (GameWorld.mortalityRate/100)));
			}
        }
    }
}

function getNumAliveNeighbours(x, y) {
    // Check every surrounding cell, using the neighbourCellsMap
    return GameWorld.neighbourCellsMap.reduce((numNeighbours, [dx, dy]) => {
        return numNeighbours + (isCellAlive(x + dx, y + dy) ? 1 : 0);
    }, 0);
}

function isCellAlive(x, y) {
    // Respect grid boundaries
    if (x < 0 || x >= GameWorld.numColumns || y < 0 || y >= GameWorld.numRows){
        return false;
    }

    return GameWorld.objects[gridToIndex(x, y)].isAlive;
}

function gridToIndex(x, y){
    return x + (y * GameWorld.numColumns);
}

function drawCells () {

    // Clear the screen
    context.clearRect(0, 0, width, height);

    // Draw all the gameobjects
    GameWorld.objects.forEach((gameObject) => {
      gameObject.draw();
    });

}

function drawCellsGL () {
	console.log('drawCellsGL',context);
    // Clear the screen
    context.clearColor((32/255), (28/255), (29/255), 1.0);
	context.clear(context.COLOR_BUFFER_BIT);

    // Draw all the gameobjects
    GameWorld.objects.forEach((gameObject) => {
      // gameObject.drawGL();
    });

}

function animationLoop (argument) {

	// FRAME SCHEDULING
	oFPS.now = window.performance.now();
	const msPassed = oFPS.now - oFPS.prev;
	setTimeout(animationLoop,oFPS.ms);
	if (msPassed < oFPS.ms) return;
	oFPS.prev = oFPS.now;
	updateStats(1000 / msPassed);
	// requestAnimationFrame(animationLoop);

    updateCells();
    drawCells();
}

function updateStats(_fps) {
  var str = "fps: " + Math.round(_fps) + "\n";
      str +="obj: " + GameWorld.objects.length;

  document.getElementById("fps").textContent = str;
}

// Called initially and whenever the window resizes to update the canvas
// size and width/height variables.
function sizeCanvas() {
	if(DEBUG) console.log("sizeCanvas",arguments);

	const canvas = document.getElementsByTagName("canvas")[0];
	width = window.innerWidth;
	height = window.innerHeight;
	diagnal = Math.sqrt(Math.pow(width,2) + Math.pow(height,2));
	canvas.width = width;
	canvas.height = height;

	var pixels = width * height;
	var area = pixels / GameWorld.maxObjects;
	var side = Math.ceil(Math.sqrt(area));
	Cell.width = Cell.height = side;
	GameWorld.numColumns = Math.ceil(width / side);
	GameWorld.numRows = Math.ceil(height / side);
	// console.log(GameWorld.numRows + "x" + GameWorld.numColumns);
}

window.onload = () => {
  // Make sure the canvas always fills the whole window
  window.addEventListener("resize", sizeCanvas, false);

  sizeCanvas();

	createGrid();

	// Schedule the main animation loop
	window.requestAnimationFrame(animationLoop);
};
