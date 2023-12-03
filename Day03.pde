import java.util.Map;

class Day03 extends DayBase {
    private Day03ParsingData parsingData;

    private int numbersParsedPerStep;
    private boolean isCheckingGears;

    private int maxWidth;
    private int maxHeight;
    private int middleX;
    private int middleY;
    private int tableX;
    private int tableY;
    private int tableWidth;
    private int tableHeight;
    private int cellWidth;
    private int cellHeight;

    private int minCellSize = 8;
    private color colorGearValid = color(0, 255, 0, 127);
    private color colorGearInvalid = color(255, 50, 50, 127);

    private int pageButtonWidth = 100;
    private int pageButtonHeight = 30;
    private int pageButtonFontSize = 20;
    private ButtonColors buttonColors = new ButtonColors(color(191), color(255), color(63), color(0));
    private int buttonMargin = 10;

    private Button pageUpButton;
    private Button pageDownButton;
    private int buttonHoverIndex;
    private Button hoveredButton;

    private int pageRowCount;
    private int pageRowStep;
    private int pageCount;
    private int pageIndex;
    private int pageFirstRow;
    private int pageLastRow;
    
    Day03() {
        super();
        this.isImplemented = true;
        this.maxWidth = width - 20;
        this.maxHeight = height - 60;
        this.middleX = width / 2;
        this.middleY = 60 + this.maxHeight / 2;
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

    void init() {
        this.pageUpButton = new Button(width - this.buttonMargin - this.pageButtonWidth, this.buttonMargin,
            this.pageButtonWidth, this.pageButtonHeight, this.buttonColors, this.pageButtonFontSize, "UP", true);
        this.pageDownButton = new Button(width - 2 * (this.buttonMargin + this.pageButtonWidth), this.buttonMargin,
            this.pageButtonWidth, this.pageButtonHeight, this.buttonColors, this.pageButtonFontSize, "DOWN", true);

        this.buttonHoverIndex = -1;
        this.hoveredButton = null;
    }

    void run() {
        this.parsingData = new Day03ParsingData(this.input.length);

        int rowLength = this.input[0].length();
        this.numbersParsedPerStep = ceil(rowLength / 15.0);

        if (this.parsingData.lineCount * this.minCellSize > maxHeight) {
            if (rowLength * this.minCellSize > maxWidth) {
                //println("Data can't be horizontally fit on a page, numbers parsed per step: " + this.numbersParsedPerStep);
                this.cellWidth = this.minCellSize;
            } else {
                //println("Data needs multiple pages, numbers parsed per step: " + this.numbersParsedPerStep);
                this.cellWidth = floor(maxWidth / rowLength);
            
            }
            this.cellHeight = this.cellWidth;
            this.pageRowCount = maxHeight / this.cellHeight;
            this.pageRowStep = this.pageRowCount / 2;
            int overflowRows = this.parsingData.lineCount % this.pageRowCount;
            this.pageCount = 1 + (this.parsingData.lineCount - overflowRows) / this.pageRowStep;
        } else {
            //println("Data fits well on one page, numbers parsed per step: " + this.numbersParsedPerStep);
            this.pageCount = 1;
            this.pageRowCount = this.parsingData.lineCount;
            this.pageRowStep = this.pageRowCount;
            this.cellHeight = maxHeight / this.parsingData.lineCount;
            this.cellWidth = this.cellHeight;
        }

        println("Page count " + this.pageCount + ", row step " + this.pageRowStep + ", rows per page " + this.pageRowCount);

        this.tableHeight = this.cellHeight * this.pageRowCount;
        this.tableWidth = this.cellWidth * rowLength;
        this.tableX = this.middleX - this.tableWidth / 2;
        this.tableY = this.middleY - this.tableHeight / 2;

        println("Table pos: " + this.tableX + "," + this.tableY + ", table dims: " + this.tableWidth + "x" + this.tableHeight + ", cell dims: " + this.cellWidth + "x" + this.cellHeight);

        this.pageIndex = 0;
        this.isParsingData = true;
    }

    void update(int x, int y) {
        this.buttonHoverIndex = -1;

        if (this.pageUpButton.containsPoint(x, y)) {
            this.buttonHoverIndex = 0;
        } else if (this.pageDownButton.containsPoint(x, y)) {
            this.buttonHoverIndex = 1;
        }

        if (this.buttonHoverIndex == 0) {
            if (this.pageDownButton.isMouseOver) {
                this.pageDownButton.onMouseOut();
            }
            if (!this.pageUpButton.isMouseOver) {
                this.pageUpButton.onMouseOver();
                this.hoveredButton = this.pageUpButton;
            }
        } else if (this.buttonHoverIndex == 1) {
            if (this.pageUpButton.isMouseOver) {
                this.pageUpButton.onMouseOut();
            }
            if (!this.pageDownButton.isMouseOver) {
                this.pageDownButton.onMouseOver();
                this.hoveredButton = this.pageDownButton;
            }
        } else if (this.hoveredButton != null) {
            this.hoveredButton.onMouseOut();
            this.hoveredButton = null;
        }

        if (!this.updateParsingInputData()) {
            return;
        }

        if (!this.updateValidatingGears()) {
            return;
        }
        
        this.part1();
        this.part2();
        this.finish();
    }

    void onMousePressed() {
        if (this.hoveredButton == null) {
            println("No button hovered!");
            return;
        }

        if (this.hoveredButton == this.pageUpButton) {
            if (this.pageIndex > 0) {
                println("Up a page!");
                this.pageIndex--;
            }
        } else if (this.hoveredButton == this.pageDownButton) {
            if (this.pageIndex < this.pageCount - 1) {
                println("Down a page!");
                this.pageIndex++;
            }
        }
    }

    void draw() {
        this.pageUpButton.drawButton();
        this.pageDownButton.drawButton();
        this.pageFirstRow = this.pageIndex * this.pageRowStep;
        this.pageLastRow = min(this.pageFirstRow + this.pageRowCount, this.parsingData.lineCount);
        this.drawNumbers();
        this.drawGears();
    }

    void drawNumbers() {
        int x, y;
        String line;

        for (int r = this.pageFirstRow; r < this.pageLastRow; r++) {
            y = this.tableY + (r - this.pageFirstRow) * this.cellHeight;
            line = this.input[r];

            for (int c = 0; c < line.length(); c++) {
                x = this.tableX + c * this.cellWidth + this.cellWidth / 2;
                
                if (this.parsingData.isNumberAt(c, r)) {
                    fill(0, 255, 0);
                } else if (r == this.parsingData.rowIndex) {
                    fill(255);
                } else {
                    fill(191);
                }

                textSize(cellHeight);
                text(line.charAt(c), x, y);
            }
        }
    }

    void drawGears() {
        int x, y, w, h, asr, aer;
        Day03Gear gear;

        for (int i = 0; i < this.parsingData.gearIndex; i++) {
            gear = this.parsingData.gears.get(i);

            if (gear.row < this.pageFirstRow || gear.row > this.pageLastRow) {
                continue;
            }

            asr = gear.adjStartRow - this.pageFirstRow;
            aer = gear.adjEndRow - this.pageFirstRow;

            x = this.tableX + gear.adjStartColumn * this.cellWidth;
            y = this.tableY + asr * this.cellHeight - this.cellHeight / 2;
            w = this.tableX + gear.adjEndColumn * this.cellWidth + this.cellWidth - x;
            h = this.tableY + aer * this.cellHeight + this.cellHeight / 2 - y;

            fill(gear.isValid ? this.colorGearValid : this.colorGearInvalid);
            noStroke();
            rect(x, y, w, h);
        }
    }

    void stepParsingInputData() {
        if (this.parsingData.rowIndex >= this.parsingData.lineCount) {
            this.isParsingData = false;
            this.pageIndex = 0;
            return;
        }

        if (this.parsingData.columnIndex == -1) {
            this.parsingData.columnIndex = 0;
            this.parsingData.rowLength = this.input[this.parsingData.rowIndex].length();
            this.parsingData.adjStartRow = max(this.parsingData.rowIndex - 1, 0);
            this.parsingData.adjEndRow = min(this.parsingData.lineCount - 1, this.parsingData.rowIndex + 1);
        }

        while (this.parsingData.numbersParsedInStep < this.numbersParsedPerStep) {
            this.parsingData.columnIndex = this.parseLine(this.parsingData.rowIndex, this.parsingData.rowLength, this.parsingData.columnIndex,
                this.parsingData.adjStartColumn, this.parsingData.adjStartRow, this.parsingData.adjEndColumn, this.parsingData.adjEndRow);

            this.parsingData.numbersParsedInStep++;

            if (this.parsingData.columnIndex == -1) {
                this.parsingData.rowIndex++;
                break;
            }
        }
        
        if (this.pageIndex + 1 < this.pageCount &&
            this.parsingData.rowIndex - this.pageRowStep / 2 > this.pageRowStep * (1 + this.pageIndex)) {
            this.pageIndex++;
        }

        this.parsingData.numbersParsedInStep = 0;
    }

    int parseLine(int rowIndex, int rowLength, int charColumn, int adjStartColumn, int adjStartRow, int adjEndColumn, int adjEndRow) {
        String line = this.input[rowIndex];
        
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
                    //println("Skip number digit '" + this.input[r].charAt(c) + "' at row " + r + " column " + c);
                    continue; // Skip the number itself
                }

                character = this.input[r].charAt(c);
                
                if (this.isCharGear(character)) {
                    gearID = this.parsingData.getPositionID(c, r);
                    payload.gear = this.parsingData.gearMap.get(gearID);

                    if (payload.gear == null) {
                        //println("New gear '" + gearID + "' found attached on row " + r + " column " + c);
                        payload.gear = new Day03Gear(gearID, c, r, max(0, c - 1), max(0, r - 1),
                            min(c + 1, payload.rowLength - 1), min(r + 1, this.parsingData.lineCount - 1));
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
        
            if (this.pageIndex + 1 < this.pageCount &&
                gear.row - this.pageRowStep / 2 > this.pageRowStep * (1 + this.pageIndex)) {
                this.pageIndex++;
            }

            return false;
        }

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
}

class Day03ParsingData {
    public int lineCount;
    public int rowIndex;
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

    Day03ParsingData(int inputLines) {
        this.lineCount = inputLines;
        this.rowIndex = 0;
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
            this.numberMap.put(this.getPositionID(c, this.rowIndex), number);
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