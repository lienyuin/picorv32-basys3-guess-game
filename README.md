# PicoRV32 Basys 3 Guessing Game

基於 PicoRV32 RISC-V 與 Memory-Mapped I/O 的 FPGA 隨機猜數字遊戲。

## 功能

- `SW[3:0]`：輸入 0～15 的猜測值
- `BTN_LEFT`：提交答案
- `BTN_RIGHT`：清除目前 LED 結果
- `BTN_CENTER`：產生新的偽隨機答案並清除結果
- `LED0`：猜中
- `LED1`：猜測值太小
- `LED2`：猜測值太大
- 七段顯示器：顯示目前 Switch 輸入的 0～F

## 開發環境

- 開發板：Digilent Basys 3
- FPGA：Xilinx Artix-7 `xc7a35tcpg236-1`
- Vivado：2024.2（原專案使用版本）
- CPU：PicoRV32（RV32I 設定）

## 專案結構

```text
rtl/
├── top.v              # 最上層整合與位址解碼
├── io.v               # Memory-Mapped I/O、按鈕同步、偽隨機答案
├── simple_ram.v       # RISC-V 程式 ROM（機器碼）
└── seven_seg.v        # 七段顯示器解碼

third_party/picorv32/
├── picorv32.v         # 開源 PicoRV32 CPU core
└── COPYING            # PicoRV32 ISC License

constraints/
└── Basys3.xdc         # Basys 3 腳位約束

firmware/
├── guess_game.S       # 可讀的 RV32I 組合語言說明
└── main.c             # 等效 C 語言流程

vivado/
└── create_project.tcl # 自動建立 Vivado 專案

bitstream/
└── top.bit            # 原專案產生的可燒錄 Bitstream
```

## Memory Map

| 位址 | 功能 | 存取方式 |
|---|---|---|
| `0x03000000` | LED 結果暫存器 | 寫入 |
| `0x03000004` | Switch 輸入 | 讀取 |
| `0x03000008` | BTN_LEFT | 讀取 |
| `0x0300000C` | BTN_RIGHT | 讀取 |
| `0x03000010` | 偽隨機目標值 | 讀取 |

## 建立 Vivado 專案

### 方法一：使用 Tcl 腳本

1. 開啟 Vivado Tcl Shell。
2. 切換到本 Repository 根目錄。
3. 執行：

```tcl
source vivado/create_project.tcl
```

專案會建立在 `build/vivado/`。

### 方法二：手動建立

1. 建立 RTL Project，Part 選擇 `xc7a35tcpg236-1`。
2. 將 `rtl/*.v` 與 `third_party/picorv32/picorv32.v` 加入 Design Sources。
3. 將 `constraints/Basys3.xdc` 加入 Constraints。
4. 將 `top` 設為 Top Module。
5. 執行 Synthesis、Implementation、Generate Bitstream。

## 操作方式

1. 燒錄 Bitstream 後，按 `BTN_CENTER` 產生新答案。
2. 使用 `SW[3:0]` 輸入數字，七段顯示器會顯示目前值。
3. 按 `BTN_LEFT` 提交。
4. 根據 LED 判斷：
   - LED0：猜中
   - LED1：太小
   - LED2：太大
5. `BTN_RIGHT` 清除結果；`BTN_CENTER` 開始新一局。

## RISC-V 程式

實際執行的 RV32I 機器碼存放在 `rtl/simple_ram.v`。`firmware/guess_game.S`
與 `firmware/main.c` 提供相同遊戲流程的可讀版本，方便理解與報告說明。

## 已知限制

- 使用 polling，未實作 interrupt。
- 隨機答案由高速自由運行計數器產生，屬於偽隨機數。
- 七段顯示器目前只使用最右邊一位。
- 按鈕有兩級同步，但未加入完整的機械彈跳消除電路。

## 外部來源

- PicoRV32：https://github.com/YosysHQ/picorv32
- PicoRV32 授權：ISC License
- Basys 3 腳位參考：Digilent Basys 3 Master XDC
