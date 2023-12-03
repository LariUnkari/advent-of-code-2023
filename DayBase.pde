class DayBase {
    public boolean isImplemented;

    public boolean isRunning;
    public boolean isParsingData;

    String[] input;

    DayBase() {
        this.isImplemented = false;
        this.input = new String[0];
    }

    void setInput(String[] input) {
        this.input = input;
    }

    void init() {

    }

    void start() {
        this.isRunning = true;
        this.run();
    }

    void run() {
        println("No logic to run!");
    }

    void stop() {
        println("Solution interrupted");
        this.isRunning = false;
    }
    
    void finish() {
        println("Solution completed");
        this.isRunning = false;
    }

    void update(int x, int y) {

    }

    boolean updateParsingInputData() {
        if (!this.isRunning) {
            return false;
        }

        if (this.isParsingData) {
            this.stepParsingInputData();
            return false;
        }

        return true;
    }

    void stepParsingInputData() {
        println("No parsing logic implemented!");
        this.isParsingData = false;
    }

    void onMousePressed() {
        
    }

    void draw() {
        
    }
}