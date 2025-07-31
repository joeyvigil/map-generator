// Processing sketch: City map with resource-generating cities and cards

int cols = 16;
int rows = 16;
int citySize = 20;
City[] cities;
Card[] cards;
int numCards = 300;

City selectedCityA = null;
City selectedCityB = null;

String[] resources = {"coal", "lumber", "copper", "silver", "gold"};
color[] resourceColors = {
  color(50),          // coal - dark gray
  color(139,69,19),   // lumber - bown
  color(255,0,0),     // copper - red
  color(192,192,192), // silver - silver
  color(255,215,0)    // gold - gold
};

HashMap<City, ArrayList<String>> cityResources = new HashMap<City, ArrayList<String>>();

void setup() {
  size(1000, 1000);
  textAlign(CENTER, CENTER);
  textSize(10);
  generateCities();
  connectCities();
  generateCards();
}

void draw() {
  background(255);
  drawConnections();
  drawCities();
}

void generateCities() {
  ArrayList<City> tempCities = new ArrayList<City>();
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      if(random(1)<.5){
        float posX = map(x + 0.5 + random(-0.3, 0.3), 0, cols, 50, width - 50);
        float posY = map(y + 0.5 + random(-0.3, 0.3), 0, rows, 50, height - 50);
        String name = getLabel(x, y);
        tempCities.add(new City(posX, posY, name));
      }
    }
  }
  cities = tempCities.toArray(new City[0]);
}

String getLabel(int x, int y) {
  char c = (char)('A' + x);
  return "" + c + (y + 1) + "-" + generateCityName();
}

String generateCityName() {
  String[] prefixes = {"Zorl", "Kal", "Dar", "Bel", "Thal", "Mir", "Nor", "Fen", "Vor", "Ral", "Gor", "Tar", "Hel", "Sor", "Mar", "Ul"};
  String[] suffixes = {"ton", "keep", "spire", "mouth", "helm", "port", "bridge", "stead", "shire", "grave", "crest", "burg", "watch", "fall", "dale", "reach"};
  return prefixes[int(random(prefixes.length))] + suffixes[int(random(suffixes.length))];
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

void drawConnections() {
  stroke(0);
  for (City c : cities) {
    for (City conn : c.connections) {
      if (c.id < conn.id) {
        float d = dist(c.x, c.y, conn.x, conn.y);
        line(c.x, c.y, conn.x, conn.y);

        // Optional: draw road cost
        fill(0);
        text(nf(d, 1, 1), (c.x + conn.x) / 2, (c.y + conn.y) / 2);
      }
    }
  }
}

void drawCities() {
  for (City c : cities) {
    c.drawCity();
  }
}

void mousePressed() {
  for (City c : cities) {
    float d = dist(mouseX, mouseY, c.x, c.y);
    if (d < citySize * 1.5) {
      if (selectedCityA == null) {
        selectedCityA = c;
      } else if (selectedCityB == null && c != selectedCityA) {
        selectedCityB = c;

        if (selectedCityA.connections.contains(selectedCityB)) {
          selectedCityA.connections.remove(selectedCityB);
          selectedCityB.connections.remove(selectedCityA);
          println("Disconnected " + selectedCityA.name + " from " + selectedCityB.name);
        } else {
          selectedCityA.connectTo(selectedCityB);
          println("Connected " + selectedCityA.name + " to " + selectedCityB.name);
        }

        selectedCityA = null;
        selectedCityB = null;
      }
      break;
    }
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    save("map.jpg");
    println("map.jpg exported");
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
  if (key == 'r' || key == 'R') {
    String[] cardLines = new String[numCards];
    for (int i = 0; i < numCards; i++) {
      cardLines[i] = cards[i].city.name + ", " + cards[i].resource;
    }
    saveStrings("cards.txt", cardLines);
    println("Card list exported to cards.txt");
  }
}

void generateCards() {
  cards = new Card[numCards];
  for (int i = 0; i < numCards; i++) {
    City randCity = cities[int(random(cities.length))];
    String res = weightedRandomResourceByPosition(randCity.y);
    cards[i] = new Card(randCity, res);

    if (!cityResources.containsKey(randCity)) {
      cityResources.put(randCity, new ArrayList<String>());
    }
    if (!cityResources.get(randCity).contains(res)) {
      cityResources.get(randCity).add(res);
    }
  }
}

String weightedRandomResourceByPosition(float y) {
  float normalizedY = map(y, 50, height - 50, 0, 1); // 0 = north, 1 = south
  float coalProb = lerp(0.6, 0.2, normalizedY);
  float lumberProb = lerp(0.1, 0.5, normalizedY);
  float r = random(1);

  if (r < coalProb) return "coal";
  else if (r < coalProb + lumberProb) return "lumber";
  else if (r < coalProb + lumberProb + 0.1) return "copper";
  else if (r < coalProb + lumberProb + 0.2) return "silver";
  else return "gold";
}

int getResourceIndex(String res) {
  for (int i = 0; i < resources.length; i++) {
    if (resources[i].equals(res)) return i;
  }
  return 0; // fallback
}

class City {
  float x, y;
  String name;
  int id;
  ArrayList<City> connections = new ArrayList<City>();

  City(float x, float y, String name) {
    this.x = x;
    this.y = y;
    this.name = name;
    this.id = int(random(100000));
  }

  void connectTo(City other) {
    if (!connections.contains(other)) connections.add(other);
    if (!other.connections.contains(this)) other.connections.add(this);
  }

  void drawCity() {
    fill(50, 100, 200);
    stroke(0);
    ellipse(x, y, citySize, citySize);

    fill(0);
    text(name, x, y - citySize * 1.5);

    // Draw resource dots
    if (cityResources.containsKey(this)) {
      ArrayList<String> resList = cityResources.get(this);
      float offsetStep = 6;
      float baseY = y + citySize / 2 + 4;

      for (int i = 0; i < resList.size(); i++) {
        String res = resList.get(i);
        int resIndex = getResourceIndex(res);
        fill(resourceColors[resIndex]);
        noStroke();
        ellipse(x + (i - resList.size() / 2.0) * offsetStep, baseY, 6, 6);
      }
    }
  }
}

class Card {
  City city;
  String resource;

  Card(City city, String resource) {
    this.city = city;
    this.resource = resource;
  }
}
