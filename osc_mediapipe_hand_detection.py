# Atsuya Kobayashi 2020-12-22
# Modified by Ryota Kato 2021-1-10
# Reference: https://google.github.io/mediapipe/solutions/hands , https://gist.github.com/atsukoba/d94e9f0187246ce84cffa70f0a17ea5c
# LICENCE: MIT

from itertools import chain

import mediapipe as mp
from cv2 import cv2
from pythonosc import udp_client
import numpy as np

IP = "127.0.0.1"
PORT = 6448
VIDEO_DEVICE_ID = 0
RELATIVE_AXIS_MODE = True

HAND_LANDMARK_NAMES = [
    "wrist",
    "thumb_1",
    "thumb_2",
    "thumb_3",
    "thumb_4",
    "index_1",
    "index_2",
    "index_3",
    "index_4",
    "middle_1",
    "middle_2",
    "middle_3",
    "middle_4",
    "ring_1",
    "ring_2",
    "ring_3",
    "ring_4",
    "pinky_1",
    "pinky_2",
    "pinky_3",
    "pinky_4"
]


def extract_detected_hands_points(multi_hand_landmarks,
                                  send_osc_client=None):

    if multi_hand_landmarks is not None:
        vectors = [0] * 21
        wrist = [multi_hand_landmarks[0].landmark[0].x, multi_hand_landmarks[0].landmark[0].y]
        # print(wrist)
        for hand_idx, landmarks in enumerate(multi_hand_landmarks):
            for point_idx, points in enumerate(landmarks.landmark):
                # ここで手首を起点にした各ポイントに対するベクトルは取れている
                vectors[point_idx] = np.array([wrist[0] - points.x, wrist[1] - points.y])

                # print(f"wrist to {HAND_LANDMARK_NAMES[point_idx]} : {vectors[point_idx]}")
                # if you want to check data on console
                # print(f"Hand: {hand_idx}, {HAND_LANDMARK_NAMES[point_idx]},"
                #       + f"x:{points.x} y:{points.y} z:{points.z}")
                """
                if you want to send data to addresses correspoding
                to landmarks names on detected hands, use berow
                """
                # if send_osc_client is not None:
                #     send_osc_client.send_message(f"/{HAND_LANDMARK_NAMES[point_idx]}",
                #                                  [points.x, points.y])

            """if you want to send data to single input address, use berow"""
            if send_osc_client is not None:
                send_osc_client.send_message(
                    f"/wek/inputs",
                    list(chain.from_iterable([[p[0], p[1]] for p in vectors])))
        # print(vectors)


if __name__ == "__main__":

    mp_drawing = mp.solutions.drawing_utils
    mp_hands = mp.solutions.hands

    hands = mp_hands.Hands(
        min_detection_confidence=0.5, min_tracking_confidence=0.5)

    cap = cv2.VideoCapture(VIDEO_DEVICE_ID)

    osc_client = udp_client.SimpleUDPClient(IP, PORT)

    while cap.isOpened():
        success, image = cap.read()
        if not success:
            print("Ignoring empty camera frame.")
            # If loading a video, use 'break' instead of 'continue'.
            continue

        image = cv2.cvtColor(cv2.flip(image, 1), cv2.COLOR_BGR2RGB)
        image.flags.writeable = False
        results = hands.process(image)
        extract_detected_hands_points(results.multi_hand_landmarks,
                                      send_osc_client=osc_client)
        image.flags.writeable = True
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                mp_drawing.draw_landmarks(
                    image, hand_landmarks, mp_hands.HAND_CONNECTIONS)
        cv2.imshow('Detected Hands', image)

        if cv2.waitKey(5) & 0xFF == 27:
            break

    hands.close()
    cap.release()
