README - Infraestrutura como Código (Terraform)

Este projeto foi desenvolvido com foco na entrega funcional e automatizada da infraestrutura em nuvem utilizando Terraform. A arquitetura foi organizada em módulos reutilizáveis, separados por responsabilidade, localizados na pasta terraform/modules:

- network: define a VPC e sub-redes
- iam: configura permissões e roles
- eks: provisiona o cluster Kubernetes

Essa estrutura modular facilita a manutenção, promove reutilização e segue boas práticas de IaC. O arquivo principal (main.tf) referencia os módulos e centraliza a configuração do ambiente.

A execução do código ainda é manual, exigindo que o operador clone o repositório e execute os comandos Terraform localmente. No entanto, foi incluído um pipeline de simulação (.github/workflows/infra-ci-cd.yaml) que automatiza os passos de validação e planejamento:

- terraform init (comentado por padrão)
- terraform validate
- terraform plan

O passo terraform apply está comentado por motivos de escopo, mas incluído para demonstrar como a entrega real da infraestrutura pode ser realizada.

A automação completa da implantação (CD) pode ser implementada futuramente com integração ao pipeline de CI, autenticação segura na AWS e controle de estado remoto.

Essa abordagem garante rastreabilidade, consistência e escalabilidade na gestão dos recursos em nuvem.
