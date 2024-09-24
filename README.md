# VERILOG PRACTICES: Digital Design Projects

## Overview
This project was developed as part of one of my Digital Design courses, focusing on the construction of solid knowledge in SystemVerilog and Digital Design, developing, for instance, some WISHBONE addapted blocks, such as a Wishbone RAM memory compatible. Additionally, it includes work on other structures, such as a Median Filter. The primary goal was to practice using 'SystemVerilog' and applying digital design principles in constructing these elements.

> **Important**: Only certain parts of the project were completed by me. For further details on my contributions, please refer to the **tags** and **commits** in the repository. The majority of the project was implemented by my Télécom Paris instructors **Tarik Graba** and **Yves Mathieu**.

## Project Structure

### wb_bram.sv (Wishbone RAM)
This file implements a **Wishbone RAM** module. The main focus of this file is to construct a memory block using the **Wishbone protocol**, which is adapted for handling multiple independent devices.

#### Key Features:
- **Addressing and Data Handling**: The `wb_bram` module defines the logic for addressing and incrementing addresses, in synthesys, how to work with the memory using the protocol.
- **Acknowledgement and Error Handling**: The file follows Wishbone conventions by providing signals such as `ack`, `err`, and `rty`.
- **Memory Writing and Reading**: The module features a sequential logic block that enables reading and writing to specific memory sections based on the **Wishbone `sel` signal**.

### vga.sv
The **vga.sv** file is responsible for controlling the display on an FPGA screen by fetching pixel data from the memory. It manages both horizontal and vertical synchronizations and processes the RGB signals for the display, profiting from parallelism possible when working with FPGAs.

#### Key Features:
- **VGA Timing and Control**: Horizontal and vertical sync signals are managed to handle the VGA display timings.
- **Wishbone Interface**: The module is connected to a **Wishbone master** interface to retrieve pixel data from the memory.
- **FIFO Buffering**: A FIFO (First In, First Out) mechanism is implemented to handle data flow between the memory and VGA, ensuring smooth video playback.
- **SDRAM Reading**: Data is fetched from an external SDRAM to feed the VGA display, ensuring pixel data is correctly loaded.

## Conclusion
This project demonstrates the integration of various digital design elements such as bus systems, memory modules, and display controllers using **SystemVerilog**. The modular approach allowed for the reuse of standard protocols like **Wishbone**, making the design flexible and scalable.

