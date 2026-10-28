\#AEGIS

Acquisition Engine with Guarded Intelligent Switching



Hệ thống SoC thu thập dữ liệu và điều khiển vòng kín có bảo vệ phần cứng



Thành phần chính:

* aegis\_daq\_ctrl: IP tự thiết kế gồm SPI ADC (LTC2308), Averager, FIFO, PWM Generator, Threshold Comparator, Fail-safe, Event Logger
* Nios II: firmware điều khiển PI, xử lý ngắt, giao tiếp OLED (I2C) và PC
* PC App: ứng dụng Python giám sát và điều khiển



Cấu trúc thư mục

|Thư mục|Nội dung|
|-|-|
|docs/|Tài liệu, register map, sơ đồ|
|hw/ip/aegis\_daq\_ctrl/rtl/|Code Verilog của IP|
|hw/ip/aegis\_daq\_ctrl/sim/|Testbench, script ModelSim|
|hw/quartus/|Project Quartus, Platform Designer|
|sw/app/|Firmware Nios II|
|pc\_app/|Ứng dụng PC|



Yêu cầu kỹ thuật:

* Không push trực tiếp lên main, mọi phần việc làm trên nhánh 'feature/...'
* File '.qsys' và '.qsf' chỉ người phụ trách tích hợp được sửa
* Luôn 'git pull' trước khi bắt đầu làm

