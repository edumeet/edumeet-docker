import os
import time

def get_total_bytes(interfaces):
    rx_bytes = 0
    tx_bytes = 0

    for interface in interfaces:
        with open('/sys/class/net/{}/statistics/rx_bytes'.format(interface)) as f:
            rx_bytes += int(f.read())
        with open('/sys/class/net/{}/statistics/tx_bytes'.format(interface)) as f:
            tx_bytes += int(f.read())
    return (rx_bytes, tx_bytes)

interfaces = os.listdir('/sys/class/net/')
if 'lo' in interfaces:
    interfaces.remove('lo') 
(rx_bytes1, tx_bytes1) = get_total_bytes(interfaces)
time.sleep(1)
(rx_bytes2, tx_bytes2) = get_total_bytes(interfaces)

rx_bitrate = ((rx_bytes2 - rx_bytes1) / 1024 ) * 8
tx_bitrate = ((tx_bytes2 - tx_bytes1) / 1024 ) * 8

print(rx_bitrate, tx_bitrate)
