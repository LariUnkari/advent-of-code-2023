class Day01 extends DayBase {
    Day01() {
        super();
        this.isImplemented = true;
    }

    void run() {
        println("Running Day 01");
        this.part1();
        this.part2();
        this.stop();
    }

    void part1() {
        String[][] values = this.getValues("(\\d)", "(\\d)");

        int sum = 0;
        for (int i = 0; i < values.length; i++) {
            sum += Integer.parseInt(values[i][0] + values[i][1]);
        }

        println("Part 1: values sum = " + sum);
    }

    void part2() {
        String[] digitsA = new String[] { "one","two","three","four","five","six","seven","eight","nine" };
        String[] digitsB = this.buildArrayReversed(digitsA);

        String[][] values = this.getValues(this.buildRegex(digitsA), this.buildRegex(digitsB));

        int sum = 0;
        for (int i = 0; i < values.length; i++) {
            sum += parseValue(values[i][0], values[i][1]);
        }

        println("Part 2: values sum = " + sum);
    }

    String[] buildArrayReversed(String[] digits) {
        String[] reverseDigits = new String[digits.length];

        for (int i = 0; i < digits.length; i++) {
            reverseDigits[i] = new StringBuilder(digits[i]).reverse().toString();
        }

        return reverseDigits;
    }

    String buildRegex(String[] digits) {
        return "(\\d|" + join(digits, "|") + ")";
    }

    int parseValue(String digitFirst, String digitLast) {
        return this.parseDigit(digitFirst, false) * 10 + this.parseDigit(digitLast, true);
    }

    int parseDigit(String digit, boolean isLast) {
        if (digit.length() == 1) {
            return Integer.parseInt(digit);
        }
        
        switch (isLast ? new StringBuilder(digit).reverse().toString() : digit) {
            case "one":   return 1;
            case "two":   return 2;
            case "three": return 3;
            case "four":  return 4;
            case "five":  return 5;
            case "six":   return 6;
            case "seven": return 7;
            case "eight": return 8;
            case "nine":  return 9;
            default: break;
        }

        return 0;
    }

    String[][] getValues(String regexpFirst, String regexpLast) {
        String[][] parsedInputs = new String[this.input.length][2];
        
        String[] first, last;
        String inputLine, inputLineReversed;
        
        for (int i = 0; i < this.input.length; i++) {
            inputLine = this.input[i];
            inputLineReversed = new StringBuilder(inputLine).reverse().toString();

            parsedInputs[i] = new String[] { this.getValue(inputLine, regexpFirst), this.getValue(inputLineReversed, regexpLast) };
        }

        return parsedInputs;
    }

    String getValue(String text, String regexp) {
        String[] matches = match(text, regexp);

        if (matches != null) {
            return matches[0];
        } else {
            println("No match on '" + text + "' with pattern " + regexp);
        }

        return "0";
    }
}