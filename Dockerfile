FROM python:3.8-buster

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

# COPY .env .
COPY requirements.txt .
COPY main.py .

RUN pip install --upgrade pip

RUN pip install -r requirements.txt

# CMD ["python", "./main.py"]

# NOTE per debug
ENTRYPOINT ["bash"]

# # NOTE per live
# CMD ["main.py" "--url https://tuo-webapp-url --metadata https://tuo-metadata-url --target 'Titolo della Pagina di login con successo'"]
# ENTRYPOINT ["python"]
