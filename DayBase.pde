class DayBase {
    public boolean isImplemented;

    String[] input;

    DayBase() {
        this.isImplemented = false;
        this.input = new String[0];
    }

    void setInput(String[] input) {
        this.input = input;
    }

    void run() {
        println("No logic to run!");
    }
}