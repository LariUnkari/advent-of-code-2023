import java.util.Map;

class Day11 extends DayBase {
    final char CharGalaxy = '#';
    final char CharEmpty = '.';

    final int ExpansionSpeed = 10;

    private Day11ParsingData parsingData;
    
    Day11() {
        super();
        this.isImplemented = true;
    }

    void part1() {
        int expansion = 2;
        long answer = this.calculateExpandedDistances(this.parsingData.galaxyList, expansion, this.parsingData.expansionRows, this.parsingData.expansionColumns);
        println("Part 1: Sum of distances between " + this.parsingData.galaxyList.size() + " galaxies after expansion factor of " + expansion + " is " + answer);
    }
    void part2() {
        int expansion = 1000000;
        long answer = this.calculateExpandedDistances(this.parsingData.galaxyList, expansion, this.parsingData.expansionRows, this.parsingData.expansionColumns);
        println("Part 2: Sum of distances between " + this.parsingData.galaxyList.size() + " galaxies after expansion factor of " + expansion + " is " + answer);
    }

    void run() {
        this.parsingData.isParsingData = true;
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        if (!this.parsingData.areExpansionRowsMapped) {
            for (int i = 0; i < this.ExpansionSpeed; i++) {
                this.updateExpansionCol(this.parsingData.mappingPosition, this.parsingData.areaDimensions, this.parsingData.map, this.parsingData.expansionColumns);
                this.parsingData.mappingPosition.x++;

                if (this.parsingData.mappingPosition.x >= this.parsingData.areaDimensions.x) {
                    this.parsingData.areExpansionRowsMapped = true;
                    break;
                }
            }
            return false;
        }

        if (!this.parsingData.areExpansionColumnsMapped) {
            for (int i = 0; i < this.ExpansionSpeed; i++) {
                this.updateExpansionRow(this.parsingData.mappingPosition, this.parsingData.areaDimensions, this.parsingData.map, this.parsingData.expansionRows);
                this.parsingData.mappingPosition.y++;

                if (this.parsingData.mappingPosition.y >= this.parsingData.areaDimensions.y) {
                    this.parsingData.areExpansionColumnsMapped = true;
                    break;
                }
            }

            if (this.parsingData.areExpansionColumnsMapped) {
                this.parsingData.mappingPosition.x = 0;
                this.parsingData.mappingPosition.y = 0;
            }
            return false;
        }

        if (!this.parsingData.areGalaxiesMapped) {
            if (this.parsingData.mappingPosition.y >= this.parsingData.areaDimensions.y) {
                this.parsingData.areGalaxiesMapped = true;
                // this.printMap(this.parsingData.map, this.parsingData.areaDimensions);
                println("Found " + this.parsingData.galaxyList.size() + " galaxies");
                return false;
            }

            this.updateGalaxyMapping(this.parsingData.mappingPosition, this.parsingData.areaDimensions,
                this.parsingData.map, this.parsingData.galaxyList, this.parsingData.galaxyMap);

            this.printMapRow(this.parsingData.map, this.parsingData.mappingPosition.y, this.parsingData.areaDimensions.x);
            this.parsingData.mappingPosition.y++;
            return false;
        }

        // if (!this.parsingData.areDistancesCalculated) {
        //     this.calculateDistances(this.parsingData.galaxyList);
        //     this.parsingData.areDistancesCalculated = true;
        //     return false;
        // }

        return true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    void updateExpansionRow(Point2 position, Point2 dimensions, ArrayList<ArrayList<Character>> map, HashSet<Integer> expansionRows) {
        // println("Expanding space at row " + position.y);
        ArrayList<Character> row = map.get(position.y);
        boolean galaxyFound = false;
        char c;
        int x;
        
        for (x = 0; x < dimensions.x; x++) {
            c = row.get(x);

            if (c == this.CharGalaxy) {
                galaxyFound = true;
                break;
            }
        }

        if (!galaxyFound) {
            expansionRows.add(position.y);
            // println("Added expansion row at " + position.y);
        }
    }

    void updateExpansionCol(Point2 position, Point2 dimensions, ArrayList<ArrayList<Character>> map, HashSet<Integer> expansionColumns) {
        // println("Expanding space at column " + position.x);
        ArrayList<Character> row;
        boolean galaxyFound = false;
        char c;
        int y;

        for (y = 0; y < dimensions.y; y++) {
            row = map.get(y);
            c = row.get(position.x);

            if (c == this.CharGalaxy) {
                galaxyFound = true;
                break;
            }
        }
        
        if (!galaxyFound) {
            expansionColumns.add(position.x);
            // println("Added expansion column at " + position.x);
        }
    }

    void updateGalaxyMapping(Point2 position, Point2 dimensions, ArrayList<ArrayList<Character>> map, ArrayList<Day11Galaxy> galaxyList, HashMap<Integer,Integer> galaxyMap) {
        // println("Mapping space at row " + position.y);
        ArrayList<Character> row = map.get(position.y);
        Day11Galaxy g;
        Point2 p;
        int x, i, n;
        char c;

        for (x = 0; x < dimensions.x; x++) {
            c = row.get(x);

            if (c == this.CharGalaxy) {
                p = new Point2(x, position.y);
                i = this.getPositionIndex(p.x, p.y, dimensions.x);
                n = galaxyList.size() + 1;
                g = new Day11Galaxy(n, i, p);
                galaxyMap.put(i, galaxyList.size());
                galaxyList.add(g);
                // println("Galaxy " + n + " found at " + p.x + "," + p.y + " (" + i + ")");
            }
        }
    }

    long calculateExpandedDistances(ArrayList<Day11Galaxy> galaxyList, int expansionFactor, HashSet<Integer> expansionRows, HashSet<Integer> expansionColumns) {
        int size = galaxyList.size();
        long sum = 0;

        Day11Galaxy g1, g2;
        int i, k, x, y, x1, x2, y1, y2;
        long d;

        for (i = 0; i < size; i++) {
            g1 = galaxyList.get(i);

            for (k = i + 1; k < size; k++) {
                // if (k == i) { continue; }

                g2 = galaxyList.get(k);

                // if (g1.distances.containsKey(g2.id)) { continue; }

                x1 = min(g1.position.x, g2.position.x);
                x2 = max(g1.position.x, g2.position.x);
                y1 = min(g1.position.y, g2.position.y);
                y2 = max(g1.position.y, g2.position.y);

                d = 0;

                for (y = y1; y < y2; y++) {
                    d += expansionRows.contains(y) ? expansionFactor : 1;
                }
                for (x = x1; x < x2; x++) {
                    d += expansionColumns.contains(x) ? expansionFactor : 1;
                }

                // println("Distance between " + g1.id + " and " + g2.id + " is " + d);

                // g1.distances.put(g2.id, d);
                // g2.distances.put(g1.id, d);

                sum += d;
            }
        }

        return sum;
    }

    int getPositionIndex(int x, int y, int width) {
        return x + y * width;
    }

    void printMap(ArrayList<ArrayList<Character>> map, Point2 dimensions) {
        for (int y = 0; y < dimensions.y; y++) {
            this.printMapRow(map, y, dimensions.x);
        }
    }

    void printMapRow(ArrayList<ArrayList<Character>> map, int rowIndex, int width) {
        ArrayList<Character> row = map.get(rowIndex);
        char c;

        for (int x = 0; x < width; x++) {
            c = row.get(x);
            print(c + " ");
        }

        println("");
    }

    void stepParsingInputData() {
        if (this.parsingData.inputLineIndex >= this.parsingData.inputLineCount) {
            this.parsingData.isParsingData = false;
            // this.printMap(this.parsingData.map, this.parsingData.areaDimensions);
            println("Done parsing input");
            return;
        }

        String data = this.parsingData.input[this.parsingData.inputLineIndex];
        this.parseLine(data, this.parsingData.inputLineIndex, this.parsingData.areaDimensions.x, this.parsingData.map);
        this.parsingData.inputLineIndex++;
    }

    void parseLine(String data, int y, int width, ArrayList<ArrayList<Character>> map) {
        ArrayList<Character> line = new ArrayList<Character>();
        char c;

        for (int x = 0; x < width; x++) {
            line.add(data.charAt(x));
        }

        map.add(line);
    }

    void createParsingData(String[] input) {
        this.parsingData = new Day11ParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {}

    DayVisualBase getVisualization() {
        return null;
    }
}

class Day11ParsingData extends ParsingData {
    public ArrayList<ArrayList<Character>> map;
    public HashSet<Integer> expansionRows;
    public HashSet<Integer> expansionColumns;
    public ArrayList<Day11Galaxy> galaxyList;
    public HashMap<Integer,Integer> galaxyMap;
    public Point2 areaDimensions;
    public Point2 mappingPosition;
    public boolean areExpansionRowsMapped;
    public boolean areExpansionColumnsMapped;
    public boolean areGalaxiesMapped;
    public boolean areDistancesCalculated;

    Day11ParsingData(String[] input) {
        super(input);

        this.map = new ArrayList<ArrayList<Character>>(input.length * 2);
        this.expansionRows = new HashSet<Integer>();
        this.expansionColumns = new HashSet<Integer>();
        this.galaxyList = new ArrayList<Day11Galaxy>();
        this.galaxyMap = new HashMap<Integer,Integer>();
        this.areaDimensions = new Point2(input[0].length(), input.length);
        this.mappingPosition = new Point2(0, 0);
        this.areExpansionRowsMapped = false;
        this.areExpansionColumnsMapped = false;
        this.areGalaxiesMapped = false;
        this.areDistancesCalculated = false;
    }
}

class Day11Galaxy {
    public int id;
    public int index;
    public Point2 position;
    // public HashMap<Integer,Point2> distances;

    Day11Galaxy(int id, int index, Point2 position) {
        this.id = id;
        this.index = index;
        this.position = position;
        // this.distances = new HashMap<Integer,Point2>();
    }
}