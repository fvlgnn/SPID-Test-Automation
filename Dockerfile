FROM python:3.8-buster

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

COPY .env* .
COPY requirements.txt .
COPY main.py .

RUN pip install --upgrade pip

RUN pip install -r requirements.txt
# RUN pip install argparse
# RUN pip install python-dotenv

#### #### NOTE LIVE #### ####

# usa variabili da arg
# CMD ["main.py", "--url", "https://tuo-webapp-url", "--meta", "https://tuo-metadata-url/metadata", "--target", "Titolo Pagina Login corretto"]

# OPPURE

# usa variabili da env
# CMD ["main.py"]

# ENTRYPOINT ["python"]


#### #### NOTE DEBUG #### ####

ENTRYPOINT ["bash"]


