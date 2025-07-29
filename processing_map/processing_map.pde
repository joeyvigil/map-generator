//10 = 1 cm, 1 = 1mm, map = 44cm x 44cm

// size(sizex,sizey) , change
size(440,440); 
int scaler = 1;
int sizex =440*scaler;
int sizey =440*scaler;
int cities = 100;
int roads = 200;
int city_size = 10*scaler;
int min_dis = 30*scaler; //min distance for making cities at least a certain distance apart
int max_dis = 60*scaler; //max distance for making sure roads arent too long


int[] pointx = {int(random(1,sizex))}; //cities defind by an x and y
int[] pointy = {int(random(1,sizey))};

int[] roada = {1}; //roads defined by two cities a & b
int[] roadb = {1};


//generate cities,  checks dist(x1, y1, x2, y2) if greater than min_dis, adds to point arrays if so
while (pointx.length < cities) {
  int tempx = int(random(1,sizex));
  int tempy = int(random(1,sizey));
  print("a");
  boolean make = true; //will 'make' if the the the distance is not within min lenth for each point
  for (int i = 0; i < pointx.length; i = i+1) {
    print("b");
    if(dist(tempx,tempy,pointx[i],pointy[i])< min_dis){
      print("c");
      make = false;
    }
  }
  if(make){
      pointx = append(pointx, tempx);
      pointy = append(pointy, tempy);
  }
}

//generate roads, gets 2 random cities, checks dist(x1, y1, x2, y2) if less than max_dis, adds to point arrays if so
while (roada.length < roads) {
  int tempa= int(random(0,pointx.length-1));
  int tempb= int(random(0,pointx.length-1));
  println("d " +tempa+" "+tempb);
  if(dist(pointx[tempa], pointy[tempa], pointx[tempb], pointy[tempb]) <max_dis){
    print("e");
    roada = append(roada, tempa);
    roadb = append(roadb, tempb);
  }
}


//draw cities
for (int i = 0; i < cities; i = i+1) {
  circle(pointx[i], pointy[i], city_size);
}

//draw roads
for (int i = 0; i < roads; i = i+1) {
  line(pointx[roada[i]], pointy[roada[i]], pointx[roadb[i]], pointy[roadb[i]]);
}

for (int i = 0; i < cities; i = i+1) {
  //print(i);
  println("point "+i+" "+pointx[i]+ ","+pointy[i]);
}
for (int i = 0; i < roads; i = i+1) {
  //print(i);
  println("road "+i+" "+roada[i]+ ","+roadb[i]);
}

save("map.jpg");
