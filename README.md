# Network-Traffic-Analysis-with-TCPDump
Network Traffic Analysis with TCPDump - Logging Tool for Cyber Forensics

## 📌 Project Summary

This project simulates a real-world cybersecurity scenario in which suspicious activity on a corporate network must be investigated. Using **TCPDump**, **Bash scripting**, and **Wireshark**, a custom network traffic logging tool is developed to capture, filter, and decrypt suspicious traffic for forensic analysis. 

---

## 🎯 Objectives

By completing this project, I gained hands-on experience in:

- Capturing and analyzing network traffic using **TCPDump**
- Writing **Linux shell scripts** for forensic data collection
- Saving and managing packet capture logs in `.pcap` format
- Decrypting **TLS-encrypted** traffic using session key logging
- Utilizing **Wireshark** to perform in-depth packet analysis

---

## 🧰 Tools & Technologies

| Tool                  | Purpose                                 |
|-----------------------|-----------------------------------------|
| **Ubuntu/Linux OS**   | Scripting & traffic capture             |
| **TCPDump**           | CLI-based packet sniffer                |
| **Wireshark**         | GUI-based packet analysis               |
| **Visual Studio Code**| Script writing and editing              |
| **Kali Linux VM**     | Virtual environment for testing         |

---

## 🔐 Scenario

> _"As a network administrator for an accounting firm, I was tasked with identifying whether certain workstations had been compromised. I developed a background script to monitor, filter, and save suspicious network traffic for further investigation."_  

---

## 🧱 Project Structure

```bash
.
├── watchdog.sh              # Bash script to capture and log network traffic
├── capture.pcap             # Sample capture file (binary)
├── sslkeys.log              # Session keys for decryption (if applicable)
├── decrypted_capture.txt    # Optional: readable output of capture.pcap
├── key_extraction.sh        # TSL Keys Capture
├── README.md                # Project documentation
```

## 🚀 How It Works

🔹 Step 0 - Project Setup & Environment Configuration

- Download and configure a Linux VM (I have used Kali Linux for this project - https://www.kali.org/get-kali/ )

- Navigate to system folders (e.g., /bin) and prepare the terminal environment for scripting with Bash.

🔹 Step 1 – Discover Interfaces

1.1) List all available interfaces:

```bash

tcpdump -D
```

![001](https://github.com/user-attachments/assets/5fbd6454-29f2-41e6-b769-86f463dfdd20)

🔹 Step 2 – Filter Traffic

2.1) Capture packets based on specific filters:

- Host-specific: tcpdump host 10.0.2.15

- Source/Destination: src, dst, port (e.g., port 443)

- Combine filters using logical operators like "and".

![002](https://github.com/user-attachments/assets/411ac5d6-e5a3-471c-a72d-ba27facf9913)

2.2) Limit the packet count to a specific number:

- using the command -c followed by the number (in this case 10) to limit the packet capture to the specific number

![1_Basic commands](https://github.com/user-attachments/assets/46781bef-68bf-4214-ab9c-cb0cb2d95a19)

Examples:

```bash

tcpdump host google.com
tcpdump src 192.168.1.10
tcpdump dst port 443
tcpdump src 10.0.0.5 and dst port 80
```

🔹 Step 3 – Develop the Logging Tool Script and Make It Executable

3.1) Write a script .sh file (using VScode / VSCodium [Linux] / or equivalent): in this case I named the file "watchdog.sh" , and give executable permissions to the user to run the script:

```#!/bin/bash

sudo tcpdump -c 10 host coursera.org
```

3.2) intially check if the file is executable (x) via the following command in the directory:

``` ls -al ```

![004](https://github.com/user-attachments/assets/313eaf9c-9aa9-4b15-9934-e33b6b22fd33)

❌ if NOT, use the following command to make it Executable (x)
```
chmod +x watchdog.sh
/or/
chmod 777 watchdog.sh (allowing all the users to have r-read / w-write / x-execute permissions) 
```
![005](https://github.com/user-attachments/assets/4ff11f0f-d438-4e40-a0ca-0d92d78b8343)

🔹 Step 4 - Capture and Save Packets to a Dump File

4.1) Enhance the script to write packets to a .pcap file (capture.pcap) using the -w flag (on VSCode / VSCodium):
```
#!/bin/bash 

sudo tcpdump -c 10 host coursera.org -w capture.pcap
```

![3_command to create the a file with the capture packets](https://github.com/user-attachments/assets/4ccbeba9-e0a0-429c-82f7-c7e12b9cb3d2)

4.2) Read the saved packet data:
```
bash

tcpdump -r capture.pcap
```

4.3) Use Wireshark to visually analyze the binary .pcap files, including encrypted application data (TLS layer).

🔹 Step 5 – Automate Sequenced Capture with Size and Time Limits

5.1) To manage large files and extended captures:
- Limit the file size: -C 1 (each file is limited to ~ 1MB)
- Set time-based intervals: -G 15 (creates a new file every 15 seconds)


