#!/usr/bin/env python
from pyzbar.pyzbar import decode
import cv2
import rospy
from std_msgs.msg import Int16


def main():
    #cap = cv2.VideoCapture(0) # when using pccam
    cap = cv2.VideoCapture(5) # when using webcam

    font = cv2.FONT_HERSHEY_SIMPLEX
    
    pub = rospy.Publisher('qrcode', Int16, queue_size=10)
    rospy.init_node('qrcode', anonymous=True)
    qrcode_pub = Int16()
    #r = rospy.Rate(10)
    while cap.isOpened():
        ret, frame = cap.read()
        if ret == True:
            d = decode(frame)
            if d:
                qrcode_pub.data = 1
                #pub.publish(qrcode_pub)
                for barcode in d:
                    x, y, w, h = barcode.rect
                    cv2.rectangle(frame,(x,y), (x+w, y+h), (0, 0, 255), 2)
                    barcodeData = barcode.data.decode('utf-8')
                    frame = cv2.putText(frame, barcodeData, (x, y-10), font, .5, (0, 0, 255), 2, cv2.LINE_AA)
                    
            else:
                qrcode_pub.data = 0
            cv2.imshow('frame', frame)
            pub.publish(qrcode_pub)
            

            if cv2.waitKey(1) & 0xFF ==ord('q'):
                break

    cap.release()

if __name__=='__main__':
    main()

