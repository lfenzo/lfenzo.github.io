+++
title = 'Video Summarization POC'
description = ''
date = 2024-09-15
type = 'docs'
+++

## Video Summarization POC

[poc-video-summarization](https://github.com/lfenzo/poc-video-summarization)

This project presents a proof-of-concept application designed to automatically summarize videos through a combination of audio extraction, speech recognition, and text summarization. By utilizing OpenAI’s Whisper for speech-to-text and the Gemma 2 27B model for summarization, the application efficiently generates concise summaries of video content, making it ideal for a range of video types and lengths.

### Process Overview

The workflow starts with extracting audio from videos using tools like `pytube` and `pydub`. Once the audio is processed, OpenAI’s Whisper is employed to perform speech recognition, converting the audio into text. This transcription is then passed to the Gemma 2 27B model for summarization, producing concise and accurate summaries tailored to different video formats, whether short clips or extended recordings.

### Installation and Usage

To get started, clone the repository and run the setup script. Summarizing a video involves providing the YouTube URL and, optionally, specifying output parameters like model size, the number of GPU layers to offload, and the context length for tuning performance based on your hardware.

```bash
python summarize.py <URL> -o my_summary.txt
```

### Key Features

- **Video Categories:** Summaries are optimized for short, medium, and long videos, each with unique handling approaches.
- **Customizable Models:** Users can adjust Whisper’s model size, GPU layer offloading, and context length to match their hardware capabilities.
- **Scalability:** Both CPU and GPU execution are supported, with VRAM requirements and performance tuned for different hardware setups.

### Technology Stack

- **Audio Extraction:** `pytube`, `pydub`
- **Speech Recognition:** OpenAI Whisper
- **Text Summarization:** Gemma 2 27B

### Future Directions

Opportunities for future improvements include video segmentation, customization options for summary length, and developing a user-friendly interface. This proof of concept opens doors for more advanced implementations in video summarization.

```mermaid
graph LR
    Z[URL] --> A
    A["Extract Audio<br>(pytube)"] --> B["Transcribe Audio<br>(OpenAI Whisper)"]
    B --> C["Summarize Text<br>(Gemma 2 27B)"]
	C --> D[Summary]
```
