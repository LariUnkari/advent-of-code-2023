class DayBarebones extends DayBase {
    DayBarebones() {
        super();
        //this.isImplemented = true;
    }

    void part1() {}
    void part2() {}

    void run() {
        //this.parsingData.isParsingData = true;
    }

    boolean update(int x, int y) {
        return true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    void stepParsingInputData() {}

    void createParsingData(String[] input) {}

    ParsingData getParsingData() {
        return null;
    }

    void createVisualization(ViewRect viewRect) {}

    DayVisualBase getVisualization() {
        return null;
    }
}