# Ultrasonic Parking Sensor ASIC

## 📌 Overview
This repository contains the design and physical realization of the control logic for an ultrasonic parking sensor system as an Application-Specific Integrated Circuit (ASIC). The architecture is designed using Verilog HDL to control the generation of precise triggers and the measurement of echo-pulses for real-time distance calculation. The design was synthesized and implemented with OpenLane 2, an open-source RTL-to-GDSII design flow, targeting the SkyWater 130nm technology node. This hardware controller offers a highly predictable, low delay, and ultra-low power alternative to traditional software-based microcontroller solutions.

## 🏗️ System Architecture
The system is designed to integrate with an HC-SR04 ultrasonic transducer, featuring a high-resolution digital core operating at a 20 MHz frequency (50ns period). The architecture is divided into three major data-path modules, all coordinated by a central Finite State Machine (FSM):

*   **Finite State Machine (FSM) Controller:** A five-state flow (IDLE, TRIG, WAIT, MEASURE, ANALYZE) that manages the operational cycle, from waiting for external start triggers to evaluating distance safety thresholds.
*   **Trigger Generator:** Uses a 10-bit counter to hold the trigger pulse high for exactly 200 cycles, generating a precise 10µs logic high pulse without software overhead.
*   **Echo Counter and Distance Calculation:** Utilizes a 16-bit counter that counts up on each clock cycle while receiving an physical echo. 
*   **Magnitude Comparator:** The final echo count is fed into a comparator circuit that strictly checks if the measured distance is between zero and two hundred counts. If these conditions fail, the logic triggers an `alarm_active` signal.

## ⚙️ Tools & Physical Design Methodology
The transition from verified Verilog RTL to a manufacturable layout was achieved using the automated OpenLane 2 flow.

*   **Logic Synthesis:** Yosys was utilized to synthesize the RTL into a gate-level netlist based on the SkyWater standard cell library.
*   **Floorplanning & Placement:** OpenROAD handled the initialization of the die area and optimized the placement of standard cells to minimize wire length.
*   **Routing & Signoff:** Global and detailed routing was completed, followed by Design Rule Checking (DRC) and Layout Versus Schematic (LVS) verification using Magic and Netgen.
*   **Functional Verification:** Icarus Verilog and GTKWave were used to confirm functional correctness, ensuring the 10µs trigger pulse and safety alarm activation operated as intended.

## 📊 Physical Design Metrics
The final post-layout implementation yielded a highly optimized and extremely compact die footprint.

| Parameter | Value | Unit | 
| :--- | :--- | :--- | 
| **Technology Node** | SkyWater 130nm | - | 
| **Operating Frequency** | 20 | MHz | 
| **Die Area** | 0.006591 | mm² | 
| **Total Power** | 66.7 | µW | 
| **Cell Count** | 246 | Cells | 
| **Sequential Elements** | 31 | Flops | 
| **Clock Tree** | 8 | Cells | 
| **DRC/LVS** | CLEAN | - | 

*(Note: Data extracted from Post-Layout results.)*
