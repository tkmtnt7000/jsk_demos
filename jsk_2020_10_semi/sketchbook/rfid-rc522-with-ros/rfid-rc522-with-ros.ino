#include <SPI.h>
#include <MFRC522.h>

#include <ros.h>
#include <std_msgs/Int16.h>
#include <std_msgs/String.h>
ros::NodeHandle nh;
std_msgs::Int16 ic_msg;
std_msgs::String ic_uid_msg;
ros::Publisher ic_pub("/rfid/sound", &ic_msg);
ros::Publisher card_id_pub("/rfid/uid", &ic_uid_msg);

constexpr uint8_t RST_PIN = 9;
constexpr uint8_t SS_PIN = 10;

#define UID "2C AD BA 16" // 取得した識別子を記述
#define UID_card "09 11 E3 B2"

int led_blue = 8;
int led_red = 3;
char charUID[15];

MFRC522 mfrc522(SS_PIN, RST_PIN);
MFRC522::MIFARE_Key key;

void ic_touch_sound(){
  ic_msg.data = 1;
  ic_pub.publish(&ic_msg);
}

void setup() {

    nh.initNode();
    nh.advertise(ic_pub);
    //Serial.begin(9600);
    //pinMode(led_blue, OUTPUT);
    //pinMode(led_red, OUTPUT);
    while (!Serial);
    SPI.begin();
    mfrc522.PCD_Init();    
    mfrc522.PCD_DumpVersionToSerial();
    //Serial.println(F("Scan PICC to see UID, SAK, type, and data blocks..."));

    dump_byte_array(key.keyByte, MFRC522::MF_KEY_SIZE);
}

void loop() {
    // put on ic card when initializing
    
    if ( ! mfrc522.PICC_IsNewCardPresent()) {
        //ic_msg.data = 2;
        //ic_pub.publish(&ic_msg);
    }
    if ( ! mfrc522.PICC_ReadCardSerial()) {
        return;
    }
    

    String strBuf[mfrc522.uid.size];
    for (byte i = 0; i < mfrc522.uid.size; i++) {
        strBuf[i] =  String(mfrc522.uid.uidByte[i], HEX);
        if(strBuf[i].length() == 1){
          strBuf[i] = "0" + strBuf[i];
        }
    }
    
    String strUID = strBuf[0] + " " + strBuf[1] + " " + strBuf[2] + " " + strBuf[3] ;//+ " " + strBuf[4] + " " + strBuf[5] + " " + strBuf[6];
    //charUID = strBuf[0] + " " + strBuf[1] + " " + strBuf[2] + " " + strBuf[3] ;
    if ( strUID.equalsIgnoreCase(UID_card) ){
        //Serial.println("verified!");
        //digitalWrite(led_blue, HIGH); // 青いLEDを光らせる
        //delay(1000); // 1秒待つ
        //digitalWrite(led_blue, LOW); // 青いLEDを消す
        ic_msg.data = 1;
        //ic_uid_msg.data = strUID.c_str();
        ic_pub.publish(&ic_msg);
        delay(1000);
    } else {
        //Serial.println("error!");
        //analogWrite(led_red, 180); // 赤いLEDを光らせる
        //delay(1000); // 1秒待つ
        //analogWrite(led_red, 0); // 赤いLEDを消す
        ic_msg.data = 0;
        ic_pub.publish(&ic_msg);
        delay(1000);
    }
    //ic_pub.publish(&ic_msg);
    //card_id_pub.publish(&ic_uid_msg);
    nh.spinOnce();
}

void dump_byte_array(byte *buffer, byte bufferSize) {
    for (byte i = 0; i < bufferSize; i++) {
        //Serial.print(buffer[i] < 0x10 ? " 0" : " ");
        //Serial.print(buffer[i], HEX);
    }
}
