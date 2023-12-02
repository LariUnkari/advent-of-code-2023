class DayBase {
    public boolean isImplemented;

    public boolean isRunning;
    public boolean isDone;

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
        this.isRunning = false;
    }

    void draw() {
        
    }
}