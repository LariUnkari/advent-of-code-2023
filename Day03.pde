import java.util.Map;

class Day03 extends DayBase {
    private Day03ParsingData parsingData;
    private Day03Visual visualization;

    private int numbersParsedPerStep;
    private boolean isCheckingGears;
    
    Day03() {
        super();
        this.isImplemented = true;
    }

    void part1() {
        int sum = 0;

        for (Day03Number num : this.parsingData.numbers) {
            sum += num.number;
        }

        println("Part 1: Sum of valid numbers is " + sum);
    }

    void part2() {
        int sum = 0;

        Day03Gear gear;
        Day03Number a, b;
        for (Map.Entry<String, Day03Gear> entry : this.parsingData.gearMap.entrySet()) {
            gear = entry.getValue();
            if (gear.numbers.size() == 2) {
                a = gear.numbers.get(0);
                b = gear.numbers.get(1);
                sum += a.number * b.number;
                //println("Valid gear found at row " + gear.row + ", column " + gear.column + ", attached to numbers: " + a.number + " and " + b.number);
            } else {
                //println("Gear at row " + gear.row + ", column " + gear.column + " was not valid, attached to " + gear.numbers.size() + " gear(s)");
            }
        }

        println("Part 2: Sum of gear ratios is " + sum);
    }

