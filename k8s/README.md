Kubernetes (k8s/)

Esta pasta contém os manifestos Kubernetes utilizados para orquestrar a aplicação PHP em ambiente de produção. Os arquivos foram organizados para refletir boas práticas de resiliência, escalabilidade e isolamento de ambiente.

Componentes adotados:

- deployment.yaml: define o deployment da aplicação, especificando a imagem Docker publicada, número de réplicas e política de atualização. Garante consistência e controle de versão.

- service.yaml: expõe a aplicação por meio de um LoadBalancer, redirecionando o tráfego externo da porta 80 para a porta interna 8080 do container.

- configmap.yaml: centraliza variáveis de configuração da aplicação, permitindo ajustes sem necessidade de rebuild da imagem.

- hpa.yaml: configura o Horizontal Pod Autoscaler com base no uso de CPU, permitindo escalabilidade automática conforme a demanda.

- pdb.yaml: define políticas de interrupção para garantir disponibilidade mínima durante atualizações ou falhas, evitando indisponibilidade total.

- ns-prod.yaml: cria um namespace dedicado ao ambiente de produção, isolando os recursos e facilitando a gestão por contexto.

Esses manifestos foram pensados para garantir que a aplicação seja implantada com controle, escalabilidade e tolerância a falhas, alinhando-se às práticas recomendadas para workloads em Kubernetes.

Para aplicar os manifestos em um cluster ativo, utilize:

kubectl apply -f k8s/

A aplicação será provisionada no namespace "prod", com balanceamento de carga, escalabilidade automática e políticas de resiliência.
