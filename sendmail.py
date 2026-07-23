import smtplib
from email.mime.text import MIMEText
from email.utils import formatdate
import cv2
import mediapipe as mp
import numpy as np
import time  # 追加

mp_holistic = mp.solutions.holistic
mp_drawing = mp.solutions.drawing_utils

sendAddress = input("送信者メールアドレス: ")
password = input("アプリパスワード: ")
subject = '人物動作検出通知'
bodyText = '人物の動作を検出しました。'
fromAddress = sendAddress
toAddress = sendAddress

def send_mail():
    smtpobj = smtplib.SMTP('smtp.gmail.com', 587)
    smtpobj.starttls()
    smtpobj.login(sendAddress, password)
    msg = MIMEText(bodyText)
    msg['Subject'] = subject
    msg['From'] = fromAddress
    msg['To'] = toAddress
    msg['Date'] = formatdate()
    smtpobj.send_message(msg)
    smtpobj.close()

cap = cv2.VideoCapture(0)

def get_pose_vector(landmarks, shape):
    # ランドマーク座標を1次元配列に
    h, w, _ = shape
    return np.array([[lm.x * w, lm.y * h] for lm in landmarks.landmark]).flatten()

with mp_holistic.Holistic(
    static_image_mode=False,
    model_complexity=1,
    enable_segmentation=False,
    refine_face_landmarks=True,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
) as holistic:
    prev_pose = None
    motion_detected = False  # 動作検出フラグ
    interval = 20  # 秒
    last_check = time.time()  # タイマー開始

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = holistic.process(rgb)

        detected = False
        # 顔を囲む
        if results.face_landmarks:
            detected = True
            h, w, _ = frame.shape
            face_points = [(int(lm.x * w), int(lm.y * h)) for lm in results.face_landmarks.landmark]
            x_list = [p[0] for p in face_points]
            y_list = [p[1] for p in face_points]
            x_min, x_max = min(x_list), max(x_list)
            y_min, y_max = min(y_list), max(y_list)
            cv2.rectangle(frame, (x_min, y_min), (x_max, y_max), (0, 255, 0), 2)

        # 手・体の骨格を描画
        if results.left_hand_landmarks:
            detected = True
            mp_drawing.draw_landmarks(
                frame, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(0,0,255), thickness=2, circle_radius=2),
                mp_drawing.DrawingSpec(color=(0,255,0), thickness=2)
            )
        if results.right_hand_landmarks:
            detected = True
            mp_drawing.draw_landmarks(
                frame, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(0,0,255), thickness=2, circle_radius=2),
                mp_drawing.DrawingSpec(color=(0,255,0), thickness=2)
            )
        if results.pose_landmarks:
            detected = True
            mp_drawing.draw_landmarks(
                frame, results.pose_landmarks, mp_holistic.POSE_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(255,0,0), thickness=2, circle_radius=2),
                mp_drawing.DrawingSpec(color=(0,255,255), thickness=2)
            )

            # 動きの大きさを判定
            pose_vec = get_pose_vector(results.pose_landmarks, frame.shape)
            if prev_pose is not None:
                diff = np.linalg.norm(pose_vec - prev_pose)
                # 動きが大きいときフラグを立てる
                if diff > 100:  # この値は調整してください
                    motion_detected = True
            prev_pose = pose_vec

        # 1分ごとにチェック
        now = time.time()
        if now - last_check >= interval:
            if motion_detected:
                # メール送信の代わりに、OpenCVで画像を保存する
                cv2.imwrite('alert.jpg', frame)
                print(" 動作を検知しました！alert.jpg として保存しました。")
            motion_detected = False  # フラグリセット
            last_check = now

        cv2.imshow('Holistic Detection', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

cap.release()
cv2.destroyAllWindows()
