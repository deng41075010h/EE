# System of Chip Lab Project

彩色電子紙之影像處理晶片設計之論文重現(進行中)

## 說明

reference: 陳昕陽, "彩色電子紙之色彩量測與影像處理晶片設計", 國立臺灣師範大學電機工程學系, 2021.

關鍵字：彩色電子紙、影像處理演算法、晶片設計

摘要： 透過重現學長的論文，更加了解於彩色電子紙上的影像處理流程與演算法，學習色彩學、影像處理等相關知識，並練習實作與熟悉晶片架構設計。

### 流程

![img](https://github.com/deng41075010h/EE/blob/main/Lab/process.png)

1. Color Enhancement  
   以輸入的Lab資料，對a, b分別乘1.5做色彩增強
   
2. Lab to sRGB
   色彩空間轉換
   
3. Error Diffusion (誤差擴散)  
   半色調演算法(HalfTone)之一
   
   ![img](https://github.com/deng41075010h/EE/blob/main/Lab/Floyd-Steinberg.png)
   
5. CFA mapping  
   符合彩色電子紙的排列

<br>
已完成軟體演算法架構驗證實作，正在進行硬體模擬

### 程式碼
[軟體演算法架構驗證](https://github.com/deng41075010h/EE/blob/main/Lab/C%2B%2B%20code/main.cpp)  
檔案路徑： C++ code -> main.cpp  
 


