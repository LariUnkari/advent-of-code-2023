class Day09 extends DayBase {
    private Day09ParsingData parsingData;
    
    Day09() {
        super();
        this.isImplemented = true;
    }

    void part1() {
        Day09HistoryItem item;
        Long[] line;
        long prediction;
        long answer = 0;
        int i, k;

        for (i = 0; i < this.parsingData.items.length; i++) {
            item = this.parsingData.items[i];
            prediction = 0;

            for (k = item.lines.size() - 2; k >= 0; k--) {
                line = item.lines.get(k);
                prediction += line[line.length - 1];
            }

            println("Item[" + i + "]: prediction after " + item.lines.size() + " lines is " + prediction);
            answer += prediction;
        }

        println("Part 1: Sum of predictions is " + answer);
    }
    void part2() {
        Day09HistoryItem item;
        Long[] line;
        long history;
        long answer = 0;
        int i, k;

        for (i = 0; i < this.parsingData.items.length; i++) {
            item = this.parsingData.items[i];
            history = 0;

            for (k = item.lines.size() - 2; k >= 0; k--) {
                line = item.lines.get(k);
                history = line[0] - history;
            }

            println("Item[" + i + "]: extrapolated history after " + item.lines.size() + " lines is " + history);
            answer += history;
        }

        println("Part 2: Sum of predictions is " + answer);
    }

    void run() {
        this.parsingData.isParsingData = true;
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        if (this.parsingData.itemIndex < this.parsingData.items.length) {
            Day09HistoryItem item = this.parsingData.items[this.parsingData.itemIndex];
            Long[] prev, next;
            long value;
            int i, k;
            boolean found;

            this.parsingData.lineIndex = 0;

            while (!item.isDone && this.parsingData.lineIndex < 100) {
                prev = item.lines.get(this.parsingData.lineIndex);
                next = new Long[prev.length - 1];
                this.parsingData.lineIndex++;

                i = 0;
                k = 1;
                found = true;

                while (k < prev.length) {
                    value = prev[k] - prev[i];
                    next[i] = value;
                    // println("Item[" + this.parsingData.itemIndex + "] Line[" + this.parsingData.lineIndex + "][" + i + "]: " + prev[k] + "-" + prev[i] + "=" + value);
                    if (value != 0) { found = false; }
                    i++;
                    k++;
                }

                // print("Item[" + this.parsingData.itemIndex + "] Line[" + this.parsingData.lineIndex + "]: [");
                // for (i = 0; i < next.length; i++) {
                //     if (i > 0) { print(","); }
                //     print(next[i]);
                // }
                // println("]");

                item.lines.add(next);
                if (found) { break; }
            }

            this.parsingData.itemIndex++;
            return false;
        }

        return true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    void stepParsingInputData() {
        if (this.parsingData.inputLineIndex >= this.parsingData.input.length) {
            this.parsingData.isParsingData = false;
            return;
        }

        String data = this.parsingData.input[this.parsingData.inputLineIndex];
        this.parsingData.items[this.parsingData.inputLineIndex] = this.parseHistory(data);
        
        this.parsingData.inputLineIndex++;
    }

    Day09HistoryItem parseHistory(String data) {
        String[] values = split(data, " ");
        println("Parsed history line: [" + join(values, ",") + "]");
        Long[] history = new Long[values.length];
        for (int i = 0; i < history.length; i++) { history[i] = Long.parseLong(values[i]); }
        return new Day09HistoryItem(history);
    }

    void createParsingData(String[] input) {
        this.parsingData = new Day09ParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {}

    DayVisualBase getVisualization() {
        return null;
    }
}

class Day09ParsingData extends ParsingData {
    public Day09HistoryItem[] items;
    public int itemIndex;
    public int lineIndex;

    Day09ParsingData(String[] input) {
        super(input);
        this.items = new Day09HistoryItem[input.length];
        this.itemIndex = 0;
        this.lineIndex = 0;
    }
}

class Day09HistoryItem {
    public ArrayList<Long[]> lines;
    public boolean isDone;

    Day09HistoryItem(Long[] history) {
        this.lines = new ArrayList<Long[]>();
        this.lines.add(history);
        this.isDone = false;
    }
}