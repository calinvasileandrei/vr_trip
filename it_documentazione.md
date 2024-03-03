# Documentazione VR App

#### Definizioni
* Dispositivo manager: Un dispositivo che controlla un gruppo di dispositivi client
* Dispositivo cliente/host: Un dispositivo utente che viene controllato da un manager
* Percorso: Per percorso e' inteso un file video intero, esse e' formato da tante clip. Il percorso e' abbinato da un file transcript.json che ne definisce le caratteristiche, numero di clip, nome di ogni clip e il tempo di inizio e di fine di una clip.
* Clip: Per clip si intende un pezzo di vide di un percorso, per esempio una clip potrebbe essere il primo minuto di un video
* Libreria Interna: La libreria interna e' la parte di memoria interna dell'applicazione sicura non accessibile dall'esterno.


## Intro
L'applicazione per funzionare necessita di essere collegata al wifi, in modo che possa recuperare un indirizzo IP per gestire le comunicazioni con un "dispositivo manager" o per funzionare da "dispositivo client".


Se non callegato ad una rete wifi viene mostrata una schermata con un tasto "aggiorna" che permette dopo essersi collegati ad una rete wifi di recuperare l'indirizzo IP.

Una volta superata questa schermata (visualizzata solo se non connesso ad una rete wifi ) si viene portati alla schermata Home.

## Introduzione Home

La schermata home presenta 5 pulsanti che permettono la navigazione verso altre schermate

- Device Manager
- Device Host
- Selezione Manager
- Gestione File
- Settings

## Come usare l'applicazione

#### Impostare il nome dispositivo

Per prima cosa e' necessario entrare nella schermata "Setting", questa schermata permette di selezionare il nome del dispositivo (e' consigliato usare il numero segnato dietro ad ogni dispositivo per avere sempre una panoramica chiara di quale dispositivo e' chi).

Per settare quindi il nome dispositivo premere il campo di testo, scrivere il nome e successivamente premere il taso "salva".

>Una volta completata questa operazione non sara' piu' necessaria ripeterla a meno che non venga eliminata l'applicazione (il nome viene salvato dentro la memoria persistente dell'applicazione).

#### Gestione File

La sezione gestione file permette di gesire i percorsi sul dispositivo.
Questa sezione e' composta da 3 pagine scorrendo da destra verso sinistra e' possibile navigare nella pagina successiva.

- Pagina 1: Gestione file locali 
  - Questa schermata permette di getire i file locali nel telefono.
  - Se dentro la memoria del telefono nella cartella Downloads creiamo una cartella chiamata "VR_TRIP" e all'interno di essa aggiungiamo un percorso sara' possibile visualizzare questo percorso da questa pagina.
  - Se il percorso che e' stato aggiunto alla cartella VR_TRIP non e' valido allora verra mostrato di colore ROSSO.
  - Se il percorso che e' stato aggiunto alla cartella VR_TRIP e' valido verra' mostrato di colore verde.
  - Premendo il tasto Importa Downloads/VR_TRIP e' possibile fare una copia dei file percorsi (solo quelli validi) nella memoria interna dell'applicazione, quando viene premuto questo tasto viene avviato un animazione di caricamento sul pulsante. (E' importante rimanere su questa ).
- Pagina 2: Libreria Interna dell'applicazione
  - In questa pagina e' possibile vedere tutti i percorsi caricati nell'applicazione.
  - Premendo su un percorso e' possibile avviare la riproduzione di esso.
  - Premendo a lungo su un percorso e' possibile eliminare solo quel percorso
  - Premendo "Cancella Libreria" verra' eliminata tutta la libreria interna dell'applicazione.
- Pagina 3: Gestione Google Drive
  - In questa pagina e' possibile connettersi ad un account google che e' stato autorizzato (se volete aggiungere altri account dovete richiedermi l'accesso).
  - Appena entrati sulla pagina aspettare 1/2 secondi prima di effettuare altre operazioni cosi da dare il tempo di effettuare la connessione automatica a google.
  - Se la connessione a google automatica non e' avvenuta per un qualsiasis motivo e' possibile premere il tasto "Connetti a Google Drive" per effettuare l'accesso.
  - In alto alla pagina sulla destra della scritta "Sinc GoogleDrive" e' possibile controllare lo stato se su "Effettuata" l'applicazione e' connessa a Google.
  - Dopo essersi connessi se si preme il tasto "Aggiorna" verranno mostrati tutti i percorsi disponibili su Google Drive.
  - #### Percorsi di Google drive
    - Per aggiungere un percorso su Google Drive bisogna precedere il nome del percorso con la scritta "VrTrip_", quindi il nome completo della cartella del percorso sara' : "VrTrip_NOMEPERCORSO"
    - Premendo su una cartella di Google Drive nella schermata questa verra' scaricata sul dispositivo nella Libreria Interna. Per scaricare un percorso potrebbero volerci diversi minuti, e' importante aspettare che l'icona di caricamento vicino ad un percorso scompaia del tutto prima di uscire da questa pagina.
    - > E' possibile scaricare piu' di un percorso alla volta ma e' consigliato non superare i 2/3 percorsi in simultanea
    - > E' possibile scaricare i percorsi da piu' dispositivi simultaneamente senza problemi.
    - Un volta scaricato un percorso da google drive nella Libreria Interna, dovrebbe apparire immediatamente nella pagina della Libreria Interna. Verificare che quest'ultimo funzioni correttamente provando a riprodurre il percorso in questione. Se non dovesse funzionare eliminare il percorso e scaricarlo nuovamente.



#### Selezione Manager
In questa pagina e' possibile selezionare quale manager debba controllare il dispositivo in questione. Quindi questa pagina verra' visitata solo dai Dispositivi Client.

Accedendo alla pagina l'applicazione si mette in ricerca sulla rete, e al centro della schermata dovrebbe apparire la scritta "Ricerca di un manager in corso...".

In questo momento se sulla rete wifi e' presente un dispositivo che sta svolgendo il ruolo di manager dovrebbe apparire identificato dal suo indirizzo IP es: 192.168.0.106.

Premendo su di esso verra' completato il campo "Manager IP" presente in cima alla schermata. Per cancellare la selezione e' possibile premere il tasto a forma di icona del secchio di colore rosso.

> La selezione del manager viene salvata nella memoria del telefono quindi non e' necessario ripeterla a meno che non si voglia cambiare Manager.

La selezione del manager persiste quindi anceh dopo la chiusura dell'applicazione e rimarra' selezionata finche non verra' cancellata l'applicazione o rimossa la selezione tramite l'icona del secchio.


#### Device Client

Quando si naviga su questa schermata l'applicazione verra' girata in modalita "landscape" quindi come se si dovesse vedere un video a schermo intero.

La schermata sara' completamente nera con luminosita' ridotta cosi da ridurre i consumi.

Si possono intravedere 3 scrite in cima alla schermata che sono:
- Ip : L'indirizzo ip del dispositivo in questione
- Manager Ip: L'indirizzo del manager selezionato
- Nome: Il nome che abbiamo assegnato al dispositivo

In oltre e' presente un tasto disconnetti che permette la disconnessione dal manager ( Forse non necessario ).

Rimanendo su questa schermata il dispositivo client si connette automaticamente al manager e rimane in attesa di un'istruzione.

- #### Controlli manuali durante la riproduzione
  - Da documentare


#### Device Manager

