#!/usr/bin/env python
import pygame
import time
import rospy
from std_msgs.msg import Int16

flag = True

def qr_callback(msg):
    #print msg.data
    global flag
    if msg.data == 1:
        #if flag == True:
        rospy.loginfo("beep!")
        pygame.mixer.music.play(1)
        time.sleep(2)
        pygame.mixer.music.stop()
        #flag = not flag
            #print flag
    else:
        flag = True
        pygame.mixer.music.stop()
    
def qr_sub():
    rospy.init_node('ic_connector', anonymous=True)
    rospy.Subscriber('/rfid/sound', Int16, qr_callback)
    rospy.spin()


def main():
    global flag
    pygame.mixer.init()
    pygame.mixer.music.load("../sounds/Ticket_Gate-Beep01-mp3/Ticket_Gate-Beep01-01(Tone1).mp3")
    qr_sub()
    
if __name__ == '__main__':
    main()
