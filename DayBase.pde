class DayBase {
    public boolean isImplemented;

    public boolean isRunning;

    String[] input;

    DayBase() {
        this.isImplemented = false;
        this.input = new String[0];
    }

    void setInput(String[] input) {
        this.input = input;
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

    void onMousePressed() {
        
    }

    void draw() {
        
    }
}