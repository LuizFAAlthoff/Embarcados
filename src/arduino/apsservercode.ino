#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include "dht.h"
#include <ESP8266HTTPClient.h>

const char* ssid = "Akdkd";
const char* password = "awyn9876";
const float pinoDHT11 = 12; //PINO ANALÓGICO UTILIZADO PELO DHT11
String backendServer = "http://192.168.122.141:3000/registro/";

WiFiClient wifiClient;
dht DHT; //VARIÁVEL DO TIPO DHT

void setup(void) {

  Serial.begin(115200); //Inicializa a comunicação serial
  delay(50); // ?Intervalo para aguardar a estabilização do sistema
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.println("");

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

}
 
void loop(void) {
  
  DHT.read11(pinoDHT11); //LÊ AS INFORMAÇÕES DO SENSOR

  HTTPClient http;    //Declare object of class HTTPClient
 
  http.begin(wifiClient, backendServer);      //Specify request destination using wifiClient and backendServer
  http.addHeader("Content-Type", "application/json");  //Specify content-type header
 
  String json = "{\"celsius\": " + String(DHT.temperature) + ",\n"
              "\"umidade\": " + String(DHT.humidity) + "}";

  int httpCode = http.POST(json);   //Send the request
  String payload = http.getString();                  //Get the response payload
 
  Serial.println(httpCode);   //Print HTTP return code
  Serial.println(payload);    //Print request response payload
 
  http.end();  //Close connection

  delay(3000);
}