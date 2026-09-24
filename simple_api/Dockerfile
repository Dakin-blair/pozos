FROM python:3.11-slim

LABEL maintainer="Dakin Blair <noubouossiedakin@gmail.com>"

WORKDIR /

COPY student_age.py /
COPY requirements.txt /

RUN apt update -y && apt install -y \
    python3-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    gcc \
    build-essential

RUN pip3 install -r /requirements.txt

VOLUME /data

EXPOSE 5000

CMD ["python3", "./student_age.py"]