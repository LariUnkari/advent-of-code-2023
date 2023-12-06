abstract class ParsingData {
    public String[] input;
    public int inputLineCount;
    public int inputLineIndex;
    public boolean isParsingData;

    ParsingData(String[] input) {
        this.input = input;
        this.inputLineCount = input.length;
        this.inputLineIndex = 0;
        this.isParsingData = false;
    }
}