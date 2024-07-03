# 單晶片控制期末專題
ppt展示影片請看youtube

影片連結：https://youtu.be/FJRL8JyAs-c

## 說明
題目：磁感測器

使用霍爾(Hall) Sensor搭配8051電路  
使用Keil C以組合語言產生hex file再燒進8051做控制  

<br>

### 線路圖
![image](https://github.com/deng41075010h/EE/blob/main/SingleChip%20Control/%E7%B7%9A%E8%B7%AF%E5%9C%96.png)

### 功能-1 (KY-024)  
感測附近磁場變化，經ADC轉換電壓訊號，傳至8051  
由8051控制在七段顯示器顯示0~255的數，表現磁場強弱 (無外加磁場時，基準值為100)

### 功能-2 (KY-003)
利用KY-003模擬開關  
以external interrupt的方式顯示  
啟動interrupt時，在七段顯示器顯示OFF  
接在P3.2為INT0，interrupt priority最高  

### 功能-3 (button)  
以external interrupt的方式顯示 
啟動interrupt時，讓七段顯示器暫停在即時的磁感測值  
顯示 StOP  -> 磁感測值 -> 全滅 -> 結束中斷  
接在P3.3為 INT1，interrupt priority 比較低  

<br>

### 程式碼
(見附件)

