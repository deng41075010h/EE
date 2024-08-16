# 數位系統實驗期末專題
影片連結：https://youtu.be/vaYfaANIu_M

## 說明
題目：Easy Games

軟體工具：Quartus  
硬體：Altera DE10-Lite  
使用 Verilog 實現 FPGA 設計

包含兩個小遊戲，透過switch切換遊戲  
Game 1 - SLOT MACHINE  
Game 2 - Guess who's bigger
<br>

### Game 1 - SLOT MACHINE
六個七段顯示器輪轉0~9  
分別有六個switch控制七段顯示器停止
嘗試讓六個數字都停在相同的數字  
如果都相同，七段顯示器將顯示"ㄷ ㅐ/ ㅂ ㅏ ㄱ"(為很棒的韓文)  
反之，則顯示"ㅋㅋㅋㅋㅋㅋ"(為笑的韓文)  

### Game 2 - Guess who's bigger
有兩個玩家，七段顯示器左三顆為1P，右三顆為2P  
數字為三位數，每一位數從0~9依不同速度輪轉  
個位數字輪轉最慢，百位數字輪轉最快  
按壓下方按鈕以開始遊戲  
按壓第二次停止個位數，依序第三次停止十位而第四次停止百位  
以此類推2P，直到按完最後一個數字，七段顯示器會閃爍三次表示選擇完畢  
最後比較兩位玩家的數字，較大者為贏家，並在七段顯示器顯示贏家為1P或2P  
上方的按鈕為reset可重置遊戲  

![image](https://github.com/deng41075010h/EE/blob/main/Digital%20System%20Lab/image.png)  

### 程式碼
見[附件](https://github.com/deng41075010h/EE/blob/main/Digital%20System%20Lab/project/project.v)  
檔案路徑：project/project.v
