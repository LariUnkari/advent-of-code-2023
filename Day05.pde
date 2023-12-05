import java.util.Arrays;

class Day05 extends DayBase {
    final int StateParsingSeeds                    = 0;
    final int StateParsingSeedToSoilMap            = 1;
    final int StateParsingSoilToFertilizerMap      = 2;
    final int StateParsingFertilizerToWaterMap     = 3;
    final int StateParsingWaterToLightMap          = 4;
    final int StateParsingLightToTemperatureMap    = 5;
    final int StateParsingTemperatureToHumidityMap = 6;
    final int StateParsingHumidityToLocationMap    = 7;

    private Day05ParsingData parsingData;

    Day05(ViewRect viewRect) {
        super(viewRect);
        this.isImplemented = true;
    }

    void run() {
        this.parsingData = new Day05ParsingData(this.input.length);
        this.isParsingData = true;
    }

    long resolveValue(long value, Day05Map map) {
        long newValue = map.resolveNumber(value);
        //println("Map '" + map.id + "' resolved " + value + " to " + newValue);
        return newValue;
    }

    void part1() {
        println("Part 1: Found " + this.parsingData.seeds.size() + " seeds");
        long lowest = this.findLowestNumberLocationList(this.parsingData.seeds);
        println("Part 1: lowest location number is " + lowest);
    }

    void part2() {
        ArrayList<Day05SeedSet> sets = new ArrayList<Day05SeedSet>();

        int typeCount = 0;
        long total = 0;

        long s, r;
        for (int i = 0; i < this.parsingData.seeds.size(); i+=2) {
            s = this.parsingData.seeds.get(i);
            r = this.parsingData.seeds.get(i + 1);

            println("Seed[" + typeCount + "] " + s + " has a range of " + r);

            sets.add(new Day05SeedSet(s, r));
            typeCount++;
            total += r;
        }

        println("Part 2: Found " + total + " seeds of " + typeCount + " types");
        long lowest = this.findLowestNumberLocationSets(sets);
        println("Part 2: lowest location number is " + lowest);
    }

    long findLowestNumberLocationList(ArrayList<Long> listSeeds) {
        long lowest = Long.MAX_VALUE;
        long seed, location;

        for (int i = 0; i < listSeeds.size(); i++) {
            seed = listSeeds.get(i);
            location = this.findSeedLocation(seed);
            
            if (location < lowest) {
                lowest = location;
            }
        }

        return lowest;
    }

    long findLowestNumberLocationSets(ArrayList<Day05SeedSet> sets) {
        long lowest = Long.MAX_VALUE;
        long location, start, end;
        Day05SeedSet set;

        for (int i = 0; i < sets.size(); i++) {
            set = sets.get(i);
            start = set.start;
            end = start + set.range;
            println("Searching seed set from " + start + " to " + end);

            for (long seed = start; seed < end; seed++) {
                location = this.findSeedLocation(seed);

                if (location < lowest) {
                    lowest = location;
                }
            }
        }

        return lowest;
    }

    long findSeedLocation(long seed) {
        long soil, fert, watr, lght, temp, hmid, loca;
        soil = this.resolveValue(seed, this.parsingData.getMap(StateParsingSeedToSoilMap));
        fert = this.resolveValue(soil, this.parsingData.getMap(StateParsingSoilToFertilizerMap));
        watr = this.resolveValue(fert, this.parsingData.getMap(StateParsingFertilizerToWaterMap));
        lght = this.resolveValue(watr, this.parsingData.getMap(StateParsingWaterToLightMap));
        temp = this.resolveValue(lght, this.parsingData.getMap(StateParsingLightToTemperatureMap));
        hmid = this.resolveValue(temp, this.parsingData.getMap(StateParsingTemperatureToHumidityMap));
        loca = this.resolveValue(hmid, this.parsingData.getMap(StateParsingHumidityToLocationMap));
        return loca;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        return true;
    }

    void stepParsingInputData() {

        if (this.parsingData.rowIndex < this.parsingData.lineCount) {
            String data = this.input[this.parsingData.rowIndex];

            if (data.length() == 0) {
                this.parsingData.rowIndex++;
                this.parsingData.setState(this.parsingData.stateIndex + 1, this.input[this.parsingData.rowIndex]);
            } else {
                this.parseLine(data, this.parsingData.stateIndex);
            }

            this.parsingData.rowIndex++;
            return;
        }

        this.isParsingData = false;
        //this.pageIndex = 0;
        println("Finished parsing input data");
    }

