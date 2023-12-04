class DayBase {
    public boolean isImplemented;

    public boolean isComplete;
    public boolean isRunning;
    public boolean isParsingData;
    
    public ViewRect viewRect;

    protected String[] input;

    DayBase(ViewRect viewRect) {
        this.isImplemented = false;
        this.input = new String[0];
        this.viewRect = viewRect;
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
        this.isRunning = false;
        this.isComplete = true;
        println("Solution completed");
        this.onComplete();
    }

    void onComplete() {
        
    }

    boolean update(int x, int y) {
        return this.updateParsingInputData();
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