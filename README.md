# MM - IoRestoACasa.work

Questo repository permette di installare velocemente una nuova istanza di Multiparty-Meeting

https://github.com/havfo/multiparty-meeting

## 1. entra nella chat Telegram di supporto

e comunicaci la tua intenzione di creare un server

https://t.me/iorestoacasawork

ti faremo alcune domande e ti aiuteremo durante la procedura di installazione.

## 2. procurati un server
Puoi usare qualsiasi distribuzione GNU/Linux, avrai bisogno di installare solo `docker`, `docker-compose` e `git`.

Per installare Docker, ti consiglio di seguire la guida ufficiale:

https://docs.docker.com/install/

Per garantire un servizio migliore abbiamo stabilito i seguenti requisiti minimi:

• una macchina dedicata allo scopo, non condivisa con altri servizi.
* IPv4 statico (possibilmente in un datacenter italiano)
* connessione 100 Mbps simmetrica (meglio 1 Gbps, ogni utente occupa circa 4 Mbps)
* 4 CPU server grade (Xeon o analogo)
* 4GB di RAM

Server posizionati in datacenter italiani riducono latenza e congestione di rete.

Naturalmente un server più grande riuscirà ad ospitare più utenti!

## 3. ottieni un certificato SSL

Devi pubblicare MM con HTTPS, quindi dovrai ottenere un certificato SSL valido.

Puoi utilizzare [Let's Encrypt](https://letsencrypt.org) che fornisce certificati gratuiti o un una certification authority a tua scelta.

Se vuoi usare certbot:
```
apt install certbot
certbot certonly -d miodominio.com --standalone
```
assicurati che il tuo dominio risolva correttamente all'indirizzo IP del tuo server prima di lanciare questo comando, altrimenti la generazione del certificato fallirà.

se la procedura ha successo troverai i file necessari in:
```
# certificato (pubblico)
/etc/letsencrypt/live/TUODOMINIO/fullchain.pem
# chiave privata
/etc/letsencrypt/live/TUODOMINIO/privkey.pem
```
Nota per i certicati Let's Encrypt:
Ogni 3 mesi l'amministratore del server deve preocuparsi di aggiornare il certificato.

## 4. scarica MM

```
cd /opt
git clone https://github.com/iorestoacasa-work/mm.git
cd mm
```

## 5. copia il certificato SSL in /certs

```
cp /etc/letsencrypt/live/TUODOMINIO/fullchain.pem certs/
cp /etc/letsencrypt/live/TUODOMINIO/privkey.pem certs/
```

## 6. modifica i file di configurazione

In questo repository trovi dei file di configurazione di esempio. Dovrai copiarli e modificare tutti i `"CHANGEME"` che trovi nei valori adatti al tuo server.

```
cp coturn.example.conf coturn.conf
cp configs/app/config.example.js configs/app/config.js
cp configs/server/config.example.js configs/server/config.js
```

Modifica i tre file `coturn.conf`, `config/app/config.js`, `config/server/config.js` inserendo valori opportuni al posto dei `CHANGEME`

## 7. avvia i container

`docker-compose up -d`

## 8. Non dimenticare il Firewall!
* 80 e 443 TCP per WEB
* 3478 TCP per TURN
* 8081 TCP per le metriche
* da 40000 a 49999 UDP/TCP per i media

## 9. verifica che MM stia funzionando

collegandoti con il browser all'hostname scelto e facendo una videochiamata

## 10. verifica che le metriche siano esposte correttamente

`curl http://hostname.scelto.it:8081/metrics`

## 11. comunica la buona notizia nella chat Telegram

aggiungeremo il tuo server alla tabella sul sito https://iorestoacasa.work
