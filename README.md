Modernização DevOps de Aplicação PHP

Este projeto tem como objetivo modernizar o ciclo de vida de uma aplicação PHP legada, aplicando práticas de DevOps como containerização, automação de pipelines CI/CD, infraestrutura como código (IaC) e estratégia de observabilidade. A entrega está organizada em etapas, conforme solicitado no teste técnico.

Etapa 1: Containerização da Aplicação

A aplicação foi empacotada em uma imagem Docker utilizando um Dockerfile otimizado e seguro:

- Multi-stage build: separa o processo de build da imagem final, reduzindo o tamanho e melhorando a segurança.
- Imagem oficial php:8.2-apache: garante compatibilidade com a aplicação legada e atualizações contínuas.
- Execução com usuário não-root (appuser): evita riscos de segurança em ambientes de produção.
- Limpeza de arquivos desnecessários: arquivos .log são removidos durante o build.
- Uso de .dockerignore: evita inclusão de arquivos irrelevantes no contexto da imagem.

Essa imagem é utilizada diretamente no manifesto de Deployment do Kubernetes, garantindo consistência entre ambientes.

Etapa 2: Pipeline de Integração Contínua (CI)

Foi criado um pipeline no GitHub Actions (.github/workflows/app_ci-cd.yml) com os seguintes passos:

1. Checkout do código
2. Build da imagem Docker
3. Scan de vulnerabilidades com Trivy
4. Push da imagem para o Docker Hub

A autenticação no Docker Hub é feita via secrets configurados no GitHub (DOCKER_USERNAME e DOCKER_PASSWORD).

Essa automação garante que cada alteração na branch principal gere uma nova imagem validada e publicada, reduzindo riscos e acelerando entregas.

Etapa 3: Infraestrutura como Código (IaC) e Implantação (CD)

Orquestração: Amazon EKS

A escolha pelo Amazon EKS (Kubernetes) foi motivada por:

- Flexibilidade para escalar aplicações complexas.
- Ecossistema maduro para observabilidade, segurança e automação.
- Compatibilidade com manifestos declarativos e ferramentas como Helm e ArgoCD.

A escolha pelo AWS Fargate foi feita por ser uma solução serverless para containers, que oferece:
- Zero gerenciamento de servidores: não há necessidade de configurar ou manter instâncias EC2.
- Escalabilidade automática: ajusta recursos conforme a demanda da aplicação.
- Provisionamento simplificado: ideal para projetos com foco em entrega rápida e infraestrutura enxuta.
- Custo sob demanda: paga-se apenas pelo uso real de CPU e memória.

Essa abordagem reduz a complexidade operacional e acelera o ciclo de entrega, sendo mais adequada ao escopo do desafio do que uma arquitetura baseada em servidores gerenciados manualmente.

Código Terraform

A infraestrutura foi provisionada com Terraform utilizando uma estrutura modular. Os módulos estão organizados em terraform/modules/, separados por responsabilidade:

- network: define a VPC e sub-redes
- iam: configura permissões e roles
- eks: provisiona o cluster Kubernetes

Essa abordagem modular melhora a organização, facilita a reutilização e reflete boas práticas de IaC. A execução ainda é manual, mas o pipeline infra-ci-cd.yaml simula o ciclo de entrega com init, validate e plan. O passo apply está comentado por motivos de escopo.

Manifestos Kubernetes

Os manifestos estão organizados na pasta k8s/ e definem os recursos necessários para executar a aplicação em produção com boas práticas de resiliência e escalabilidade:

- deployment.yaml: define o deployment da aplicação com a imagem publicada.
- service.yaml: expõe a aplicação via LoadBalancer na porta 80 → 8080.
- configmap.yaml: centraliza variáveis de configuração da aplicação.
- hpa.yaml: configura o autoscaling horizontal com base em uso de CPU.
- pdb.yaml: define políticas de interrupção para manter alta disponibilidade durante atualizações ou falhas.
- ns-prod.yaml: isola os recursos da aplicação em um namespace dedicado ao ambiente de produção.

Esses arquivos garantem que a aplicação seja implantada com controle, escalabilidade e tolerância a falhas, alinhando-se às práticas recomendadas para workloads em Kubernetes.

Estratégia de CD

O pipeline de CI pode ser estendido para implantação contínua (CD) com:

- Autenticação na AWS via aws-actions/configure-aws-credentials
- Aplicação dos manifestos com kubectl apply ou via ArgoCD
- Trigger automático após push da imagem para o Docker Hub

Essa extensão garante que novas versões sejam implantadas automaticamente no ambiente de produção.

Etapa 4: Estratégia de Observabilidade

Stack sugerida

- Prometheus + Grafana: coleta e visualização de métricas
- ELK Stack (Elasticsearch, Logstash, Kibana): análise de logs
- AWS CloudWatch: alternativa nativa para logs e métricas básicas

Métricas principais

1. Taxa de erro HTTP (4xx/5xx): monitora falhas na aplicação
2. Uso de CPU e memória por pod: identifica gargalos de performance
3. Tempo médio de resposta: mede a experiência do usuário

Essas métricas formam a base de um dashboard de saúde do serviço, permitindo decisões rápidas e informadas.
