#!/usr/bin/env python
import pygame
import time

if __name__ == '__main__':
    pygame.mixer.init()
    pygame.mixer.music.load("Ticket_Gate-Alarm01-1(Timbre1-Flap).mp3")
    pygame.mixer.music.play(1)
    time.sleep(5)
    pygame.mixer.music.stop()
