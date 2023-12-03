import java.util.Map;

class Day03 extends DayBase {
    private Day03ParsingData parsingData;
    
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
        for (Map.Entry<String, Day03Gear> entry : this.parsingData.gears.entrySet()) {
            gear = entry.getValue();
            if (gear.numbers.size() == 2) {
                a = gear.numbers.get(0);
                b = gear.numbers.get(1);
                sum += a.number * b.number;
            }
        }

        println("Part 2: Sum of gear ratios is " + sum);
    }

    void run() {
        this.parsingData = new Day03ParsingData(this.input.length);
        this.isParsingData = true;
    }

    void update(int x, int y) {
        if (!this.updateParsingInputData()) {
            return;
        }
        
        this.part1();
        this.part2();
        this.finish();
    }

    void stepParsingInputData() {
        if (this.parsingData.lineIndex < this.input.length) {
            this.parseLine(
                this.parsingData.lineIndex,
                max(this.parsingData.lineIndex - 1, 0),
                min(this.input.length - 1, this.parsingData.lineIndex + 1));

            this.parsingData.lineIndex++;

            return;
        }

        this.isParsingData = false;
    }

    void parseLine(int lineRow, int startRow, int endRow) {
        String line = this.input[lineRow];
        int lineLength = line.length();
        int numStartColumn = -1;
        int numEndColumn = -1;
        
        int startColumn, endColumn;
        String value;
        Day03Number num;
        Day03ValidationPayload validationPayload;

        for (int c = 0; c < lineLength; c++) {
            if (isCharNumber(line.charAt(c))) {
                if (numStartColumn == -1) {
                    numStartColumn = c;
                }

                if (c < lineLength - 1) {
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
                startColumn = max(numStartColumn - 1, 0);
                endColumn = min(lineLength - 1, numEndColumn + 1);

                validationPayload = new Day03ValidationPayload(startColumn, startRow, endColumn, endRow, lineRow, numStartColumn, numEndColumn);

                if (validateNumber(validationPayload)) {
                    num = new Day03Number(Integer.parseInt(value));
                    this.parsingData.numbers.add(num);

                    if (validationPayload.gear != null) {
                        validationPayload.gear.AddNumber(num);
                        num.attachedGear = validationPayload.gear;
                    }
                }
                
                numStartColumn = -1;
                numEndColumn = -1;
            }
        }
    }

    boolean validateNumber(Day03ValidationPayload payload) {
        char character;
        String gearID;

        for (int r = payload.startRow; r <= payload.endRow; r++) {
            for (int c = payload.startColumn; c <= payload.endColumn; c++) {
                if (r == payload.numberRow && c >= payload.numberStartColumn && c <= payload.numberEndColumn) {
                    continue; // Skip the number itself
                }

                character = this.input[r].charAt(c);
                
                if (this.isCharGear(character)) {
                    gearID = this.getGearID(c, r);
                    payload.gear = this.parsingData.gears.get(gearID);

                    if (payload.gear == null) {
                        payload.gear = new Day03Gear(gearID, c, r);
                        this.parsingData.AddGear(payload.gear);
                    }
                    return true;
                } else if (this.isCharSymbol(character)) {
                    return true;
                }
            }
        }

        return false;
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

    String getGearID(int column, int row) {
        return column + "-" + row;
    }
}

class Day03ParsingData {
    public int lineIndex;
    public ArrayList<Day03Number> numbers;
    public HashMap<String, Day03Gear> gears;

    Day03ParsingData(int inputLines) {
        this.lineIndex = 0;
        this.numbers = new ArrayList<Day03Number>();
        this.gears = new HashMap<String, Day03Gear>();
    }

    void AddGear(Day03Gear gear) {
        this.gears.put(gear.id, gear);
    }
}

class Day03Number {
    public int number;
    public Day03Gear attachedGear;

    Day03Number(int number) {
        this.number = number;
        this.attachedGear = null;
    }
}

class Day03ValidationPayload {
    public int startColumn;
    public int startRow;
    public int endColumn;
    public int endRow;
    public int numberRow;
    public int numberStartColumn;
    public int numberEndColumn;
    public Day03Gear gear;

    Day03ValidationPayload(int startColumn, int startRow, int endColumn, int endRow,
        int numberRow, int numberStartColumn, int numberEndColumn) {
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
    public int column;
    public int row;
    public ArrayList<Day03Number> numbers;

    Day03Gear(String id, int column, int row) {
        this.id = id;
        this.column = column;
        this.row = row;
        this.numbers = new ArrayList<Day03Number>();
    }

    void AddNumber(Day03Number number) {
        this.numbers.add(number);
        number.attachedGear = this;
    }
}