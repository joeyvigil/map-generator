int numCities = 150;
int citySize = 15;
float minDistance = 30;
int border = 20;
City selectedCityA = null;
City selectedCityB = null;

City[] cities;



String[] gridLetters = {
  "A","B","C","D","E","F","G","H",
  "I","J","K","L","M","N","O","P"
};

String[] syllables = {
  "al", "an", "ar", "bel", "ber", "cor", "dar", "del", "dor", "el", "en", "far", "fel", "gar", "gil", "hal",
  "hor", "in", "jor", "kal", "kor", "lam", "lor", "mal", "mor", "nel", "nor", "ol", "or", "ral", "ron", "sar",
  "sel", "tar", "thal", "tor", "ur", "val", "var", "vor", "zel", "zor"
};

String[] nameSuffixes = {
  "stead", "ton", "hold", "hollow", "burg", "reach", "gate", "port", "heim", "fall", "watch", "keep", "spire"
};

void setup() {
  size(800, 800);
  textAlign(CENTER, CENTER);
  textSize(12);

  cities = new City[numCities];
  int placed = 0;
  int attempts = 0;

  while (placed < numCities && attempts < 10000) {
    float x = random(border, width - border);
    float y = random(border, height - border);
    City newCity = new City(x, y);

    boolean tooClose = false;
    for (int i = 0; i < placed; i++) {
      if (dist(newCity.x, newCity.y, cities[i].x, cities[i].y) < minDistance) {
        tooClose = true;
        break;
      }
    }

    if (!tooClose) {
      int gridX = int(map(newCity.x, 0, width, 0, 16));
      int gridY = int(map(newCity.y, 0, height, 0, 16));
      gridX = constrain(gridX, 0, 15);
      gridY = constrain(gridY, 0, 15);
      String label = gridLetters[gridX] + gridLetters[gridY];

      newCity.name = label + "-" + generateCityName();

      cities[placed] = newCity;
      placed++;
    }

    attempts++;
  }

  connectCities();
}

void draw() {
  background(240);

  drawGridOverlay();

  drawGridLabels();

  for (City c : cities) {
    c.drawRoads();
  }
  for (City c : cities) {
    c.drawCity();
  }

  noFill();
  stroke(180, 80);
  rect(border, border, width - 2 * border, height - 2 * border);
}


// --------- City class ---------
class City {
  float x, y;
  String name = "";
  ArrayList<City> connections;

  City(float x, float y) {
    this.x = x;
    this.y = y;
    connections = new ArrayList<City>();
  }

  void connectTo(City other) {
    if (!connections.contains(other)) {
      connections.add(other);
      other.connections.add(this);
    }
  }

  void drawCity() {
    fill(50, 100, 200);
    stroke(0);
    ellipse(x, y, citySize, citySize);

    fill(0);
    text(name, x, y - citySize * 1.5);
  }

  void drawRoads() {
    stroke(100);
    for (City other : connections) {
      if (this.x < other.x || (this.x == other.x && this.y < other.y)) {
        line(x, y, other.x, other.y);
      }
    }
  }
}

// --------- Connect cities with Prim's algorithm ---------
void connectCities() {
  ArrayList<City> connected = new ArrayList<City>();
  ArrayList<City> unconnected = new ArrayList<City>();

  for (City c : cities) {
    unconnected.add(c);
  }

  connected.add(unconnected.remove(0));

  while (!unconnected.isEmpty()) {
    City bestA = null;
    City bestB = null;
    float bestDist = Float.MAX_VALUE;

    for (City a : connected) {
      for (City b : unconnected) {
        float d = dist(a.x, a.y, b.x, b.y);
        if (d < bestDist) {
          bestDist = d;
          bestA = a;
          bestB = b;
        }
      }
    }

    if (bestA != null && bestB != null) {
      bestA.connectTo(bestB);
      connected.add(bestB);
      unconnected.remove(bestB);
    }
  }
}

// --------- Draw A–P axis labels ---------
void drawGridLabels() {
  fill(0);
  for (int i = 0; i < 16; i++) {
    float pos = map(i + 0.5, 0, 16, 0, width);
    text(gridLetters[i], pos, 10);         // X top
    text(gridLetters[i], 10, pos);         // Y left
  }
}

// --------- Generate Syllable-Based City Name ---------
String generateCityName() {
  int syllableCount = int(random(2, 4)); // 2–3 syllables
  String name = "";

  for (int i = 0; i < syllableCount; i++) {
    name += syllables[int(random(syllables.length))];
  }

  // Capitalize first letter
  name = name.substring(0,1).toUpperCase() + name.substring(1);

  // Optional suffix
  if (random(1) < 0.8) {
    name += nameSuffixes[int(random(nameSuffixes.length))];
  }

  return name;
}

// --------- Grid ---------
void drawGridOverlay() {
  stroke(200);
  strokeWeight(1);
  fill(150, 150, 150, 50);
  textAlign(CENTER, CENTER);
  textSize(10);

  float cellW = width / 16.0;
  float cellH = height / 16.0;

  for (int y = 0; y < 16; y++) {
    for (int x = 0; x < 16; x++) {
      float posX = x * cellW;
      float posY = y * cellH;

      // Draw grid rectangle
      noFill();
      rect(posX, posY, cellW, cellH);

      // Draw region label in center of the cell
      //String label = gridLetters[x] + gridLetters[y];
      //fill(100, 100, 100, 100);
      //noStroke();
      //text(label, posX + cellW / 2, posY + cellH / 2);
      //stroke(200);
      //noFill();
    }
  }
}
// Add this mousePressed() function:
void mousePressed() {
  for (City c : cities) {
    float d = dist(mouseX, mouseY, c.x, c.y);
    if (d < citySize * 1.5) {
      if (selectedCityA == null) {
        selectedCityA = c;
      } else if (selectedCityB == null && c != selectedCityA) {
        selectedCityB = c;
        // Connect the two cities
        selectedCityA.connectTo(selectedCityB);
        println("Connected " + selectedCityA.name + " to " + selectedCityB.name);
        selectedCityA = null;
        selectedCityB = null;
      }
      break;
    }
  }
}
// export a JPG image of your city map
void keyPressed() {
  if (key == 's' || key == 'S') {
    save("map.jpg");
    println("map.jpg exported");
  }
  if (key == 'p' || key == 'P') {
    println("City Names:");
    for (City c : cities) {
      println(c.name);
    }
  }
  if (key == 'c' || key == 'C') {
    println("City Names:");
    String[] lines = new String[cities.length];
    for (int i = 0; i < cities.length; i++) {
      lines[i] = cities[i].name;
      println(lines[i]);
    }
    saveStrings("city_names.txt", lines);
    println("City names exported to city_names.txt");
  }
}
