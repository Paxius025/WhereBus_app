#include <WiFi.h>
#include <HTTPClient.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

// WiFi credentials
const char* ssid = "your-SSID";
const char* password = "your-PASSWORD";

// Server URL
const char* serverUrl = "http://your-server-url.com/api/gps";

// Bus ID
const char* bus_id = "1"; // Assign a unique bus ID

// GPS module setup
static const int RXPin = 16, TXPin = 17;
static const uint32_t GPSBaud = 9600;
TinyGPSPlus gps;
SoftwareSerial gpsSerial(RXPin, TXPin);

void setup() {
  Serial.begin(115200);
  gpsSerial.begin(GPSBaud);

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}

void loop() {
  // Check if GPS data is available
  while (gpsSerial.available() > 0) {
    gps.encode(gpsSerial.read());
    if (gps.location.isUpdated()) {
      double latitude = gps.location.lat();
      double longitude = gps.location.lng();
      
      Serial.print("Latitude: ");
      Serial.println(latitude, 6);
      Serial.print("Longitude: ");
      Serial.println(longitude, 6);
      String busStatus = "Online";
      // Send GPS data with bus_id to the server
      if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;
        http.begin(serverUrl);
        http.addHeader("Content-Type", "application/x-www-form-urlencoded");

        String httpRequestData = "bus_id=" + String(bus_id) + "&latitude=" + String(latitude, 6) + "&longitude=" + String(longitude, 6)+ "&status=" + busStatus;
        
        int httpResponseCode = http.POST(httpRequestData);
        if (httpResponseCode > 0) {
          Serial.println("Data sent successfully");
        } else {
          Serial.println("Error sending data");
        }

        http.end();
      } else {
        Serial.println("WiFi not connected");
      }

      // Wait 10 seconds before sending the next GPS data
      delay(10000);
    }
  }
}
