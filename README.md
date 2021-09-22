# SPID Test Automation
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


### Parametri

Paramenti delle variabili per i test.

#### Argomenti

Eseguire lo script passando o meno i seguenti argomenti.

    -h, --help                                  show this help message and exit
    --first FIRST                               Test di partenza (default: 1)
    --last LAST                                 Test di arrivo (default: 111)
    --exclude EXCLUDE [EXCLUDE ...]             Test da escludere (es. 5 6 7). Di default i test che AgId non verifica (default: [5, 6, 7, 50, 101, 102])
    --custom-test CUSTOM_TEST [CUSTOM_TEST ...] Esegue solo i test nella lista (es. 32 94 95 96 111) (default: None)
    --url URL                                   URL di partenza (default: https://tua-webapp-con-login-spid.tld)
    --meta META                                 URL del metadata del SP (default: https://tuo-service-provider-dove-leggere-il-metadata-spid.tld/spid-sp-metadata)
    --target TARGET                             HTML <title> della pagina di destinazione (default: TestSpidWebApp)
    --custom-user CUSTOM_USER                   True modifica CF e Email nella Response vedi --cf e --email, False come da test.json (default: false)
    --fiscal-number FISCAL_NUMBER               Codice fiscale con prefisso TINIT- dell'utente di test (default: TINIT-GDASDV00A01H501J)
    --email EMAIL                               Email dell'utente di test (default: spid.tech@agid.gov.it)
    --level LEVEL                               Livello SPID. Usa 1, 2 o 3 (default: 1)
    --delay DELAY                               Tempo tra un'azione e l'altra (default: 0.4)
    --logout LOGOUT                             True, forza il logout se la sessione è attiva (default: true)
    --container CONTAINER                       True se eseguito da dentro un container, False visualizza il browser all'utente per debug (default: true)
    --logs LOGS                                 False per live usa stdout, True per debug scrive logs su FS (default: false)

In particolare `--container` usa chrome in modalità _headless_, _no-sandbox_, disabilitando la gpu e altre cose che servono per far girare chrome dentro un container. 

**Nota Bene!** Per prime istallazioni e/o debug è consigliabile eseguire lo script direttamente tramite python e impostando lo switch `--container false`. NON USARE l'argomento _container false_ all'interno di un container o di un orchestratore, non potrà funzionare. Per l'ambiente di sviluppo è consigliabile usare il _virtual environments venv_ di python, vedi https://docs.python.org/3/library/venv.html.


#### System Environment

TODO


#### Dot-Env (Variabili da file `.env`)

TODO



### Esempi pratici

Lista di comandi da eseguire in base al sistema in uso con esempi pratici e spiegazioni.

#### Python

Direttamente tramite python.

- `python3 main.py` 

Esegue i test come da parametri di default. **Nota Bene!** Se non sono state apportate modifiche al sorgente, quantomeno ai parametri _url_ e _metadata_, sicuramente non può funzionare :|

- `python3 main.py --first 44 --last 60 --delay 1.5 --target 'Pagina di Test' --custom-user true`

Il comando sopra lancia l'automatizzazione dei test dal 44 al 60, con un delay tra un operazione e l'altra di un secondo e mezzo, dove _Pagina di Test_ è il titolo HTML compreso nel tag _<title></title>_ della pagina di arrivo dopo aver effettuato l'accesso e sulla _Response_ del validatore viene modificato _fiscalNumber_ (--fiscal-number) e _email_ (--email) come da parametri di default.

- `python3 main.py --url https://localhost:8080 --meta https://localhost:8081/metadata.xml --container false --logs true --custom-test 1 94 95 96 111`

Il comando sopra lancia l'automatizzazione dei test in localhost (verificare che SPID SAML Check stia girando in locale), prelevando il metadata da una web app in locale che gira sulla porta 8081, visualizzando il browser, scrivendo i logs - all'interno della cartella _logs_ e verificando solo i test _1, 94, 95, 96, 111_.


#### Docker

All'interno di un container Docker.

- `docker build -t spid-test-automation` o con Dockerfile personalizzato es. `docker build -f Dockerfile-python-env -t spid-test-automation`
- `docker run -it spid-test-automation`

Per vedere l'output dal container.

Immagine sul registry docker

Per altre informazioni si consiglia di consultare la documentazione ufficiale di Docker


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


