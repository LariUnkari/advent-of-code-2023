abstract class DayBase {
    public boolean isImplemented;

    public boolean isComplete;
    public boolean isRunning;

    DayBase() {
        this.isImplemented = false;
    }

    void init(ViewRect viewRect, String[] input) {
        println("Initializing solution view");

        this.isRunning = false;
        this.isComplete = false;
        
        this.createParsingData(input);
        this.createVisualization(viewRect);
    }

    abstract void createParsingData(String[] input);
    abstract ParsingData getParsingData();
    abstract void createVisualization(ViewRect viewRect);
    abstract DayVisualBase getVisualization();

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
        this.onComplete();
        println("Solution completed");
    }

    abstract void onComplete();

    boolean update(int x, int y) {
        return this.updateParsingInputData();
    }

    boolean updateParsingInputData() {
        if (!this.isRunning) {
            return false;
        }

        if (this.getParsingData().isParsingData) {
            this.stepParsingInputData();
            return false;
        }

        return true;
    }

    abstract void stepParsingInputData();

    void onMousePressed() {
        
    }

    void draw() {
        
    }
}