_Example_
``` 
bash

tcpdump -i eth0 -G 15 -C 1 -w capture.pcap
```
* This captures packets in 15-second intervals or 1MB file size—whichever occurs first.

The flags can be used in tandem by simply writing them in the same line (_example below_):

![006](https://github.com/user-attachments/assets/9d5f4f19-08df-4288-bbe7-8ca713e22f67)

🔹 Step 6 – Decrypt and Analyze Encrypted Traffic

Introducing concepts of SSL/TLS and asymmetric encryption (public/private keys):

"TLS or Transport Layer Socket is an updated version of SSL or Secure Socket Layer, and is basically a security protocol that encrypts communications between a client (like a web browser) and a server (like a website). This ensures that data transmitted over the internet, such as passwords or credit card details, is protected and cannot be intercepted by third parties. These protocols are what make HTTPS (HyperText Transfer Protocol Secured) work - securing browsing on the web. 
Each partecipant (client and server) will have a SET OF 2 KEYS, a PRIVATE KEY (secret, known only to the owner) and a PUBLIC KEY (which derives from the Private Key, shared openly): think of the Public Key as the address of the post box, and the Private Key like the actual key possessed by the owner to open it.
The Public Keys are exchanges in a process called **HANDSHAKING**, which requires:
- the CLIENT and SERVER exchanging Public Keys at the start of the session;
- Each uses the OTHER'S PUBLIC KEY to encrypt the data it sends;
- ONLY the intended recipient can decrypt the data using their PRIVATE KEY.
This exchange of keys makes it an extremely secure communication as the information sent is encrypted and therefore unreadable to the interceptor, if he doesn't possess the Private Key to decrypt the data.

It is important to introduce the topic of ENVIRONMENTAL VARIABLES, as it will be centric to the next steps.
ENVIRONMENATL VARIABLES are piece of information stored by your operating system that programs can read to know things like:
- Where to find files
- What language to use
- How to run certain features

In this specific case we set a particula environmental variable, called "SSLKEYLOGFILE", will tell the Browser:
_"Hey! When you run, save the encryption keys in this file."_

Simnce MODERN BROWSERS - like CHROME and FIREFOX - include a **debugging feature** that, when SSLKEYLOGFILE environmental variable is set, it will log the session keys used during SSL/TLS connections to a file, which we can then use to decrypt the data sent via the TLS protocol.

Remember: **it only works on your system**!. In other words, it **only works if YOU control the browser and the system** , otherwise it normally **DOES NOT EXPOSE THE KEYS REMOTELY.**

**For this instance, we are using a website called apod.nasa.gov (Astronomy Picture of the Day - https://apod.nasa.gov/apod// ):**

6.1) Captured session keys using environmental variable:
```
bash

export SSLKEYLOGFILE=~/sslkeys.log
```
![010](https://github.com/user-attachments/assets/17b495cc-7763-4a6e-968b-d01bc03adcf9)

6.2) Configure Wireshark:
- Navigate to Edit > Preferences > Protocols > TLS > (Pre)-Master-Secret log filename (sslkeys.log)

This allows Wireshark to decrypt TLS-encrypted traffic (HTTPS, for example).

![011](https://github.com/user-attachments/assets/d004f65e-3e1f-4b70-ad06-5e742871e81a)

--------------------------

## 📦 Key TCPDump Options
Option	Description
-i	Specify network interface
-D	List all available interfaces
-w file.pcap	Write captured packets to a file
-r file.pcap	Read packets from a .pcap file
-C	Set max file size (MB)
-G	Rotate capture every N seconds
host / src/ dst / port	Filter packet sources and destinations

## 🧪 Sample Use Case
```
bash

tcpdump -i eth0 src 192.168.1.10 and port 443 -w suspicious.pcap
```
Captures HTTPS traffic from a specific source IP for further investigation.


## 🔍 Analysis with Wireshark
Once .pcap files are captured, they can be opened in Wireshark to inspect:

- Protocol types (TLS, HTTP, DNS, etc.)

- Session initiation and termination

- Application-layer data

- Decrypted content (if SSLKEYLOGFILE is set)

--------------------------------------
## 📘 Learning Highlights
✅ Built a real-time logging solution
✅ Mastered key tcpdump filtering commands
✅ Created rotating .pcap capture files with size/time limits
✅ Decrypted TLS traffic using session keys
✅ Gained forensic insights from packet-level traffic


## Conclusion
This project simulates a real-world SOC analyst task involving incident detection and traffic forensics. It showcases my practical experience with Linux systems, cybersecurity tools, network protocols, and secure data handling. The scripting component further highlights my automation capabilities for continuous monitoring and response readiness.

## 📎 License
This project is licensed for educational and demonstration purposes.

## 🤝 Contacts
Michele Filandro
Aspiring SOC Analyst
📧 cyberatlas.protect@gmail.com  
🔗 https://www.linkedin.com/in/michele-filandro-a8302a224/

