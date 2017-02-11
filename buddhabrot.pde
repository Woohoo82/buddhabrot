// Trace des ensembles de julia
// centre remarquable : (0.0016437219719554978, -0.8224676332977523)
 
 
//variables globales, en com a droite : valeur de départ vue globale
float zoom;
//centre
double x = -0.5d; //-0.5
double y = 0d; //0
//echelle
double ex = 3.6d; //3.6 - largeur
double ey = 2.4d; //2.4 - hauteur
//repères affichage
double xmin;
double xmax;
double ymin;
double ymax;
//z0
double re = 0d;
double im = 0d;
//paramètres
int nmax = 100; // 200 - nb itérations max (plus c'est grand, plus l'ensemble est précis, plus l'image est belle et plus c'est lent)
int lum = 6; // 6 - pour la luminosité (peut etre utile de changer pour des grands zooms
 
double dragx, dragy; // pour se balader avec la souris

int[][] buff;  // image buffer (unnormalised counters)

int[] maxIter = {20000, 2000, 200};

//int iterCount = 0;
 
void setup()
{
  size(displayWidth, displayHeight);
  //size(800, 500);
  background(0);
  buff = new int[3][width * height];
  noLoop();
}
 
void draw()
{
  for (int ch = 0; ch < 3; ch++)
    julia(ch);
    
  loadPixels();
  fillBuff();
  updatePixels();
  
  println("elapsed:", millis() / 1000);
}
 
//infos image
void mousePressed()
{
  println();
  println("Z0 : ("+re+", "+im+")");
  println("Centre : ("+x+", "+y+")");
  println("Echelle : ("+ex+", "+ey+")");
  println("Pointeur : ("+map(mouseX, 0, width, xmin, xmax)+", "+map(mouseY, 0, height, ymax, ymin)+")");
  println("Itérations : "+nmax);
  println();
   
  dragx = map(mouseX, 0, width, xmin, xmax);
  dragy = map(mouseY, 0, height, ymax, ymin);
}
 
void mouseReleased()
{
  x -= map(mouseX, 0, width, xmin, xmax)-dragx;
  y -= map(mouseY, 0, height, ymax, ymin)-dragy;
}
 
//zoom
void mouseWheel(MouseEvent event)
{
  zoom = 0.8;
  if(event.getCount() < 0){zoom = 1.125;}
  //point fixe
  double i = map(mouseX, 0, width, xmin, xmax);
  double j = map(mouseY, 0, height, ymax, ymin);
  //calcul de la nouvelle echelle
  ex *= zoom;
  ey *= zoom;
  //nouveau centre
  x = i - (i-x)*zoom;
  y = j - (j-y)*zoom;
  
  draw();
}
 
void julia(int channel)
{
  print("calculating channel", channel, "...");
  //balayage de tous les pixels
  for(int i=0; i < width; i++){
    for(int j=0; j < height; j++){
      int n = beforeEscape(i, j);
      if(n != nmax)
        //pixelMandel(i, j, n);
        traceBuddha(i, j, channel);
    }
  }
  println(" ok");
}

int beforeEscape(int i, int j){
  // min-max des axes
  xmin = x - ex/2d;
  xmax = xmin+ex;
  ymin = y - ey/2d;
  ymax = ymin+ey;
   
  double a, b; // point du plan complexe
  double k, l; // pour convertir les int en double
  double xn, yn; // termes de la suite
  int n; // index de la suite
  k = i;
  l = j;
  // correspondance pixel / point du plan
  a = map(k, 0, width, xmin, xmax);
  b = map(l, 0, height, ymax, ymin);
  a += random(1.0)*((xmax - xmin) / width);
  b += random(1.0)*((ymax - ymin) / height);
  // initialisation premier terme de la suite, n=0
  xn = re; 
  yn = im;
  //calcul des termes suivants de la suite
  //on s'arrete si le module du terme est supérieur à 2 (la suite diverge, le point n'est pas dans l'ensemble)
  n = 1;
  double pxn; // pour stocker x(n-1)
  // calcul jusqu'au (nmax-1)ème terme de la suite
  while(n < nmax) {
    // z(n+1) = z(n)^2+c
    pxn = xn;
    xn = xn*xn - yn*yn + a;
    yn = 2*yn*pxn + b;
    if(xn*xn+yn*yn > 4){break;}
    n++;
  }
  return n;
}

void traceBuddha(int i, int j, int channel){
  // min-max des axes
  xmin = x - ex/2d;
  xmax = xmin+ex;
  ymin = y - ey/2d;
  ymax = ymin+ey;
   
  double a, b; // point du plan complexe
  double k, l; // pour convertir les int en double
  double xn, yn; // termes de la suite
  int n; // index de la suite
  k = i;
  l = j;
  // correspondance pixel / point du plan
  a = map(k, 0, width, xmin, xmax);
  b = map(l, 0, height, ymax, ymin);
  a += random(2.0)*((xmax - xmin) / width);
  b += random(2.0)*((ymax - ymin) / height);
  // initialisation premier terme de la suite, n=0
  xn = re; 
  yn = im;
  //calcul des termes suivants de la suite
  //on s'arrete si le module du terme est supérieur à 2 (la suite diverge, le point n'est pas dans l'ensemble)
  n = 1;
  double pxn; // pour stocker x(n-1)
  // calcul jusqu'au (nmax-1)ème terme de la suite
  while(n < maxIter[channel]) {
    // z(n+1) = z(n)^2+c
    pxn = xn;
    xn = xn*xn - yn*yn + a;
    yn = 2*yn*pxn + b;
    n++;
    pixelBuddha(xn, yn, channel);
  }
}

void pixelBuddha(double x, double y, int ch){
  int px = (int)Math.round(map(x, xmin, xmax, 0, width));
  int py = (int)Math.round(map(y, ymin, ymax, 0, height));
  //println(px, ", ", py); delay(100);
  if (px > 0 && px < width && py > 0 && py < height)
    buff[ch][ px + py * width]++;
}

void fillBuff(){
  normalise();
  
  for (int i=0 ; i < width * height; i++)
      pixels[i] = color(buff[0][i], buff[1][i], buff[2][i]);
}

void normalise(){
  float   inf = 1.0/0.0;
  float[] max = {0.0, 0.0, 0.0};
  float[] min = {inf, inf, inf};
  
  for (int i=0 ; i < width * height; i++) {
    for (int ch=0 ; ch < 3; ch++) {
      if (buff[ch][i] > max[ch]) max[ch] = buff[ch][i];
      if (buff[ch][i] < min[ch]) min[ch] = buff[ch][i];
    }
  }
  
  max[0] *= 0.0004;    //R 0.0004  G 0.008  B 0.16
  min[0] = max[0] / 6;
  max[1] *= 0.008;
  min[1] = max[1] / 6;
  max[2] *= 0.06;
  min[2] = max[2] / 6;

  for (int i=0 ; i < width * height; i++) {
    for (int ch=0 ; ch < 3; ch++) {
      buff[ch][i] = round(map(buff[ch][i], min[ch], max[ch], 0, 255));
    }
  }
}
 
void zoom() // zoom sur le centre
{
  ex *= zoom;
  ey *= zoom;
}
 
double map(double a, double x1, double x2, double y1, double y2)
{
  double ratio = (y2-y1)/(x2-x1);
  return y1 + (a-x1)*ratio;
}