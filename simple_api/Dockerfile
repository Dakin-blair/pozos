# Stage 1 : build des dependances (compilation de flask_simpleldap)
FROM python:3.11-slim AS builder

WORKDIR /

COPY requirements.txt /

RUN apt update -y && apt install -y \
    python3-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    gcc \
    build-essential

RUN pip3 install --user -r /requirements.txt

# Stage 2 : image finale, avec uniquement les librairies runtime necessaires
FROM python:3.11-slim

LABEL maintainer="Dakin Blair <noubouossiedakin@gmail.com>"

WORKDIR /

RUN apt update -y && apt install -y \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.local /root/.local
COPY student_age.py /

ENV PATH=/root/.local/bin:$PATH

VOLUME /data

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f -u toto:python http://localhost:5000/pozos/api/v1.0/get_student_ages || exit 1

CMD ["python3", "./student_age.py"]