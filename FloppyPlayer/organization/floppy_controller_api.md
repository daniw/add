Schnittstellenbeschreibung Floppy Controller
============================================

| Address   | Register          |
|:----------|:------------------|
| 0x82      | ON/OFF            |
| 0x83      | Mode              |
| 0x84      | Status init       |
| 0x85      | Status melody     |
| 0x86      | Pitch Module 0    |
| 0x87      | Pitch Module 1    |
| ...       | ...               |

| Register      | 0             | 1             |
|:----------    |:--------------|:--------------|
| ON/OFF        | Module off    | Module on     |
| Mode          | Fix frequency | Melody        |
| Status init   | ready         | initializing  |
| Status melody | ready         | playing       |