#include <Stepper.h>

#include <math.h>
#include <ros.h>
ros::NodeHandle  nh;

#include <sensor_msgs/Range.h>
#include <std_msgs/Int16.h>

#define DIN_PIN 12
//std_msgs::Int16 pin_msg; 
//ros::Publisher arduino_pub("arduino", &pin_msg);

int pin_msg;
void pin_setup()
{
  pinMode( DIN_PIN, INPUT_PULLUP );
  pin_msg = 0;
  //pin_msg.data = 0;
  //nh.advertise(arduino_pub);
}

//int pin_msg;
void pin_loop()
{
  Serial.begin(9600);
  //pinMode( DIN_PIN, INPUT_PULLUP );
  //pin_msg.data = digitalRead(DIN_PIN);
  pin_msg = digitalRead(DIN_PIN);
  Serial.println(pin_msg);
  //arduino_pub.publish(&pin_msg);
}

void setup()
{
  //nh.initNode();
  pin_setup();
}

unsigned long timer = 0;
void loop()
{
  unsigned long now = millis();
  // measure and publich pin value every 1000 milliseconds
  if ( (now - timer) > 1000 ) {
    pin_loop();
    timer = now;
  }
  //nh.spinOnce();
}
