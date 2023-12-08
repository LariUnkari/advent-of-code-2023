class DayBarebones extends DayBase {
    private DayBarebonesParsingData parsingData;
    
    DayBarebones() {
        super();
        this.isImplemented = true;
    }

    void part1() {}
    void part2() {}

    void run() {
        this.parsingData.isParsingData = true;
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        return true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    void stepParsingInputData() {
        this.parsingData.isParsingData = false; // Check if parsing is actually done
        this.parsingData.inputLineIndex++;
    }

    void createParsingData(String[] input) {
        this.parsingData = new DayBarebonesParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {}

    DayVisualBase getVisualization() {
        return null;
    }
}

class DayBarebonesParsingData extends ParsingData {
    DayBarebonesParsingData(String[] input) {
        super(input);
    }
}