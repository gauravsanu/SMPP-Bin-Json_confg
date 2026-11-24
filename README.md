# SMPP-Bin-Json_confg

Java 17 file-driven SMPP client with multiple accounts/connections and a separate local SMSC simulator.

## Requirements
- Java 17+ (`java -version`)
- Maven 3.8+ (`mvn -version`) for building the SMPP client
- Windows CMD or PowerShell

Client dependencies: Cloudhopper SMPP 5.0.9 (`com.fizzed:ch-smpp`) and Jackson 2.17.2. Maven downloads dependencies on first client build. The local simulator is already included as `simulator/smsc-simulator.jar` and has no external runtime dependencies.

## Folder layout
```
SMPP-Bin-Json_confg/
  config/json_config.json
  sms_request/       # input sms<number>.json files
  sms_processing/   # claimed while processing
  sms_sent/          # submit_sm response archives
  sms_failed/        # local processing errors
  logs/
  simulator/smsc-simulator.jar
  src/main/java/     # client + simulator source
  start-smsc-simulator.bat
  start-smpp.bat
```

Each processed SMS is archived in its own directory:
```
sms_sent/sms1_yyyyMMdd_HHmmss_SSS/
  original_request.json
  submit_sm_response.json
  result.json
```
A valid SMPP response is stored under `sms_sent`, including a non-zero SMPP status (response JSON says `success:false`). Local processing errors go to `sms_failed`.

## 1. Start the local SMSC simulator
Open CMD in the project directory:
```
start-smsc-simulator.bat
```
Defaults: host `127.0.0.1`, port `2775`, system_id `test`, password `test`. It accepts SMPP bind transmitter/receiver/transceiver and submit_sm, returning ESME_ROK plus a synthetic message_id. It is a protocol test stub only; it does not deliver messages to mobile networks or generate DLRs.

## 2. Start the SMPP JSON gateway
Open a second CMD:
```
start-smpp.bat
```
The gateway reads `config/json_config.json`, binds each configured connection, and watches `sms_request`. Logs show a separate coloured `SUBMIT_SM` and `SUBMIT_SM_RESPONSE` line for every request. Windows Terminal supports ANSI colours; older CMD versions may show escape codes if VT support is disabled.

## 3. Add an SMS
Create `sms4.json` in `sms_request`:
```json
{
  "accountId": "SMSC_TEST",
  "sourceAddress": "TEST",
  "destinationAddress": "919876543210",
  "message": "Your OTP is 123456",
  "dataCoding": "GSM",
  "requestDeliveryReceipt": false,
  "responseTimeoutMs": 10000
}
```
Only names matching `sms<number>.json` are picked up. For safe handoff, write to a temporary extension and rename to `sms4.json` after the write completes.

## 4. One-to-many connection mapping
`json_config.json` supports multiple accounts; each account can have multiple `connections[]`. A request chooses its account using `accountId`. Connections within the account are selected round-robin. Each connection has its own host, port, systemId and password.

Supported bindType: `TRANSMITTER`, `RECEIVER`, `TRANSCEIVER`. Submit SMS using a transmitter-capable bind (`TRANSMITTER` or `TRANSCEIVER`).

## Important notes
- `submit_sm_resp` status 0 means the SMSC accepted the submission; it is not confirmation that the handset received the SMS. Delivery confirmation normally arrives later through a DLR.
- Keep real SMPP passwords secure; do not commit config files to public source control.
- This starter binds at startup but does not automatically reconnect after network/SMSC failure. Restart after restoring connectivity.
- GSM text uses Cloudhopper GSM charset. Confirm encoding and `data_coding` rules with your provider before production.
- The simulator is a minimal local test SMSC, not a production SMSC.
