import java.util.Map;

class Day10 extends DayBase {
    final Point2[] GridVectors = new Point2[] {
        new Point2(0, -1), new Point2(1, 0), new Point2(0, 1), new Point2(-1, 0)
    };
    
    final byte ConnectNorthSouth = (1 | 1 << 2);
    final byte ConnectEastWest   = (1 << 1 | 1 << 3);
    final byte ConnectNorthEast  = (1 | 1 << 1);
    final byte ConnectNorthWest  = (1 | 1 << 3);
    final byte ConnectSouthEast  = (1 << 2 | 1 << 1);
    final byte ConnectSouthWest  = (1 << 2 | 1 << 3);

    private Day10ParsingData parsingData;
    
    Day10() {
        super();
        this.isImplemented = true;
    }

    void part1() {
        int answer = this.parsingData.path.size() / 2;
        println("Part 1: Farthest point is " + answer + " steps away");
    }
    void part2() {}
        

    void run() {
        this.parsingData.isParsingData = true;
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        // Check start is valid
        if (!this.parsingData.isStartValid) {
            int i;
            char c;
            Point2 direction;
            MapDirection mapDir;

            int dirIndex = 0;
            int k = GridVectors.length;
            Point2 vec = new Point2(0,0);

            for (i = 0; i < GridVectors.length; i++) {
                direction = GridVectors[i];
                vec.x = this.parsingData.startX + direction.x;
                vec.y = this.parsingData.startY + direction.y;

                if (vec.y < 0 || vec.y >= this.parsingData.map.length || vec.x < 0 || vec.x >= this.parsingData.map[vec.y].length) {
                    continue;
                }

                c = this.parsingData.map[vec.y][vec.x];
                // println("Checking direction " + i + ", map position " + vec.x + "," + vec.y + " '" + c + "'");

                mapDir = Directions.mapDirections[Directions.reverseMapDirection(i)];
                if (this.doesConnectTo(c, mapDir)) {
                    // println("Start connects to direction " + i);
                    if (i < k) { k = i; }
                    dirIndex |= 1 << i;
                }
            }
            
            c = this.getCharFromConnectionFlags(dirIndex);
            // println("Start connections bitVal: " + dirIndex + " resolves to char " + c);

            if (c == 'X') {
                println("ERROR: Unable to validate start position!");
                return true;
            }
            
            // println("Start dir: " + dirIndex + " resolves to char " + c);

            this.parsingData.path.add(new Point2(this.parsingData.startX, this.parsingData.startY));
            this.parsingData.startPipe = c;
            this.parsingData.loopX = this.parsingData.startX;
            this.parsingData.loopY = this.parsingData.startY;
            this.parsingData.loopNextDirection = k;
            this.parsingData.isStartValid = true;
            
            println("Start position: " + this.parsingData.startX + "," + this.parsingData.startY + ", start direction: " + k);

            return false;
        }

        if (!this.parsingData.isLoopFound) {
            Point2 dir = GridVectors[this.parsingData.loopNextDirection];
            Point2 vec = new Point2(this.parsingData.loopX, this.parsingData.loopY);
            char c = this.parsingData.map[vec.y][vec.x];

            // println("Looking from '" + c + "' at " + vec.x + "," + vec.y + " to dir " +
            //     this.parsingData.loopNextDirection + ": " + dir.x + "," + dir.y);

            vec.x += dir.x;
            vec.y += dir.y;

            if (vec.x == this.parsingData.startX && vec.y == this.parsingData.startY) {
                this.parsingData.isLoopFound = true;
                this.parsingData.isParsingData = false;
                println("Loop validated, path length is " + this.parsingData.path.size());
                return false;
            } else {
                // println("Next position " + vec.x + "," + vec.y + " is not start position " + this.parsingData.startX + "," + this.parsingData.startY);
                this.parsingData.path.add(new Point2(vec.x, vec.y));
                if (this.parsingData.path.size() % 100 == 0) {
                    println("Path length: " + this.parsingData.path.size() + " < " + this.parsingData.mapArea);
                }
            }

            c = this.parsingData.map[vec.y][vec.x];
            
            this.parsingData.loopFromDirection = Directions.reverseMapDirection(this.parsingData.loopNextDirection);
            this.parsingData.loopNextDirection = this.getNextDirection(c, this.parsingData.loopFromDirection);

            if (this.parsingData.loopNextDirection == -1) {
                println("ERROR: Unable to get next direction at position " + vec.x + "," + vec.y);
                return true;
            }

            // dir = GridVectors[this.parsingData.loopNextDirection];
            // println("Moved from " + this.parsingData.loopX + "," + this.parsingData.loopY + " to '" + c + "' at " + vec.x + "," + vec.y + ", next direction is " +
            //     this.parsingData.loopNextDirection + ": " + dir.x + "," + dir.y);

            this.parsingData.loopX = vec.x;
            this.parsingData.loopY = vec.y;
            
            return false;
        }

        return true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    int getNextDirection(char c, int fromDir) {
        for (int i = 0; i < Directions.mapDirections.length; i++) {
            if (i == fromDir) { continue; }
            if (this.doesConnectTo(c, Directions.mapDirections[i])) { return i; }
        }

        return -1;
    }

    boolean doesConnectTo(char c, MapDirection d) {
        switch (c) {
            case '|': return d == MapDirection.North || d == MapDirection.South;
            case '-': return d == MapDirection.East  || d == MapDirection.West;
            case 'L': return d == MapDirection.North || d == MapDirection.East;
            case 'J': return d == MapDirection.North || d == MapDirection.West;
            case '7': return d == MapDirection.South || d == MapDirection.West;
            case 'F': return d == MapDirection.South || d == MapDirection.East;
        }

        return false;
    }

    char getCharFromConnectionFlags(int flags) {
        switch (flags) {
            case ConnectNorthSouth: return '|';
            case ConnectEastWest:   return '-';
            case ConnectNorthEast:  return 'L';
            case ConnectNorthWest:  return 'J';
            case ConnectSouthEast:  return 'F';
            case ConnectSouthWest:  return '7';
        }

        return 'X';
    }

    Point2 gridVectorFromMapDirection(MapDirection from) {
        return GridVectors[Directions.getIndexOfMapDirection(from)];
    }

    void stepParsingInputData() {
        if (this.parsingData.inputLineIndex >= this.parsingData.input.length) {
            if (!this.parsingData.isStartFound) {
                println("ERROR: Unable to find start position!");
            }
            println("Map parsed, found " + this.parsingData.spaces.size() + " empty spaces");
            this.parsingData.isParsingData = false;
            return;
        }

        char c;
        for (int i = 0; i < this.parsingData.width; i++) {
            c = this.parsingData.input[this.parsingData.inputLineIndex].charAt(i);
            this.parsingData.map[this.parsingData.inputLineIndex][i] = c;
            if (c == 'S') {
                println("Found start at position " + i + " of line " + this.parsingData.inputLineIndex);
                this.parsingData.startX = i;
                this.parsingData.startY = this.parsingData.inputLineIndex;
                this.parsingData.isStartFound = true;
            } else {
                // println("'" + c + "' is not starting position, at " + i + "," + this.parsingData.inputLineIndex);
                if (c == '.') {
                    this.parsingData.spaces.add(new Point2(i, this.parsingData.inputLineIndex));
                }
            }
        }

        this.parsingData.inputLineIndex++;
        return;
    }

    void createParsingData(String[] input) {
        this.parsingData = new Day10ParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {}

    DayVisualBase getVisualization() {
        return null;
    }
}

class Day10ParsingData extends ParsingData {
    public char[][] map;
    public int width;
    public int height;
    public int mapArea;
    public ArrayList<Point2> spaces;
    public boolean isStartFound;
    public boolean isStartValid;
    public char startPipe;
    public int startX;
    public int startY;
    public boolean isLoopFound;
    public int loopLength;
    public int loopFromDirection;
    public int loopNextDirection;
    public int loopX;
    public int loopY;
    public ArrayList<Point2> path;

    Day10ParsingData(String[] input) {
        super(input);
        this.isStartFound = false;
        this.isStartValid = false;
        this.startPipe = 'S';
        this.startX = -1;
        this.startY = -1;
        this.isLoopFound = false;
        this.loopLength = 0;
        this.loopFromDirection = -1;
        this.loopNextDirection = -1;
        this.loopX = -1;
        this.loopY = -1;
        this.path = new ArrayList<Point2>();
        this.spaces = new ArrayList<Point2>();
        this.map = new char[input.length][];

        this.width = input[0].length();
        this.height = input.length;
        this.mapArea = this.width * this.height;
        println("Map dimensions " + this.width + "x" + this.height + " has an area of " + this.mapArea);

        for (int y = 0; y < this.height; y++) {
            this.map[y] = new char[this.width];
        }
    }
}