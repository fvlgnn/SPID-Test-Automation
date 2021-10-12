# SPID SAML Check Test Automation
Automatizzazione dei test AgID del simulatore Identity Provider _IdP_ [SPID SAML Check](https://github.com/italia/spid-saml-check) per l'integrazione di SPID.


## Descrizione

Questo sistema automatizzato aiuta l'utente a verificare il centinaio di test che AgID richiede affinché un Service Provider _SP_ possa integrare sul proprio ambiente la login tramite SPID.

Il sistema è sviluppato tramite Python ed utilizza Selenium che interagisce su un browser (attualmente Chrome). Il sistema può essere eseguito direttamente da Python oppure eseguito in un container Docker/Docker compose, o lanciato da un orchestratore (Kubernates/Openshift) utilizzando una versione Jenkins Slave per eseguire il pull dell'immagine Docker e avviare la procedura automatizzata dei test AgID.

I parametri personalizzabili del sistema possono essere passati tramite argomenti _args_ o tramite variabili d'ambiente _env_.


----


## Requisiti d'ambiente

- IdP _SPID SAML Check_ installato su ambiente (vedi documentazione ufficiale _Developers Italia_ https://github.com/italia/spid-saml-check)
- WebApp Service Provider _SP_ con login SPID e con abilitato come Identity Provider _IdP_ il validatore _SPID SAML Check_
- Python 3
- Pip
- Selenium
- Chrome
- Docker (opzionale)
- Kubernates (opzionale)
- Openshift (opzionale)
- Jenkins (opzionale)


----


## Guida all'uso

**Nota Bene!** Sicuramente all'interno dello script principale `main.py`, alcuni tags HTML che utilizza Selenium per catturare le sezioni della WebApp personale, in modo tale da simulare le azioni di login, andranno modificati, mentre quelli inerenti al validatore _SPID SAML Check_ sono configurati in modo tale da non richiedere ulteriori modifiche.


## Parametri e Variabili

Paramenti delle variabili per i test. I parametri possono essere passati allo script tramite argomenti/switch o tramite file .env o tramite variabili d'ambiente di sistema.

Di default vengono lette le variabili degli argomenti, in caso non siano impostati vengono usati i valori di default. Per dettagli vedi --help o vedi sottosezione [Argomenti](#argomenti). 

Se si desidera utilizzare passare le variabili d'ambiente tramite file `.env` o tramite sistema, usare come esempio il file `.env.example`. Per dettagli vedi sottosezione [Variabili Ambiente](#variabili-ambiente).


### Argomenti

Eseguire lo script passando o meno i seguenti argomenti. Nel caso non vengano passati gli argomenti verranno utilizzati i valori di default.


    usage: main.py [-h] [--first FIRST] [--last LAST] [--exclude EXCLUDE [EXCLUDE ...]] [--custom-test CUSTOM_TEST [CUSTOM_TEST ...]] [--url URL] [--meta META] [--target TARGET] [--custom-user CUSTOM_USER] [--fiscal-number FISCAL_NUMBER] [--email EMAIL] [--level LEVEL] [--delay DELAY] [--logout LOGOUT] [--container CONTAINER] [--logs LOGS]

    optional arguments:
    -h, --help              show this help message and exit
    --first FIRST           Test di partenza (default: 1)
    --last LAST             Test di arrivo (default: 111)
    --exclude EXCLUDE [EXCLUDE ...]
                            Test da escludere (es. 5 6 7). Di default i test che AgID non verifica (default: [5, 6, 7, 50, 101, 102])
    --custom-test CUSTOM_TEST [CUSTOM_TEST ...]
                            Esegue solo i test nella lista (es. 1 32 94 95 96 111) (default: None)
    --force FORCE           True, riesegue i test saltati per problemi non riferiti alla validazione (default: true)
    --url URL               URL di partenza, la webapp con integrato il login con SPID (default: https://localhost:8443)
    --meta META             URL del metadata del tuo SP (default: https://localhost:8443/spid-sp-metadata)
    --target TARGET         HTML <title> della pagina di destinazione (default: TestSpidWebAppLoggedIn)
    --target-unauthorized TARGET_UNAUTHORIZED   
                            HTML <title> della pagina per utente senza privilegi (default: Errore - Utente Non Autorizzato)
    --custom-user CUSTOM_USER
                            True modifica CF e Email nella Response come --cf e --email, False come da test.json (default: false)
    --fiscal-number FISCAL_NUMBER
                            Codice fiscale con prefisso TINIT- dell'utente di test (default: TINIT-GDASDV00A01H501J)
    --email EMAIL           Email dell'utente di test (default: spid.tech@agid.gov.it)
    --level LEVEL           Livello minimo di SPID richiesto dal SP per i test (94, 95, 96). Usa 1, 2 o 3 (default: 1)
    --delay DELAY           Tempo tra un'azione e l'altra (default: 0.4)
    --logout LOGOUT         True, forza il logout se la sessione è attiva (default: true)
    --container CONTAINER
                            True se eseguito da dentro un container, False visualizza il browser all'utente per debug (default: true)
    --logs LOGS             False per live usa stdout, True per debug scrive logs su FS (default: false)


In particolare `--container` usa chrome in modalità _headless_, _no-sandbox_, disabilitando la gpu e altre cose che servono per far girare chrome dentro un container. 

**Nota Bene!** Per prime istallazioni e/o debug è consigliabile eseguire lo script direttamente tramite python e impostando lo switch `--container false`. NON USARE l'argomento _container false_ all'interno di un container o di un orchestratore, non potrà funzionare. Per l'ambiente di sviluppo è consigliabile usare il _virtual environments venv_ di python, vedi https://docs.python.org/3/library/venv.html.


### Variabili Ambiente

Usare variabili tramite file `.env` o tramite variabili d'ambiente di sistema. Utilizzando le variabili d'ambiente i valori di alcuni o di tutti gli [argomenti](#argomenti) _args_ verranno sovrascritti. 

Se si desidera utilizzare passare le variabili d'ambiente tramite file `.env` o tramite sistema, usare come esempio il file `.env.example`, creando un file `.env` per l'appunto e modificare i valori delle variabili.

**Nota Bene!** Se si desidera utilizzare le variabili d'ambiente al posto degli argomenti è molto importante impostare all'interno del file `.env` o all'interno del sistema la variabile _USE_ENV_VAR_ a vera come segue `USE_ENV_VAR=true`.


## Esempi pratici

Lista di comandi da eseguire in base al sistema in uso con esempi pratici e spiegazioni.

### Python

Direttamente tramite python.

- `python3 main.py` 

Esegue i test come da parametri di default. **Nota Bene!** Se non sono state apportate modifiche al sorgente, quantomeno ai parametri _url_ e _metadata_, sicuramente non può funzionare :|

- `python3 main.py --first 44 --last 60 --delay 1.5 --target 'Pagina di Test' --custom-user true`

Il comando sopra lancia l'automatizzazione dei test dal 44 al 60, con un delay tra un operazione e l'altra di un secondo e mezzo, dove _Pagina di Test_ è il titolo HTML compreso nel tag _<title></title>_ della pagina di arrivo dopo aver effettuato l'accesso e sulla _Response_ del validatore viene modificato _fiscalNumber_ (--fiscal-number) e _email_ (--email) come da parametri di default.

- `python3 main.py --url https://localhost:8081 --meta https://localhost:8081/metadata.xml --container false --logs true --custom-test 1 94 95 96 111`

Il comando sopra lancia l'automatizzazione dei test cercando la webapp e prelevando il metadata in localhost sulla porta 8081, visualizzando il browser, scrivendo i logs - all'interno della cartella _logs_ e verificando solo i test _1, 94, 95, 96, 111_.

**Nota Bene!** _SPID SAML Check_ di default in locale gira sulla porta `8080` quindi la webapp con il login di SPID localmente deve girare su altra porta. Nell'esempio sopra sulla `8081`.

### Docker

In questo repository sono presenti 4 _Dockerfile_ dai quali può essere costruita l'immagine. Segue breve descrizione del contenuto.

- **`Dockerfile`**: di default una volta eseguita la build ed eseguito il run entra direttamente nel terminale `bash` del container. Al suo interno sono presenti step per la build commentati in modo tale da prendere spunto per eventuali personalizzazioni. Vedi [Python](#python) e [Parametri e Variabili](#parametri-e-variabili).
- **`Dockerfile-python-arg`**: di default una volta eseguita la build ed eseguito il run, viene avviato direttamente lo script con i parametri riportati nello step `CMD`. Per funzionare sicuramente necessita di essere personalizzato. Vedi la sezione [Argomenti](#argomenti).
- **`Dockerfile-python-env`**: di default una volta eseguita la build ed eseguito il run, viene avviato direttamente lo script con le variabili lette dal file `.env`. Assicurarsi che il file esista e sia configurato correttamente con i parametri desiderati, inoltre è importate che nel file sia riportata la variabile `USE_ENV_VAR=true`. Vedi la sezione [Variabili Ambiente](#variabili-ambiente).
- **`Dockerfile-openshift-jenkins-salve`**: da utilizzare solo se si dispone di un Openshift/Kubernates e si hanno competenze DevOps. L'immagine creata può essere caricata nel cluster ed essere avviata tramite Build. Viene creato un pod con Jenkins che esegue la pipeline come da configurazione personale, tale pod effettua i test come da script `main.py`. L'output di Jenkins richiede alcuni minuti prima che venga riportato a video. Vedi la sezione [Jenkins Slave su Openshift / Kubernates](#jenkins-slave-su-openshift-kubernates).

#### Alcuni esempi

Usare il sistema all'interno di un container Docker, attenzione a verificare l'esistenza o meno del file `.env`, vedi sezione [Argomenti](#argomenti) e [Variabili Ambiente](#variabili-ambiente).

- `docker build -t spid-test-automation`
- `docker run -it spid-test-automation`

Per creare un container che utilizza le variabili d'ambiente (assicurarsi che esista il file `.env`) ed eseguire i seguenti comandi.

- `docker build -f .\Dockerfile-python-env -t spid-test-automation-python-env .`
- `docker run -it spid-test-automation-python-env`

Per debug si consiglia di avviare il container montando il file `main.py` da filesystem a container. Eseguire la build utilizzando il `Dockerfile` ed eseguire il seguente comando _run_.

- `docker run --mount type=bind,source="$(pwd)"/main.py,target=/main.py -it spid-test-automation`

In questo modo si accede all'interno del container tramite _ENTRYPOINT_ `bash` ed è possibile modificare il file `main.py` in modo tale che le modifiche apportate possono essere verificate dopo il salvataggio senza la necessità di dover eseguire una nuova _docker build_.

Per altre informazioni in merito al mondo dei container si consiglia di consultare la documentazione ufficiale di [Docker](https://docker.com).


#### Jenkins Slave su Openshift / Kubernates 

- visionare\modificare `Dockerfile-openshift-jenkins-slave`
- eseguire la build `docker build -f Dockerfile-openshift-jenkins-slave -t spid-test-automation`
- assegnare un tag all'immagine `docker image tag spid-test-automation nome-del-tuo-registry/spid-test-automation:latest`
- caricare l'immagine su un docker registry `docker push nome-del-tuo-registry/spid-test-automation:latest`

- configurare l'orchestratore per utilizzare l'immagine
- configurare i parametri della pipline di Jenkins esempio di seguito 

```
pipeline {
    agent any
    environment {
        LC_ALL = 'en_US.UTF-8'
        LANG    = 'en_US.UTF-8'
        LANGUAGE = 'en_US.UTF-8'
    }
    stages {
        stage("SPID Test Automation") {
            agent {
                label 'spid-test-automation'
            }   
            steps {
                script {
                    sh "python3 /main.py --url ${env.WEBAPP_TEST_PAGE_URL} --meta ${env.WEBAPP_TEST_METADATA_URL} --target ${env.WEBAPP_TEST_PAGE_TITLE}"
                }
            }
        }
    }
}
```