    void parseLine(String data, int state) {
        if (state < 0 || state > StateParsingHumidityToLocationMap) {
            println("Invalid parsing state " + state + "!");
            return;
        }

        if (state == StateParsingSeeds) {
            this.parseSeeds(data);
            return;
        }
        
        Day05Map map = this.parsingData.getMap(state);
        if (map != null) {
            this.parseMapNumbers(data, map);
        } else {
            println("Unable to get map for state " + state);
        }
    }

    void parseSeeds(String data) {
        String[] matches = match(data, "seeds: (.*)");
        if (matches == null) {
            println("Unable to parse seeds!");
            return;
        }
        
        String[] seeds = split(matches[1], " ");
        for (int i = 0; i < seeds.length; i++) {
            this.parsingData.seeds.add(Long.parseLong(seeds[i]));
        }
        //println("Parsed seeds: " + join(seeds, ","));
    }

    void parseMapNumbers(String data, Day05Map map) {
        String[] items = split(data, " ");
        long[] numbers = new long[items.length];

        for (int i = 0; i < items.length; i++) {
            numbers[i] = Long.parseLong(items[i]);
        }

        //println("Parsed map '" + map.id + "' numbers: destination " + numbers[0] + ", source " + numbers[1] + ", range: " + numbers[2]);
        map.addSet(numbers[0], numbers[1], numbers[2]);
    }
}

class Day05ParsingData {
    public int lineCount;
    public int rowIndex;
    public int stateIndex;
    public String stateName;

    public ArrayList<Long> seeds;
    private Day05Map[] mapsPerState;

    Day05ParsingData(int lineCount) {
        this.lineCount = lineCount;
        this.rowIndex = 0;
        this.stateIndex = 0;
        this.stateName = "";
        this.seeds = new ArrayList<Long>();
        this.mapsPerState = new Day05Map[7];
        for (int i = 0; i < 7; i++) {
            this.mapsPerState[i] = new Day05Map();
        }
    }

    void setState(int stateIndex, String stateName) {
        this.stateIndex = stateIndex;
        this.stateName = stateName.substring(0, stateName.length() - 5);
        this.mapsPerState[this.stateIndex - 1].setName(this.stateName);
        println("Set parsing state " + this.stateIndex + " '" + this.stateName + "'");
    }

    Day05Map getMap(int state) {
        return this.mapsPerState[state - 1];
    }
}

class Day05Map {
    public String id;
    private ArrayList<Day05MapSet> sets;

    Day05Map() {
        this.id = null;
        this.sets = new ArrayList<Day05MapSet>();
    }

    void setName(String id) {
        this.id = id;
        //println("Map id set: '" + this.id + "'");
    }

    void addSet(long destination, long source, long range) {
        Day05MapSet set = new Day05MapSet(source, source + range - 1, destination - source);
        //println("Map '" + this.id + "' added set: source=[" + set.start + "-" + set.end + "], diff=" + set.diff +
        //    " -> destination[" + destination + "-" + (destination + range - 1) + "]");
        this.sets.add(set);
    }

    long resolveNumber(long number) {
        int count = this.sets.size();
        long result = number;

        Day05MapSet set;
        for (int i = 0; i < count; i++) {
            set = this.sets.get(i);

            if (number < set.start) {
                //println("Map '" + this.id + "' Number " + number + " is less than " + set.start + ", no change");
                continue;
            }

            if (number > set.end) {
                //println("Map '" + this.id + "' Number " + number + " is greater than " + set.end + ", no change");
                continue;
            }

            result = number + set.diff;
            break;
        }

        //println("Map '" + this.id + "' Number " + number + " maps to " + result);
        return result;
    }
}

class Day05MapSet {
    public long start;
    public long end;
    public long diff;

    Day05MapSet(long start, long end, long diff) {
        this.start = start;
        this.end = end;
        this.diff = diff;
    }
}

class Day05SeedSet {
    public long start;
    public long range;

    Day05SeedSet(long start, long range) {
        this.start = start;
        this.range = range;
    }
}