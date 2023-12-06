import java.util.Map;

class Day06 extends DayBase {
    private Day06ParsingData parsingData;

    Day06() {
        super();
        this.isImplemented = true;
    }

    void part1() {
        long answer = 1;

        long count;
        Day06Race race;
        for (int i = 0; i < this.parsingData.racesA.length; i++) {
            race = this.parsingData.racesA[i];
            count = race.highestCharge - race.lowestCharge + 1;

            if (count > 0) {
                println("Race " + race.id + " has " + count + " plans that surpass the record " + race.record);
                answer *= count;
            }
        }

        println("Part 1: Margin of error beating record of " + this.parsingData.racesA.length + " races is " + answer);
    }

    void part2() {
        long answer = this.parsingData.raceB.highestCharge - this.parsingData.raceB.lowestCharge + 1;
        println("Part 2: Number of charge options for beating record of " + this.parsingData.raceB.record + " is " + answer);
    }

    void run() {
        this.parsingData.isParsingData = true;
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        if (this.parsingData.isCalculatingRaceTimes) {
            if (this.parsingData.raceIndex < this.parsingData.racesA.length) {
                this.calculateRaceTimes(this.parsingData.racesA[this.parsingData.raceIndex]);

                this.parsingData.raceIndex++;
                return false;
            }

            this.calculateRaceTimes(this.parsingData.raceB);
            this.parsingData.isCalculatingRaceTimes = false;
        }

        return true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    void stepParsingInputData() {
        String[] times = this.parseNumbersPart1(this.parsingData.input[0]);
        String[] records = this.parseNumbersPart1(this.parsingData.input[1]);
        println("Parsed time values: [" + join(times, ",") + "] and distance record values: [" + join(records, ",") + "]");

        this.parsingData.racesA = new Day06Race[times.length];

        Day06Race race;
        for (int i = 0; i < times.length; i++) {
            race = new Day06Race(i + 1, Long.parseLong(times[i]), Long.parseLong(records[i]));
            this.parsingData.racesA[i] = race;
            println("Parsed race " + race.id + ": time=" + race.time + ", record=" + race.record);
        }

        race = new Day06Race(-1, this.parseNumberPart2(times), this.parseNumberPart2(records));
        this.parsingData.raceB = race;
        println("Parsed race " + race.id + ": time=" + race.time + ", record=" + race.record);
        
        this.parsingData.isParsingData = false;
        this.parsingData.isCalculatingRaceTimes = true;
    }

    long parseNumberPart2(String[] data) {
        String s = join(data, "");
        println("Parsed number " + s + " from [" + join(data, ",") + "]");
        return Long.parseLong(s);
    }

    String[] parseNumbersPart1(String data) {
        String[] numbers;
        String[][] matches = matchAll(data, "\\d+");

        if (matches == null) {
            return new String[0];
        }

        numbers = new String[matches.length];
        for (int i = 0; i < matches.length; i++) {
            numbers[i] = matches[i][0];
        }
        
        return numbers;
    }

    void calculateRaceTimes(Day06Race race) {
        println("Calculating times for race " + race.id + ", time=" + race.time + ", record=" + race.record);

        long distance;
        long chargeA = this.getOptimalChargeTime(race.time);
        long chargeB = race.time - chargeA;
        println("Race " + race.id + ", optimal charge=[" + chargeA + "," + chargeB + "], distance=" +
            this.getDistance(chargeA, race.time));

        boolean limitsFound = false;
        while (!limitsFound && chargeA > 0 && chargeB < race.time) {
            distance = this.getDistance(chargeA, race.time);
            if (distance > race.record) {
                race.lowestCharge = chargeA;
            } else {
                println("Race " + race.id + ", lowest record-breaking charge=" + (chargeA + 1) + ", distance=" + this.getDistance(chargeA + 1, race.time));
                limitsFound = true;
            }

            distance = this.getDistance(chargeB, race.time);
            if (distance > race.record) {
                race.highestCharge = chargeB;
            } else {
                println("Race " + race.id + ", highest record-breaking charge=" + (chargeB - 1) + ", distance=" + this.getDistance(chargeB - 1, race.time));
                limitsFound = true;
            }

            chargeA--;
            chargeB++;
        }
    }

    long getDistance(long charge, long time) {
        return charge * (time - charge);
    }

    long getOptimalChargeTime(long time) {
        // Quadratic formula: f(x) = ax² + 2b + c, from this parabola peak formula: -b/2a
        // Race distance: f(charge) = -charge² + time * charge
        // Race max distance: -time / (2 * -1), which simplifies to time / 2
        return time / 2;
    }

    void createParsingData(String[] input) {
        this.parsingData = new Day06ParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {}

    DayVisualBase getVisualization() {
        return null;
    }
}

class Day06ParsingData extends ParsingData {
    public boolean isCalculatingRaceTimes;
    public Day06Race[] racesA;
    public Day06Race raceB;
    public int raceIndex;

    public Day06ParsingData(String[] input) {
        super(input);
        this.isCalculatingRaceTimes = false;
        this.raceIndex = 0;
    }
}

class Day06Race {
    public int id;
    public long time;
    public long record;
    public long lowestCharge;
    public long highestCharge;

    Day06Race(int id, long time, long record) {
        this.id = id;
        this.time = time;
        this.record = record;
        this.lowestCharge = -1;
        this.highestCharge = -1;
    }
}