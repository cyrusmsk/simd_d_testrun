import std;

static immutable MINUTES = 24;

static struct pi {
    int first, second;
}

struct BluePrint {
    int oreCost;
    int clayCost;
    pi obsidianCosts;
    pi geodeCosts;
    int maxOre;
}

BluePrint[] bps;

int globalMax;
struct Elements {
  int ore;
  int clay;
  int obsidian;
  int geode;

  Elements opBinary(string op)(Elements rhs){
      static if (op == "+") return Elements(ore+rhs.ore, clay+rhs.clay, obsidian+rhs.obsidian, geode+rhs.geode);
      static if (op == "-") return Elements(ore-rhs.ore, clay-rhs.clay, obsidian-rhs.obsidian, geode-rhs.geode);
      static if (op == "*") return Elements(ore*rhs.ore, clay*rhs.clay, obsidian*rhs.obsidian, geode*rhs.geode);
  }

  Elements opAssign(string op: "+")(Elemets rhs){
      return Elements(ore+rhs.ore, clay+rhs.clay, obsidian+rhs.obsidian, geode+rhs.geode);
  }
}

static int getTotal(const ref BluePrint bp, Elements inventory, Elements rates, int minutesLeft) {
    int geodeRate = rates.geode;
    int upperLimit = inventory.geode;
    foreach(i; 0..minutesLeft) {
        upperLimit += geodeRate++;
    }
    if (upperLimit < globalMax)
        return 0;
    if (minutesLeft == 0)
        return globalMax = max(globalMax, inventory.geode);
    minutesLeft--;

    int total = 0;
    // Geode robot
    auto geodeOre = bp.geodeCosts.first;
    auto geodeObsidian = bp.geodeCosts.second;
    if (inventory.ore >= geodeOre && inventory.obsidian >= geodeObsidian) {
        auto newInv = inventory + rates;
        auto newRates = rates;
        newInv.ore -= geodeOre;
        newInv.obsidian -= geodeObsidian;
        newRates.geode++;

        total = max(total, getTotal(bp, newInv, newRates, minutesLeft));
    }
    if (rates.ore >= geodeOre && rates.obsidian >= geodeObsidian)
        return total;

    // Obsidian robot
    auto obsidianOre = bp.obsidianCosts.first;
    auto obsidianClay = bp.obsidianCosts.second;
    if ( rates.obsidian < geodeObsidian && inventory.ore >= obsidianOre && inventory.clay >= obsidianClay ) {
        auto newInv = inventory + rates;
        auto newRates = rates;
        newInv.ore -= obsidianOre;
        newInv.clay -= obsidianClay;
        newRates.obsidian++;

        total = max( total, getTotal( bp, newInv, newRates, minutesLeft ) );
    }

    // Clay robot
    if ( rates.clay < bp.obsidianCosts.second && inventory.ore >= bp.clayCost ) {
        auto newInv = inventory + rates;
        auto newRates = rates;
        newInv.ore -= bp.clayCost;
        newRates.clay++;

        total = max( total, getTotal( bp, newInv, newRates, minutesLeft ) );
    }

    // Ore robot
    if ( rates.ore < bp.maxOre && inventory.ore >= bp.oreCost ) {
        auto newInv = inventory + rates;
        auto newRates = rates;
        newInv.ore -= bp.oreCost;
        newRates.ore++;

        total = max( total, getTotal( bp, newInv, newRates, minutesLeft ) );
    }

    // Do nothing if it can be useful
    if ( rates.ore < bp.maxOre && rates.clay < obsidianClay && rates.obsidian < geodeObsidian ) {
        auto newInv = inventory + rates;
        total = max( total, getTotal( bp, newInv, rates, minutesLeft ) );
    }

  return total;
}

void main() {
    foreach(line; stdin.byLine()) {
        BluePrint bp;
        line.formattedRead("Blueprint %*d: Each ore robot costs %d ore. Each clay robot costs %d ore. Each obsidian robot costs %d ore and %d clay. Each geode robot costs %d ore and %d obsidian.",
    bp.oreCost,
    bp.clayCost,
    bp.obsidianCosts.first,
    bp.obsidianCosts.second,
    bp.geodeCosts.first,
    bp.geodeCosts.second);
    bp.maxOre = max(max(bp.oreCost,bp.clayCost), max(bp.obsidianCosts.first, bp.geodeCosts.first));

    bps ~= bp; 
   }
   int ret = 0;
   Elements inventory;
   Elements rates = {1,0,0,0};
   int i = 0;
   foreach(bp; bps) {
       globalMax = 0;
       i++;
       int total = getTotal(bp, inventory, rates, MINUTES);
       ret += i * total;
       writeln(i, ": ", total, " (", i * total, ")");
   }
   writeln(ret);
}
