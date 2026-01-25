#!/usr/bin/env python3
"""
New Barbell Video Crawler - Avoids duplicates
Downloads high-quality barbell exercise videos and extracts frames.
Tracks downloaded video IDs to never download the same video twice.
"""

import subprocess
import random
from pathlib import Path
import cv2
import json
from datetime import datetime

# Directories
TRAINING_DIR = Path(__file__).parent
OUTPUT_DIR = TRAINING_DIR / 'crawled_new'
VIDEOS_DIR = OUTPUT_DIR / 'videos'
FRAMES_DIR = OUTPUT_DIR / 'frames'
DOWNLOADED_IDS_FILE = TRAINING_DIR / 'downloaded_video_ids.txt'

# Output directory for labeling
LABELING_IMAGES_DIR = TRAINING_DIR / 'labeling_images'

def load_downloaded_ids():
    """Load previously downloaded video IDs."""
    ids = set()
    if DOWNLOADED_IDS_FILE.exists():
        with open(DOWNLOADED_IDS_FILE) as f:
            for line in f:
                vid = line.strip()
                if vid:
                    ids.add(vid)
    return ids

def save_downloaded_id(video_id):
    """Append a new video ID to the downloaded list."""
    with open(DOWNLOADED_IDS_FILE, 'a') as f:
        f.write(video_id + '\n')

def get_video_id_from_url(url):
    """Extract video ID from YouTube URL."""
    import re
    patterns = [
        r'(?:v=|/)([0-9A-Za-z_-]{11}).*',
        r'(?:embed/)([0-9A-Za-z_-]{11})',
        r'(?:shorts/)([0-9A-Za-z_-]{11})',
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return None

def search_youtube(query, max_results=30):
    """Search YouTube and return video URLs, filtering out duplicates."""
    downloaded_ids = load_downloaded_ids()

    # Use yt-dlp to search
    cmd = [
        'yt-dlp',
        f'ytsearch{max_results}:{query}',
        '--get-id',
        '--no-warnings',
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    video_ids = [vid.strip() for vid in result.stdout.strip().split('\n') if vid.strip()]

    # Filter out already downloaded
    new_ids = [vid for vid in video_ids if vid not in downloaded_ids]
    print(f"  Found {len(video_ids)} videos, {len(new_ids)} are new")

    return new_ids

def download_video(video_id, prefix=''):
    """Download a single video in high quality."""
    url = f'https://www.youtube.com/watch?v={video_id}'
    output_template = str(VIDEOS_DIR / f'{prefix}%(title).30s_%(id)s.%(ext)s')

    cmd = [
        'yt-dlp',
        '-f', 'bestvideo[height>=720][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height>=720]+bestaudio/best[height>=720]/best',
        '--merge-output-format', 'mp4',
        '-o', output_template,
        '--no-playlist',
        '--max-filesize', '200M',
        url
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        if result.returncode == 0:
            # Find the downloaded file
            for f in VIDEOS_DIR.glob(f'*{video_id}*'):
                return f
    except subprocess.TimeoutExpired:
        print(f"    Timeout downloading {video_id}")
    except Exception as e:
        print(f"    Error: {e}")

    return None

def extract_frames(video_path, output_prefix, fps=2, max_frames=150):
    """Extract frames from video."""
    cap = cv2.VideoCapture(str(video_path))
    if not cap.isOpened():
        return 0

    video_fps = cap.get(cv2.CAP_PROP_FPS)
    frame_interval = max(1, int(video_fps / fps))

    frame_count = 0
    saved_count = 0

    while saved_count < max_frames:
        ret, frame = cap.read()
        if not ret:
            break

        if frame_count % frame_interval == 0:
            # Resize to 1280px width maintaining aspect ratio
            h, w = frame.shape[:2]
            if w > 1280:
                new_w = 1280
                new_h = int(h * 1280 / w)
                frame = cv2.resize(frame, (new_w, new_h))

            output_path = FRAMES_DIR / f'{output_prefix}_{saved_count:04d}.jpg'
            cv2.imwrite(str(output_path), frame, [cv2.IMWRITE_JPEG_QUALITY, 90])
            saved_count += 1

        frame_count += 1

    cap.release()
    return saved_count

def copy_frames_to_labeling():
    """Copy extracted frames to labeling directory."""
    count = 0
    for frame in FRAMES_DIR.glob('*.jpg'):
        dest = LABELING_IMAGES_DIR / frame.name
        if not dest.exists():
            import shutil
            shutil.copy(frame, dest)
            count += 1
    return count

def main():
    # Create directories
    VIDEOS_DIR.mkdir(parents=True, exist_ok=True)
    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    LABELING_IMAGES_DIR.mkdir(parents=True, exist_ok=True)

    # Search queries - various barbell exercises from side view
    queries = [
        # Squat variations with side view
        'powerlifting squat side view slow motion',
        'barbell squat form check side angle',
        'squat bar path analysis',
        'IPF squat competition side camera',
        'olympic weightlifting squat side view',

        # Deadlift variations
        'deadlift bar path side view',
        'conventional deadlift form side angle',
        'sumo deadlift technique side view',
        'powerlifting deadlift competition',

        # Bench press
        'bench press side view form',
        'bench press bar path analysis',
        'powerlifting bench press side angle',
        'paused bench press technique',

        # Olympic lifts
        'clean and jerk side view slow motion',
        'snatch side angle analysis',
        'olympic weightlifting side camera',

        # Misc
        'barbell overhead press side view',
        'barbell row side angle',
        'pendlay row form check',

        # Training footage
        '바벨 스쿼트 측면',
        '데드리프트 측면 촬영',
        '벤치프레스 측면',
        'パワーリフティング 横から',
    ]

    # Shuffle queries
    random.shuffle(queries)

    downloaded_ids = load_downloaded_ids()
    print(f"Already downloaded: {len(downloaded_ids)} videos")

    total_frames = 0
    videos_downloaded = 0
    max_videos = 30  # Target number of new videos

    for query in queries:
        if videos_downloaded >= max_videos:
            break

        print(f"\nSearching: {query}")
        new_ids = search_youtube(query, max_results=15)

        for video_id in new_ids[:5]:  # Max 5 per query
            if videos_downloaded >= max_videos:
                break

            if video_id in downloaded_ids:
                continue

            print(f"  Downloading {video_id}...")
            video_path = download_video(video_id)

            if video_path:
                videos_downloaded += 1
                save_downloaded_id(video_id)
                downloaded_ids.add(video_id)

                # Extract frames
                prefix = f'new_{video_id}'
                frames = extract_frames(video_path, prefix)
                total_frames += frames
                print(f"    Extracted {frames} frames")

                # Delete video after extraction to save space
                video_path.unlink()
            else:
                print(f"    Failed to download")

    # Copy frames to labeling directory
    print(f"\nCopying frames to labeling directory...")
    copied = copy_frames_to_labeling()

    print(f"\n=== Summary ===")
    print(f"Videos downloaded: {videos_downloaded}")
    print(f"Total frames extracted: {total_frames}")
    print(f"Frames copied to labeling: {copied}")
    print(f"Total downloaded videos: {len(load_downloaded_ids())}")

if __name__ == '__main__':
    main()