    void run() {
        this.numbersParsedPerStep = ceil(this.parsingData.rowLength / 15.0);
        this.parsingData.isParsingData = true;
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        if (!this.updateValidatingGears()) {
            return false;
        }
        
        return true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    void stepParsingInputData() {
        if (this.parsingData.inputLineIndex >= this.parsingData.inputLineCount) {
            this.parsingData.isParsingData = false;
            this.parsingData.isCheckingGears = true;
            return;
        }

        if (this.parsingData.columnIndex == -1) {
            this.parsingData.columnIndex = 0;
            this.parsingData.adjStartRow = max(this.parsingData.inputLineIndex - 1, 0);
            this.parsingData.adjEndRow = min(this.parsingData.inputLineCount - 1, this.parsingData.inputLineIndex + 1);
        }

        while (this.parsingData.numbersParsedInStep < this.numbersParsedPerStep) {
            this.parsingData.columnIndex = this.parseLine(this.parsingData.inputLineIndex, this.parsingData.rowLength, this.parsingData.columnIndex,
                this.parsingData.adjStartColumn, this.parsingData.adjStartRow, this.parsingData.adjEndColumn, this.parsingData.adjEndRow);

            this.parsingData.numbersParsedInStep++;

            if (this.parsingData.columnIndex == -1) {
                this.parsingData.inputLineIndex++;
                break;
            }
        }

        this.parsingData.numbersParsedInStep = 0;
    }

    int parseLine(int rowIndex, int rowLength, int charColumn, int adjStartColumn, int adjStartRow, int adjEndColumn, int adjEndRow) {
        String line = this.parsingData.input[rowIndex];
        
        int numStartColumn = -1;
        int numEndColumn = -1;
        String value;
        Day03Number num;
        Day03ValidationPayload validationPayload;

        for (int c = charColumn; c < rowLength; c++) {
            if (isCharNumber(line.charAt(c))) {
                if (numStartColumn == -1) {
                    //println("Found a new number at row " + rowIndex + " char " + c);
                    numStartColumn = c;
                }

                if (c < rowLength - 1) {
                    continue;
                }

                // Last character of the line, the number needs to be processed
                numEndColumn = c;
            } else if (numStartColumn != -1) {
                // Found a non-number character, mark the number end to previous
                numEndColumn = c - 1;
            }
            
            if (numStartColumn != -1 && numEndColumn != -1) {
                value = line.substring(numStartColumn, numEndColumn + 1);

                // Get the validation area columns
                adjStartColumn = max(numStartColumn - 1, 0);
                adjEndColumn = min(rowLength - 1, numEndColumn + 1);

                //println("Validating number " + value + ", rectangle(" + adjStartColumn + "," + adjStartRow + "|" + adjEndColumn + "," + adjEndRow + ")");
                validationPayload = new Day03ValidationPayload(rowLength, adjStartColumn, adjStartRow, adjEndColumn, adjEndRow,
                    rowIndex, numStartColumn, numEndColumn);

                if (validateNumber(validationPayload)) {
                    num = new Day03Number(Integer.parseInt(value), rowIndex, numStartColumn, numEndColumn);
                    this.parsingData.AddNumber(num);
                    //println("Found valid number " + value + ", row " + rowIndex + ", chars " + numStartColumn + "-" + numEndColumn);

                    if (validationPayload.gear != null) {
                        //println("Gear '" + validationPayload.gear.id + "' was attached");
                        validationPayload.gear.AddNumber(num);
                        num.attachedGear = validationPayload.gear;
                    }
                } else {
                    //println("Invalid number " + value + ", row " + rowIndex + ", chars " + numStartColumn + "-" + numEndColumn);
                }
                
                numStartColumn = -1;
                numEndColumn = -1;
                return c + 1;
            }
        }

        return -1;
    }

    boolean validateNumber(Day03ValidationPayload payload) {
        char character;
        String gearID;

        for (int r = payload.startRow; r <= payload.endRow; r++) {
            for (int c = payload.startColumn; c <= payload.endColumn; c++) {
                if (r == payload.numberRow && c >= payload.numberStartColumn && c <= payload.numberEndColumn) {
                    //println("Skip number digit '" + this.parsingData.input[r].charAt(c) + "' at row " + r + " column " + c);
                    continue; // Skip the number itself
                }

                character = this.parsingData.input[r].charAt(c);
                
                if (this.isCharGear(character)) {
                    gearID = this.parsingData.getPositionID(c, r);
                    payload.gear = this.parsingData.gearMap.get(gearID);

                    if (payload.gear == null) {
                        //println("New gear '" + gearID + "' found attached on row " + r + " column " + c);
                        payload.gear = new Day03Gear(gearID, c, r, max(0, c - 1), max(0, r - 1),
                            min(c + 1, payload.rowLength - 1), min(r + 1, this.parsingData.inputLineCount - 1));
                        this.parsingData.AddGear(payload.gear);
                    } else {
                        //println("Gear '" + gearID + "' attached on row " + r + " column " + c);
                    }
                    return true;
                } else if (this.isCharSymbol(character)) {
                    //println("Symbol '" + character + "' found on row " + r + " column " + c);
                    return true;
                } else {
                    //println("Empty char '" + character + "' found on row " + r + " column " + c);
                }
            }
        }

        return false;
    }

    boolean updateValidatingGears() {
        int count = this.parsingData.gears.size();

        Day03Gear gear;

        if (this.parsingData.gearIndex < count) {
            gear = this.parsingData.gears.get(this.parsingData.gearIndex);
            gear.isValid = gear.numbers.size() == 2;

            this.parsingData.gearIndex++;
            return false;
        }

        this.parsingData.isCheckingGears = false;
        return true;
    }

    boolean isCharSymbol(char c) {
        return c != '.';
    }

    boolean isCharGear(char c) {
        return c == '*';
    }

    boolean isCharNumber(char c) {
        switch (c) {
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                return true;
        }

        return false;
    }

    void createParsingData(String[] input) {
        this.parsingData = new Day03ParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {
        this.visualization = new Day03Visual(viewRect, this.parsingData);
    }

    DayVisualBase getVisualization() {
        return this.visualization;
    }
}

class Day03ParsingData extends ParsingData {
    public boolean isCheckingGears;
    public int rowLength;
    public int columnIndex;
    public int numbersParsedInStep;
    public int adjStartColumn;
    public int adjStartRow;
    public int adjEndColumn;
    public int adjEndRow;
    public int numStartColumn;
    public int numEndColumn;
    public int gearIndex;

    public ArrayList<Day03Number> numbers;
    public HashMap<String, Day03Number> numberMap;
    public ArrayList<Day03Gear> gears;
    public HashMap<String, Day03Gear> gearMap;

    Day03ParsingData(String[] input) {
        super(input);
        this.isCheckingGears = false;
        this.rowLength = input[0].length();
        this.columnIndex = -1;
        this.numbersParsedInStep = 0;
        this.gearIndex = 0;
        this.numbers = new ArrayList<Day03Number>();
        this.numberMap = new HashMap<String, Day03Number>();
        this.gears = new ArrayList<Day03Gear>();
        this.gearMap = new HashMap<String, Day03Gear>();
    }

    void AddNumber(Day03Number number) {
        this.numbers.add(number);
        
        for (int c = number.startColumn; c <= number.endColumn; c++) {
            this.numberMap.put(this.getPositionID(c, this.inputLineIndex), number);
        }
    }

    void MapNumber(String id, Day03Number number) {
        this.numberMap.put(id, number);
    }

    void AddGear(Day03Gear gear) {
        this.gears.add(gear);
        this.gearMap.put(gear.id, gear);
    }

    boolean isNumberAt(int column, int row) {
        return this.numberMap.containsKey(this.getPositionID(column, row));
    }

    String getPositionID(int column, int row) {
        return column + "-" + row;
    }
}

class Day03Number {
    public int number;
    public int row;
    public int startColumn;
    public int endColumn;
    public Day03Gear attachedGear;

    Day03Number(int number, int row, int startColumn, int endColumn) {
        this.number = number;
        this.row = row;
        this.startColumn = startColumn;
        this.endColumn = endColumn;
        this.attachedGear = null;
    }
}

class Day03ValidationPayload {
    public int rowLength;
    public int startColumn;
    public int startRow;
    public int endColumn;
    public int endRow;
    public int numberRow;
    public int numberStartColumn;
    public int numberEndColumn;
    public Day03Gear gear;

    Day03ValidationPayload(int rowLength, int startColumn, int startRow, int endColumn, int endRow,
        int numberRow, int numberStartColumn, int numberEndColumn) {
        this.rowLength = rowLength;
        this.startColumn = startColumn;
        this.startRow = startRow;
        this.endColumn = endColumn;
        this.endRow = endRow;
        this.numberRow = numberRow;
        this.numberStartColumn = numberStartColumn;
        this.numberEndColumn = numberEndColumn;
        this.gear = null;
    }
}

class Day03Gear {
    public String id;
    public boolean isValid;
    public int column;
    public int row;
    public int adjStartColumn;
    public int adjStartRow;
    public int adjEndColumn;
    public int adjEndRow;
    public ArrayList<Day03Number> numbers;

    Day03Gear(String id, int column, int row, int adjStartColumn, int adjStartRow, int adjEndColumn, int adjEndRow) {
        this.id = id;
        this.column = column;
        this.row = row;
        this.adjStartColumn = adjStartColumn;
        this.adjStartRow = adjStartRow;
        this.adjEndColumn = adjEndColumn;
        this.adjEndRow = adjEndRow;
        this.isValid = false;
        this.numbers = new ArrayList<Day03Number>();
    }

    void AddNumber(Day03Number number) {
        this.numbers.add(number);
        number.attachedGear = this;
    }
}