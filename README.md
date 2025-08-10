# Motion-Compensation — MATLAB Video Encoding Mini Project

## Description
This project implements **motion estimation** and **motion compensation** techniques in MATLAB to reduce inter-frame motion in videos and improve visual stability.  
The workflow reads a video sequence, estimates motion vectors between consecutive frames, and applies compensation to align frames.  
Performance is evaluated in terms of **time taken to perform motion compensation** and **Root Mean Square Error (RMSE)**.

---

## How Motion Compensation Works in This Project
1. **Frame Extraction**  
   - The input video is read frame-by-frame using MATLAB’s VideoReader.  
   - Each frame is converted to grayscale for faster processing.

2. **Motion Estimation**  
   - Uses a block-matching approach to estimate motion vectors between current and reference frames.
   - Supports two search algorithms:
     - **Exhaustive Search** — Tests all possible block positions within the search range (highest accuracy, slower).
     - **Logarithmic Search** — Reduces the number of candidate positions tested (faster, slightly less accurate).

3. **Motion Compensation**  
   - Motion vectors are applied to shift image blocks, aligning them with their predicted position in the reference frame.
   - Compensated frames are reconstructed for output.

4. **Performance Evaluation**  
   - `mc_performance.m` measures:
     - **Processing Time** — total time taken for motion estimation and compensation.
     - **RMSE** — measures the difference between compensated frames and the reference.

---

## Parameters Affecting Performance

| Parameter        | Effect on Time Taken | Effect on RMSE |
|------------------|----------------------|----------------|
| **Block Size**   | Smaller blocks → more computations per frame. Larger blocks → faster but less flexible. | Smaller blocks → lower RMSE (captures fine motion). Larger blocks → higher RMSE (misses small details). |
| **Search Range** | Larger range → more candidate positions to test (slower). Smaller range → faster. | Larger range → better chance to find correct match (lower RMSE). Smaller range → may miss motion (higher RMSE). |
| **Search Algorithm** | Exhaustive → slowest due to testing all candidates. Logarithmic → faster by reducing search steps. | Exhaustive → most accurate (lowest RMSE). Logarithmic → slightly higher RMSE depending on motion complexity. |

---

## Repository Structure

📂 data/           # Output data
📂 result/         # Processed outputs and visualizations  
📜 main.m          # Main execution script  
📜 mc_performance.m # Performance evaluation script  
📜 Motion Compensation.pdf # Technical documentation/report  
🎥 hotairballoon_2160_3840_30fps.mp4 # Sample video for testing  

---

## Result (3D Plot)
![linear_search_result](https://github.com/user-attachments/assets/76bb6810-54bc-4ba1-896b-2486bc16fff7)
![logarithmic_search_result_new](https://github.com/user-attachments/assets/80c79f7c-7d8b-4421-a1d8-ac84757219a0)


