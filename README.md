# 🚀 Modernização DevOps de Aplicação PHP

Este projeto tem como objetivo modernizar o ciclo de vida de uma aplicação PHP legada, aplicando práticas de DevOps como containerização, automação de pipelines CI/CD, infraestrutura como código (IaC) e estratégia de observabilidade. A entrega está organizada em etapas, conforme solicitado no teste técnico.

---

## 🧱 Etapa 1: Containerização da Aplicação

A aplicação foi empacotada em uma imagem Docker utilizando um `Dockerfile` otimizado e seguro:

- **Multi-stage build**: separa o processo de build da imagem final, reduzindo o tamanho e melhorando a segurança.
- **Imagem oficial `php:8.2-apache`**: garante compatibilidade com a aplicação legada e atualizações contínuas.
- **Execução com usuário não-root (`appuser`)**: evita riscos de segurança em ambientes de produção.
- **Limpeza de arquivos desnecessários**: arquivos `.log` são removidos durante o build.
- **Uso de `.dockerignore`**: evita inclusão de arquivos irrelevantes no contexto da imagem.

Essa imagem é utilizada diretamente no manifesto de Deployment do Kubernetes, garantindo consistência entre ambientes.

---

## ⚙️ Etapa 2: Pipeline de Integração Contínua (CI)

Foi criado um pipeline no GitHub Actions (`.github/workflows/main.yml`) com os seguintes passos:

1. **Checkout do código**
2. **Build da imagem Docker**
3. **Scan de vulnerabilidades com Trivy**
4. **Push da imagem para o Docker Hub**

> A autenticação no Docker Hub é feita via `secrets` configurados no GitHub (`DOCKER_USERNAME` e `DOCKER_PASSWORD`).

Essa automação garante que cada alteração na branch principal gere uma nova imagem validada e publicada, reduzindo riscos e acelerando entregas.

---

## ☁️ Etapa 3: Infraestrutura como Código (IaC) e Implantação (CD)

### 🔧 Orquestração: Amazon EKS

A escolha pelo **Amazon EKS (Kubernetes)** foi motivada por:

- Flexibilidade para escalar aplicações complexas.
- Ecossistema maduro para observabilidade, segurança e automação.
- Compatibilidade com manifestos declarativos e ferramentas como Helm e ArgoCD.

A escolha pelo AWS Fargate foi feita por ser uma solução serverless para containers, que oferece:
• 	Zero gerenciamento de servidores: não há necessidade de configurar ou manter instâncias EC2.
• 	Escalabilidade automática: ajusta recursos conforme a demanda da aplicação.
• 	Provisionamento simplificado: ideal para projetos com foco em entrega rápida e infraestrutura enxuta.
• 	Custo sob demanda: paga-se apenas pelo uso real de CPU e memória.
Essa abordagem reduz a complexidade operacional e acelera o ciclo de entrega, sendo mais adequada ao escopo do desafio do que uma arquitetura baseada em servidores gerenciados manualmente.


### 📁 Código Terraform

Foi adotado um **script monolítico** (`main.tf`) para provisionar o cluster EKS, roles e networking. Embora modularização seja recomendada em projetos maiores, a abordagem monolítica foi escolhida por:

- Simplicidade e clareza para fins de avaliação.
- Escopo limitado e foco em demonstrar fundamentos.
- Agilidade na entrega.

Embora o código esteja versionado como Infraestrutura como Código (IaC), sua execução ainda é manual.
O operador precisa clonar o repositório e executar  localmente. A automação completa da implantação (CD) pode ser implementada futuramente com integração ao pipeline de CI e autenticação segura na AWS.

Essa decisão está documentada no `terraform/README.md`.

### 📄 Manifestos Kubernetes

- `deployment.yaml`: define o deployment da aplicação com a imagem publicada.
- `service.yaml`: expõe a aplicação via LoadBalancer na porta 80 → 8080.

### 🔄 Estratégia de CD

O pipeline de CI pode ser estendido para implantação contínua (CD) com:

- Autenticação na AWS via `aws-actions/configure-aws-credentials`.
- Aplicação dos manifestos com `kubectl apply` ou via ArgoCD.
- Trigger automático após push da imagem para o Docker Hub.

Essa extensão garante que novas versões sejam implantadas automaticamente no ambiente de produção.

---

## 📊 Etapa 4: Estratégia de Observabilidade

### 🛠️ Stack sugerida

- **Prometheus + Grafana**: coleta e visualização de métricas.
- **ELK Stack (Elasticsearch, Logstash, Kibana)**: análise de logs.
- **AWS CloudWatch**: alternativa nativa para logs e métricas básicas.

### 📈 Métricas principais

1. **Taxa de erro HTTP (4xx/5xx)**: monitora falhas na aplicação.
2. **Uso de CPU e memória por pod**: identifica gargalos de performance.
3. **Tempo médio de resposta**: mede a experiência do usuário.

Essas métricas formam a base de um dashboard de saúde do serviço, permitindo decisões rápidas e informadas.

---



