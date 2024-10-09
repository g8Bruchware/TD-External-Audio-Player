import hypermedia.net.*;
import processing.sound.*;

int port = 9000;
int sendPort = 9001;
String ip = "127.0.0.1";
UDP udp;

JSONArray values;

ArrayList<SoundFile> soundFiles = new ArrayList<SoundFile>();

void setup() {
  size(100, 100);
  windowMove(-200, -200);

  udp = new UDP(this, port, ip);
  //udp.log(true);
  udp.listen(true);
  background(255, 0, 0);

  values = loadJSONArray("soundfiles.json");


  for (int i = 0; i < values.size(); i++) {
    JSONObject fileObject = values.getJSONObject(i);
    String file = fileObject.getString("file");
    float volume = fileObject.getFloat("volume");
    println(volume);
    println("load File: " + file);
    soundFiles.add(new SoundFile(this, file));
  }

  loop();
}

void draw() {
  delay(100);
  udp.send("connected", ip, sendPort);
  background(0, 255, 0);
  for (int i = 0; i < soundFiles.size(); i++) {
    udp.send(i+":"+int(soundFiles.get(i).isPlaying()), ip, sendPort);
  }
}

void receive(byte[] data, String ip, int port) {

  String message = new String(data);

  println(message);
  String[] splitted = message.split(":");
  if (splitted.length > 1) {
    String control = splitted[0];
    int index = int(splitted[1]);

    if (control.equals("play")) {
      if (soundFiles.get(index).isPlaying()) {
        soundFiles.get(index).stop();
        soundFiles.get(index).play();
      } else {
        soundFiles.get(index).play();
      }
    }

    if (control.equals("loop")) {
      soundFiles.get(index).loop();
    }

    if (control.equals("stop")) {
      soundFiles.get(index).stop();
    }
  }

  if (message.equals("hi")) {
    udp.send("connected", ip, sendPort);
  }
  if (message.equals("exit")) {
    exit();
  }
}
