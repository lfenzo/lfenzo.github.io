+++
title = 'Multimodal Langchain Summarization App'
date = 2024-09-15
type = 'docs'
+++


## Introduction


## Input Formats


```bash
$ curl -X POST "http://0.0.0.0:8000/summarize"
    \ -F "file=@file.pdf;type=application/octet-stream"
    \ --no-buffer
```


## Architecture

```mermaid
flowchart LR

subgraph Model["Model Service (GPU)"]
    direction LR
    O["Ollama Server"]
end

O <--> R

subgraph Cache["Cache Service"]
    direction LR
    R["Redis"]
end
    
subgraph S["Summarization Service"]
    H["Langchain"]
    Loader
end

subgraph D["Storage Service"]
    direction LR
    MongoDB
end

FastAPI --> H
H ---> MongoDB
H ---> O
H <--> Loader
```

### Componentes and Containers

### Execution Flow

```mermaid
sequenceDiagram
    autonumber
    FastAPI ->> Service: File bytes<br>(POST Request)
    Service ->> Loader: File path
    Loader ->> Runnable: Langchain<br>Documents
    Runnable ->> Runnable: Cache Access
    Runnable ->> Service: Summary
    Service -->> FastAPI: Stream/Batch<br>Response
    Service ->> Storage: File Bytes + Summary and Metadata
```


## Streaming & Batching

