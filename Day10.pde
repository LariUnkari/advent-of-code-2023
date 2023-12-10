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
    void part2() {
        HashMap<Integer,Point2> closedMap = new HashMap<Integer,Point2>();
        HashMap<Integer,Point2> foundTilesMap = new HashMap<Integer,Point2>();
        
        int x, y, k;
        int size = 0;
        
        for (y = 0; y < this.parsingData.heightWithSubgrid; y++) {
            for (x = 0; x < this.parsingData.widthWithSubgrid; x++) {
                k = this.getSubgridPointIndex(x, y);

                if (closedMap.containsKey(k)) {
                    continue;
                }

                closedMap.put(k, new Point2(x, y));

                if (this.parsingData.pathMap.containsKey(k)) {
                    continue;
                }

                if (x % 2 == 0 && y % 2 == 0) {
                    foundTilesMap.put(k, new Point2(x, y));
                    // char c = this.parsingData.mapWithSubgrid[y][x];
                    // println("Putting initial tile '" + c + "' at " + x + "," + y + " to found tiles, index " + k);
                }

                size += this.findClosedArea(x, y, this.parsingData.widthWithSubgrid, this.parsingData.heightWithSubgrid,
                    closedMap, foundTilesMap, this.parsingData.pathMap);
            }
        }

        println("Part 2: found a total of " + size + " closed spaces");

        for (y = 0; y < this.parsingData.heightWithSubgrid; y++) {
            print("[");
            for (x = 0; x < this.parsingData.widthWithSubgrid; x++) {
                k = this.getSubgridPointIndex(x, y);
                if (this.parsingData.pathMap.containsKey(k)) {
                    print('+');
                } else if (foundTilesMap.containsKey(k)) {
                    print('I');
                } else {
                    print(this.parsingData.mapWithSubgrid[y][x]);
                }
                
            }
            println("]");
        }
    }

    int getPointIndex(int x, int y) {
        return y * this.parsingData.width + x;
    }

    int getSubgridPointIndex(int x, int y) {
        return y * this.parsingData.widthWithSubgrid + x;
    }

    int findClosedArea(int fromX, int fromY, int mapWidth, int mapHeight, HashMap<Integer,Point2> closedMap,
        HashMap<Integer,Point2> foundTilesMap, HashMap<Integer,Point2> pathMap) {

        ArrayList<Point2> openList = new ArrayList<Point2>();
        Point2 p = new Point2(fromX, fromY);
        openList.add(p);

        int listIndex = 0;
        int areaSize = fromX % 2 == 0 && fromY % 2 == 0 ? 1 : 0;

        int i, k, ax, ay, bx, by;
        char c;
        Point2 d, f;
        boolean isOpen = false;

        while (listIndex < openList.size()) {
            if (listIndex >= 1000000) {
                println("Panicking out after " + listIndex + " points visited");
                break;
            }

            f = openList.get(listIndex);
            ax = f.x;
            ay = f.y;
            // println("Seeking from sub grid position " + f.x + "," + f.y);

            for (i = 0; i < GridVectors.length; i++) {
                d = GridVectors[i];
                bx = ax + d.x;
                by = ay + d.y;

                if (bx < 0 || bx >= mapWidth || by < 0 || by >= mapHeight) {
                    // if (!isOpen) {
                    //     println("Found edge of area at " + bx + "," + by);
                    // }
                    isOpen = true;
                    continue;
                }

                k = this.getSubgridPointIndex(bx, by);
                if (closedMap.containsKey(k)) {
                    // println("Space " + bx + "," + by + " was already visited");
                    continue;    
                }

                p = new Point2(bx, by);
                closedMap.put(k, p);

                if (!pathMap.containsKey(k)) {
                    openList.add(p);

                    if (bx % 2 == 0 && by % 2 == 0) {
                        // println("Found new map space at " + bx + "," + by);
                        foundTilesMap.put(k, p);
                        areaSize++;
                    // } else {
                    //     println("Found new subgrid space at " + bx + "," + by);
                    }
                } else {
                    c = this.parsingData.mapWithSubgrid[by][bx];
                    // println("Found path space '" + c + "' at " + bx + "," + by);
                }
            }

            listIndex++;
        }

        // for (i = 1; i < openList.size(); i++) {
        //     p = openList.get(i);
        //     k = by * this.parsingData.height + bx;
        //     closedMap.put(k, p);
        // }

        if (areaSize > 0) {
            println("Found an area of size " + areaSize + " that is " + (isOpen ? "OPEN" : "CLOSED"));
        }

        return isOpen ? 0 : areaSize;
    }

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

                if (vec.y < 0 || vec.y >= this.parsingData.height || vec.x < 0 || vec.x >= this.parsingData.width) {
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

            vec = new Point2(2 * this.parsingData.startX, 2 * this.parsingData.startY);
            i = this.getSubgridPointIndex(vec.x, vec.y);
            this.parsingData.pathMap.put(i, vec);

            this.parsingData.path.add(new Point2(this.parsingData.startX, this.parsingData.startY));
            this.parsingData.startPipe = c;
            this.parsingData.loopX = this.parsingData.startX;
            this.parsingData.loopY = this.parsingData.startY;
            this.parsingData.loopNextDirection = k;
            this.parsingData.isStartValid = true;
            
            println("Start position: " + this.parsingData.startX + "," + this.parsingData.startY + ", subgrid position " + vec.x + "," + vec.y + ", start direction: " + k);

            return false;
        }

        if (!this.parsingData.isLoopFound) {
            Point2 dir = GridVectors[this.parsingData.loopNextDirection];
            Point2 vec = new Point2(this.parsingData.loopX, this.parsingData.loopY);
            Point2 sub = new Point2(0, 0);
            Point2 p;
            char c = this.parsingData.map[vec.y][vec.x];

            // println("Looking from '" + c + "' at " + vec.x + "," + vec.y + " to dir " +
            //     this.parsingData.loopNextDirection + ": " + dir.x + "," + dir.y);

            sub.x = 2 * vec.x + dir.x;
            sub.y = 2 * vec.y + dir.y;
            vec.x += dir.x;
            vec.y += dir.y;

            // First mark the subgrid place for part 2
            c = this.getCharFromConnectionFlags(1 << this.parsingData.loopNextDirection |
                1 << Directions.reverseMapDirection(this.parsingData.loopNextDirection));
            // println("Subgrid pipe at " + sub.x + "," + sub.y + " is '" + c + "' from direction " + this.parsingData.loopNextDirection);
            this.parsingData.mapWithSubgrid[sub.y][sub.x] = c;
            this.parsingData.pathMap.put(this.getSubgridPointIndex(sub.x, sub.y), new Point2(sub.x, sub.y));

            // Then proceed to actual position (total grid distance of 2)
            if (vec.x == this.parsingData.startX && vec.y == this.parsingData.startY) {
                println("Loop validated, path length is " + this.parsingData.path.size());
                this.parsingData.isLoopFound = true;
                this.parsingData.isParsingData = false;

                return false;
            } else {
                // println("Next position " + vec.x + "," + vec.y + " is not start position " + this.parsingData.startX + "," + this.parsingData.startY);
                p = new Point2(vec.x, vec.y);

                this.parsingData.path.add(p);

                sub.x = 2 * vec.x;
                sub.y = 2 * vec.y;
                this.parsingData.pathMap.put(this.getSubgridPointIndex(sub.x, sub.y), new Point2(sub.x, sub.y));

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
            
            this.parsingData.isParsingData = false;
            return;
        }

        char c;
        int y, sx, sy;

        for (int x = 0; x < this.parsingData.width; x++) {
            c = this.parsingData.input[this.parsingData.inputLineIndex].charAt(x);
            y = this.parsingData.inputLineIndex;
            sx = x * 2 + 1;
            sy = y * 2 + 1;
            this.parsingData.map[y][x] = c;

            // Also mark subgrid position as open space, it will be changed later if needed
            this.parsingData.mapWithSubgrid[2 * y][2 * x] = c;
            if (sx < this.parsingData.widthWithSubgrid && sy < this.parsingData.heightWithSubgrid) {
                this.parsingData.mapWithSubgrid[sy][sx] = '.';
            }

            if (c == 'S') {
                println("Found start at position " + x + " of line " + this.parsingData.inputLineIndex +
                    ", equating to position " + x + "," + y);

                this.parsingData.startX = x;
                this.parsingData.startY = y;
                this.parsingData.isStartFound = true;
            // } else {
            //     println("'" + c + "' is not starting position, at " + x + " of line " + this.parsingData.inputLineIndex +
            //         ", equating to position " + x + "," + y);
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
    public char[][] mapWithSubgrid;
    public int width;
    public int height;
    public int mapArea;
    public int widthWithSubgrid;
    public int heightWithSubgrid;
    public int mapAreaWithSubgrid;
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
    public HashMap<Integer,Point2> pathMap;

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
        this.pathMap = new HashMap<Integer,Point2>();

        this.width = input[0].length();
        this.height = input.length;
        this.mapArea = this.width * this.height;
        println("Map dimensions " + this.width + "x" + this.height + " has an area of " + this.mapArea);

        int x, y;

        this.map = new char[this.height][];
        for (y = 0; y < this.height; y++) {
            this.map[y] = new char[this.width];
        }

        this.widthWithSubgrid = 2 * this.width - 1;
        this.heightWithSubgrid = 2 * this.height - 1;
        this.mapAreaWithSubgrid = this.widthWithSubgrid * this.heightWithSubgrid;
        println("Map dimensions with subgrid " + this.widthWithSubgrid + "x" + this.heightWithSubgrid +
            " has an area of " + this.mapAreaWithSubgrid);

        this.mapWithSubgrid = new char[this.heightWithSubgrid][];
        for (y = 0; y < this.heightWithSubgrid; y++) {
            this.mapWithSubgrid[y] = new char[this.widthWithSubgrid];
            for (x = 0; x < this.widthWithSubgrid; x++) {
                this.mapWithSubgrid[y][x] = '.'; // For now mark all subgrid spaces as open ground;
            }
        }
    }
}