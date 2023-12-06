class Day03Visual extends DayVisualPageView {
    private Day03ParsingData parsingData;

    private int tableX;
    private int tableY;
    private int tableWidth;
    private int tableHeight;
    private int cellWidth;
    private int cellHeight;

    private int minCellSize = 8;
    private color colorGearValid = color(0, 255, 0, 127);
    private color colorGearInvalid = color(255, 50, 50, 127);

    private int pageRowCount;
    private int pageRowStep;
    private int pageFirstRow;
    private int pageLastRow;

    private boolean isDrawingGears;

    Day03Visual(ViewRect viewRect, Day03ParsingData parsingData) {
        super(viewRect);

        this.parsingData = parsingData;

        if (this.parsingData.inputLineCount * this.minCellSize > this.viewRect.height) {
            if (this.parsingData.rowLength * this.minCellSize > this.viewRect.width) {
                //println("Data can't be horizontally fit on a page, numbers parsed per step: " + this.numbersParsedPerStep);
                this.cellWidth = this.minCellSize;
            } else {
                //println("Data needs multiple pages, numbers parsed per step: " + this.numbersParsedPerStep);
                this.cellWidth = floor(this.viewRect.width / this.parsingData.rowLength);
            
            }
            this.cellHeight = this.cellWidth;
            this.pageRowCount = this.viewRect.height / this.cellHeight;
            this.pageRowStep = this.pageRowCount / 2;
            int overflowRows = this.parsingData.inputLineCount % this.pageRowCount;
            this.pageCount = 1 + (this.parsingData.inputLineCount - overflowRows) / this.pageRowStep;
        } else {
            //println("Data fits well on one page, numbers parsed per step: " + this.numbersParsedPerStep);
            this.pageCount = 1;
            this.pageRowCount = this.parsingData.inputLineCount;
            this.pageRowStep = this.pageRowCount;
            this.cellHeight = this.viewRect.height / this.parsingData.inputLineCount;
            this.cellWidth = this.cellHeight;
        }

        println("Page count " + this.pageCount + ", row step " + this.pageRowStep + ", rows per page " + this.pageRowCount);

        this.tableHeight = this.cellHeight * this.pageRowCount;
        this.tableWidth = this.cellWidth * this.parsingData.rowLength;
        this.tableX = this.viewRect.middleX - this.tableWidth / 2;
        this.tableY = this.viewRect.middleY - this.tableHeight / 2;

        println("Table pos: " + this.tableX + "," + this.tableY + ", table dims: " + this.tableWidth + "x" + this.tableHeight + ", cell dims: " + this.cellWidth + "x" + this.cellHeight);

        this.isDrawingGears = false;
    }

    void draw() {
        super.draw();

        this.pageFirstRow = this.pageIndex * this.pageRowStep;
        this.pageLastRow = min(this.pageFirstRow + this.pageRowCount, this.parsingData.inputLineCount);

        this.drawNumbers();
        this.drawGears();
    }

    void drawNumbers() {
        int x, y;
        String line;

        for (int r = this.pageFirstRow; r < this.pageLastRow; r++) {
            y = this.tableY + (r - this.pageFirstRow) * this.cellHeight;
            line = this.parsingData.input[r];

            for (int c = 0; c < line.length(); c++) {
                x = this.tableX + c * this.cellWidth + this.cellWidth / 2;
                
                if (this.parsingData.isNumberAt(c, r)) {
                    fill(0, 255, 0);
                } else if (r == this.parsingData.inputLineIndex) {
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

    void update(int x, int y) {
        super.update(x, y);

        if (this.parsingData.isParsingData && this.parsingData.inputLineIndex < this.parsingData.inputLineCount) {
            this.autoFocusProgress(this.parsingData.inputLineIndex);
            return;
        }

        if (!this.isDrawingGears) {
            this.isDrawingGears = true;
            this.pageIndex = 0;
        }
        
        if (this.parsingData.isCheckingGears && this.parsingData.gearIndex < this.parsingData.gears.size()) {
            Day03Gear gear = this.parsingData.gears.get(this.parsingData.gearIndex);
            this.autoFocusProgress(gear.row);
        }
    }

    void autoFocusProgress(int rowIndex) {
        if (this.pageIndex + 1 < this.pageCount && rowIndex - this.pageRowStep / 2 > this.pageRowStep * (1 + this.pageIndex)) {
            this.pageIndex++;
        }
    }
}