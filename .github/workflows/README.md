Pipelines de CI/CD

Este projeto conta com duas esteiras automatizadas, cada uma com um propósito específico dentro do ciclo de vida da aplicação:

Pipeline da Imagem Docker

Localizada em .github/workflows/app-ci-cd.yml, essa esteira é responsável por:

- Construir a imagem Docker da aplicação PHP
- Realizar análise de vulnerabilidades com Trivy
- Publicar a imagem no Docker Hub

Esse processo garante que cada nova versão da aplicação seja entregue de forma segura e automatizada, pronta para ser implantada em qualquer ambiente compatível com containers.

Pipeline de Infraestrutura como Código (IaC)

Localizada em .github/workflows/infra-ci-cd.yaml, essa esteira simula o provisionamento da infraestrutura na AWS utilizando Terraform. Ela executa:

- Validação do código Terraform (init, validate)
- Geração do plano de execução (terraform plan)

O passo de aplicação (terraform apply) está comentado por motivos de escopo, mas incluído para demonstrar como o deploy real seria realizado em ambientes produtivos.

Essa automação representa a base de um pipeline de CD para infraestrutura, garantindo consistência e rastreabilidade na gestão dos recursos em nuvem.
