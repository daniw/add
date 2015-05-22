Schnittstellenbeschreibung Floppy Controller
============================================

| Address   | Register          | R/W   |
|:----------|:------------------|:------|
| 0x80      | Switch            | R     |
| 0x81      | LED               | R/W   |
| 0x82      | Enable            | R/W   |
| 0x83      | Mode              | R/W   |
| 0x84      | Status init       | R     |
| 0x85      | Status melody     | R     |
| 0x86      | Pitch Module 0    | R/W   |
| 0x87      | Pitch Module 1    | R/W   |
| ...       | ...               | ...   |

| Register      | 0             | 1             |
|:--------------|:--------------|:--------------|
| Switch        | OFF / released| ON / pressed  |
| LED           | OFF           | ON            |
| Enable        | Module off    | Module on     |
| Mode          | Fix frequency | Melody        |
| Status init   | ready         | initializing  |
| Status melody | ready         | playing       |
