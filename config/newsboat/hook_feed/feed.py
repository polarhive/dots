#!/home/polarhive/.local/share/newsboat/hook_feed/.venv/bin/python
# -*- coding: utf-8 -*-
import os
import subprocess
import yt_dlp
import re

video_url = subprocess.check_output(["wl-paste"], text=True).strip()
youtube_regex = r"^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.*$"

if re.match(youtube_regex, video_url):
    ydl_opts = {"quiet": True, "skip_download": True, "extract_flat": True}

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(video_url, download=False)
        channel_id = info.get("channel_id")
        if channel_id:
            newsboat_dir = os.path.expanduser("~/.config/newsboat");
            urls_file = os.path.join(newsboat_dir, "urls")
            with open(urls_file, "a") as f: f.write(f"https://www.youtube.com/feeds/videos.xml?channel_id={channel_id}\n")
            subprocess.run(["notify-send", "Newsboat", f"RSS feed added for channel: {channel_id}"])
else:
    print("The URL is not a valid YouTube video URL.")
