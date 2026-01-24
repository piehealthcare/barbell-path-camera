#!/usr/bin/env python3
"""
바벨 끝단 라벨링 도구
- 이미지를 로드하고 바벨 플레이트 끝단을 클릭하여 라벨링
- YOLO 형식으로 라벨 저장
- 키보드 단축키로 빠른 작업 가능

사용법:
    python3 label_barbell_endpoints.py [이미지_폴더]

키보드 단축키:
    좌클릭: 바벨 끝단 위치 지정 (드래그로 바운딩 박스 생성)
    우클릭: 마지막 라벨 삭제
    n/Space: 다음 이미지
    p/Backspace: 이전 이미지
    s: 현재 이미지 저장
    d: 현재 이미지의 모든 라벨 삭제
    q/Esc: 종료
    h: 도움말 표시
"""

import cv2
import numpy as np
from pathlib import Path
import sys
import json

# 설정
BOX_SIZE = 50  # 기본 바운딩 박스 크기 (픽셀)
CLASS_ID = 0   # barbell_plate_side 클래스 ID
CLASS_NAME = "barbell_plate_side"


class BarbellLabeler:
    def __init__(self, image_dir: str):
        self.image_dir = Path(image_dir)
        self.labels_dir = self.image_dir.parent / "labels"
        self.labels_dir.mkdir(exist_ok=True)

        # 이미지 파일 목록
        self.images = sorted([
            f for f in self.image_dir.glob("*")
            if f.suffix.lower() in [".jpg", ".jpeg", ".png", ".bmp"]
        ])

        if not self.images:
            print(f"이미지를 찾을 수 없습니다: {image_dir}")
            sys.exit(1)

        self.current_idx = 0
        self.current_labels = []  # [(cx, cy, w, h), ...]
        self.drawing = False
        self.start_point = None
        self.current_point = None

        # 윈도우 설정
        self.window_name = "Barbell Endpoint Labeler"
        cv2.namedWindow(self.window_name, cv2.WINDOW_NORMAL)
        cv2.setMouseCallback(self.window_name, self.mouse_callback)

        # 상태
        self.modified = False
        self.show_help = False

        print(f"\n{'='*50}")
        print("바벨 끝단 라벨링 도구")
        print(f"{'='*50}")
        print(f"이미지 폴더: {self.image_dir}")
        print(f"라벨 저장 폴더: {self.labels_dir}")
        print(f"총 이미지: {len(self.images)}개")
        print(f"\n'h' 키를 누르면 도움말 표시")
        print(f"{'='*50}\n")

    def load_labels(self):
        """현재 이미지의 라벨 로드"""
        self.current_labels = []
        label_path = self.labels_dir / f"{self.images[self.current_idx].stem}.txt"

        if label_path.exists():
            with open(label_path, "r") as f:
                for line in f:
                    parts = line.strip().split()
                    if len(parts) >= 5:
                        # class_id cx cy w h
                        _, cx, cy, w, h = parts[:5]
                        self.current_labels.append((
                            float(cx), float(cy), float(w), float(h)
                        ))

        self.modified = False

    def save_labels(self):
        """현재 이미지의 라벨 저장"""
        label_path = self.labels_dir / f"{self.images[self.current_idx].stem}.txt"

        with open(label_path, "w") as f:
            for cx, cy, w, h in self.current_labels:
                f.write(f"{CLASS_ID} {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}\n")

        self.modified = False
        print(f"저장됨: {label_path.name} ({len(self.current_labels)}개 라벨)")

    def mouse_callback(self, event, x, y, flags, param):
        """마우스 이벤트 처리"""
        if self.image is None:
            return

        h, w = self.image.shape[:2]

        if event == cv2.EVENT_LBUTTONDOWN:
            # 드래그 시작
            self.drawing = True
            self.start_point = (x, y)
            self.current_point = (x, y)

        elif event == cv2.EVENT_MOUSEMOVE and self.drawing:
            # 드래그 중
            self.current_point = (x, y)

        elif event == cv2.EVENT_LBUTTONUP:
            # 드래그 종료 - 바운딩 박스 생성
            self.drawing = False

            if self.start_point:
                x1, y1 = self.start_point
                x2, y2 = x, y

                # 너무 작으면 기본 크기 사용
                if abs(x2 - x1) < 10 and abs(y2 - y1) < 10:
                    # 클릭만 한 경우 - 기본 크기 박스
                    half = BOX_SIZE // 2
                    x1 = max(0, x - half)
                    y1 = max(0, y - half)
                    x2 = min(w, x + half)
                    y2 = min(h, y + half)
                else:
                    # 드래그한 경우 - 정규화
                    x1, x2 = min(x1, x2), max(x1, x2)
                    y1, y2 = min(y1, y2), max(y1, y2)

                # YOLO 형식으로 변환 (정규화)
                cx = (x1 + x2) / 2 / w
                cy = (y1 + y2) / 2 / h
                bw = (x2 - x1) / w
                bh = (y2 - y1) / h

                self.current_labels.append((cx, cy, bw, bh))
                self.modified = True
                self.start_point = None
                self.current_point = None

        elif event == cv2.EVENT_RBUTTONDOWN:
            # 우클릭 - 마지막 라벨 삭제
            if self.current_labels:
                self.current_labels.pop()
                self.modified = True

    def draw_frame(self):
        """현재 프레임 그리기"""
        if self.image is None:
            return np.zeros((480, 640, 3), dtype=np.uint8)

        frame = self.image.copy()
        h, w = frame.shape[:2]

        # 라벨 그리기
        for i, (cx, cy, bw, bh) in enumerate(self.current_labels):
            x1 = int((cx - bw/2) * w)
            y1 = int((cy - bh/2) * h)
            x2 = int((cx + bw/2) * w)
            y2 = int((cy + bh/2) * h)

            # 바운딩 박스
            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

            # 중심점
            cx_px = int(cx * w)
            cy_px = int(cy * h)
            cv2.circle(frame, (cx_px, cy_px), 5, (0, 0, 255), -1)
            cv2.drawMarker(frame, (cx_px, cy_px), (0, 0, 255),
                          cv2.MARKER_CROSS, 20, 2)

            # 라벨 번호
            cv2.putText(frame, f"#{i+1}", (x1, y1-5),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

        # 드래그 중인 박스
        if self.drawing and self.start_point and self.current_point:
            cv2.rectangle(frame, self.start_point, self.current_point,
                         (255, 255, 0), 2)

        # 상태 바
        status_h = 80
        status_bar = np.zeros((status_h, w, 3), dtype=np.uint8)

        # 파일 정보
        filename = self.images[self.current_idx].name
        progress = f"{self.current_idx + 1}/{len(self.images)}"
        labels_count = len(self.current_labels)

        cv2.putText(status_bar, f"File: {filename}", (10, 25),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
        cv2.putText(status_bar, f"Progress: {progress}", (10, 50),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)
        cv2.putText(status_bar, f"Labels: {labels_count}", (10, 75),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 1)

        # 수정됨 표시
        if self.modified:
            cv2.putText(status_bar, "[Modified]", (w - 120, 25),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 165, 255), 1)

        # 단축키 안내
        cv2.putText(status_bar, "n:Next  p:Prev  s:Save  d:Delete  h:Help  q:Quit",
                   (w - 450, 75), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (128, 128, 128), 1)

        # 프레임과 상태바 결합
        frame = np.vstack([frame, status_bar])

        # 도움말 오버레이
        if self.show_help:
            self.draw_help(frame)

        return frame

    def draw_help(self, frame):
        """도움말 오버레이"""
        h, w = frame.shape[:2]

        # 반투명 배경
        overlay = frame.copy()
        cv2.rectangle(overlay, (50, 50), (w-50, h-100), (0, 0, 0), -1)
        cv2.addWeighted(overlay, 0.8, frame, 0.2, 0, frame)

        help_text = [
            "=== 바벨 끝단 라벨링 도구 ===",
            "",
            "마우스:",
            "  좌클릭 + 드래그: 바운딩 박스 생성",
            "  좌클릭 (클릭만): 기본 크기 박스 생성",
            "  우클릭: 마지막 라벨 삭제",
            "",
            "키보드:",
            "  n / Space: 다음 이미지 (자동 저장)",
            "  p / Backspace: 이전 이미지",
            "  s: 현재 이미지 저장",
            "  d: 모든 라벨 삭제",
            "  h: 도움말 토글",
            "  q / Esc: 종료",
            "",
            "라벨링 팁:",
            "  - 바벨 플레이트의 옆면(원형)만 라벨링",
            "  - 바벨 막대는 포함하지 않음",
            "  - 바벨이 없는 이미지는 그냥 넘어가기",
            "",
            "아무 키나 눌러 닫기..."
        ]

        y = 80
        for line in help_text:
            cv2.putText(frame, line, (70, y),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.55, (255, 255, 255), 1)
            y += 25

    def next_image(self, save_current=True):
        """다음 이미지로 이동"""
        if save_current and self.modified:
            self.save_labels()

        if self.current_idx < len(self.images) - 1:
            self.current_idx += 1
            self.load_image()
            return True
        return False

    def prev_image(self, save_current=True):
        """이전 이미지로 이동"""
        if save_current and self.modified:
            self.save_labels()

        if self.current_idx > 0:
            self.current_idx -= 1
            self.load_image()
            return True
        return False

    def load_image(self):
        """현재 인덱스의 이미지 로드"""
        img_path = self.images[self.current_idx]
        self.image = cv2.imread(str(img_path))

        if self.image is None:
            print(f"이미지 로드 실패: {img_path}")
            return False

        self.load_labels()
        return True

    def run(self):
        """메인 루프"""
        self.load_image()

        while True:
            frame = self.draw_frame()
            cv2.imshow(self.window_name, frame)

            key = cv2.waitKey(30) & 0xFF

            if self.show_help:
                # 도움말 표시 중 - 아무 키나 누르면 닫기
                if key != 255:
                    self.show_help = False
                continue

            if key == ord('q') or key == 27:  # q or Esc
                if self.modified:
                    self.save_labels()
                break

            elif key == ord('n') or key == 32:  # n or Space
                self.next_image()

            elif key == ord('p') or key == 8:  # p or Backspace
                self.prev_image()

            elif key == ord('s'):  # Save
                self.save_labels()

            elif key == ord('d'):  # Delete all labels
                self.current_labels = []
                self.modified = True

            elif key == ord('h'):  # Help
                self.show_help = True

        cv2.destroyAllWindows()

        # 통계 출력
        labeled_count = 0
        total_labels = 0
        for img in self.images:
            label_path = self.labels_dir / f"{img.stem}.txt"
            if label_path.exists():
                with open(label_path) as f:
                    lines = [l for l in f.readlines() if l.strip()]
                    if lines:
                        labeled_count += 1
                        total_labels += len(lines)

        print(f"\n{'='*50}")
        print("라벨링 완료!")
        print(f"{'='*50}")
        print(f"라벨링된 이미지: {labeled_count}/{len(self.images)}")
        print(f"총 바운딩 박스: {total_labels}")
        print(f"라벨 저장 위치: {self.labels_dir}")
        print(f"{'='*50}\n")


def create_data_yaml(dataset_dir: Path):
    """data.yaml 생성"""
    yaml_content = f"""# Barbell Plate Side Dataset
path: {dataset_dir.absolute()}
train: images
val: images

names:
  0: {CLASS_NAME}

nc: 1
"""
    yaml_path = dataset_dir / "data.yaml"
    with open(yaml_path, "w") as f:
        f.write(yaml_content)
    print(f"data.yaml 생성됨: {yaml_path}")


def main():
    # 기본 경로 또는 인자로 받은 경로
    if len(sys.argv) > 1:
        image_dir = sys.argv[1]
    else:
        # 기본: crawled_data/frames 또는 extracted_frames
        default_dirs = [
            Path(__file__).parent / "crawled_data" / "frames",
            Path(__file__).parent / "extracted_frames",
            Path(__file__).parent / "barbell_plate_dataset" / "train" / "images",
        ]

        image_dir = None
        for d in default_dirs:
            if d.exists() and list(d.glob("*.jpg")):
                image_dir = str(d)
                break

        if image_dir is None:
            print("사용법: python3 label_barbell_endpoints.py [이미지_폴더]")
            print("\n이미지가 있는 폴더를 지정하세요.")
            print("예: python3 label_barbell_endpoints.py ./extracted_frames")
            sys.exit(1)

    labeler = BarbellLabeler(image_dir)
    labeler.run()

    # data.yaml 생성
    create_data_yaml(Path(image_dir).parent)


if __name__ == "__main__":
    main()
