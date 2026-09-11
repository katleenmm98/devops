# Cluster Kubernetes Local com Kind via Terraform

## Objetivo

Este repositório provisiona, de forma **100% declarativa via Terraform**, um cluster
Kubernetes local utilizando o [Kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker).
Nenhum comando manual `kind create cluster` foi utilizado — todo o ciclo de vida
(criação, configuração e destruição) é controlado pelo Terraform através do provider
[`tehcyx/kind`](https://registry.terraform.io/providers/tehcyx/kind/latest).

## Nome do cluster e topologia

- **Nome do cluster:** `devops`
- **Topologia:**
  - 1 node **control-plane** (gerencia o cluster)
  - 2 nodes **worker** (executam as cargas de trabalho)

A topologia é definida no bloco `kind_config` do recurso `kind_cluster.devops`, em
`main.tf`, através de três blocos `node`: um com `role = "control-plane"` e dois com
`role = "worker"`.

## Estrutura dos arquivos

| Arquivo         | Descrição                                                             |
|-----------------|-------------------------------------------------------------------------|
| `versions.tf`   | Define a versão do Terraform e do provider `kind` utilizados            |
| `provider.tf`   | Configuração do provider `kind`                                         |
| `variables.tf`  | Variáveis de entrada (nome do cluster, versão do Kubernetes, etc.)      |
| `main.tf`       | Recurso `kind_cluster` com a topologia (1 control-plane + 2 workers)    |
| `outputs.tf`    | Saídas úteis (nome do cluster, endpoint da API, caminho do kubeconfig)  |

## Componentes criados pelo Kind

Ao provisionar o cluster, o Kind cria e configura, dentro de containers Docker que
simulam nodes de um cluster real, os seguintes componentes:

1. **Nodes como containers Docker**
   Cada "node" do Kubernetes (control-plane e workers) é, na prática, um container
   Docker rodando uma imagem `kindest/node`, que já vem com todos os binários do
   Kubernetes pré-instalados. Ex.: o container `devops-control-plane` representa o
   node de controle; `devops-worker` e `devops-worker2` representam os nodes worker.

2. **kube-apiserver**
   Componente do control-plane que expõe a API REST do Kubernetes. É por meio dele
   que o `kubectl` e o próprio Terraform (via provider `kind`) se comunicam com o
   cluster para criar/consultar recursos.

3. **etcd**
   Banco de dados chave-valor distribuído que armazena todo o estado do cluster
   (objetos, configurações, secrets etc.). Roda apenas no node de control-plane.

4. **kube-scheduler**
   Responsável por decidir em qual node cada novo Pod deve ser executado, com base
   em recursos disponíveis, afinidades e restrições. Ex.: ao criar um Deployment
   com 3 réplicas, o scheduler distribui os Pods entre os 2 workers disponíveis.

5. **kube-controller-manager**
   Executa os "controllers" que mantêm o estado desejado do cluster (ex.: garantir
   que o número de réplicas de um Deployment corresponda ao definido, recriar Pods
   que morreram, etc.).

6. **kubelet e kube-proxy (em todos os nodes)**
   - `kubelet`: agente que roda em cada node e garante que os containers descritos
     nos Pods estejam realmente em execução.
   - `kube-proxy`: implementa as regras de rede que permitem que Services do
     Kubernetes encaminhem tráfego para os Pods corretos.

7. **CNI (rede de Pods) — kindnet**
   O Kind instala por padrão o `kindnet`, um plugin de rede (CNI) simples que
   permite a comunicação entre Pods em nodes diferentes.

8. **CoreDNS**
   Serviço de DNS interno do cluster, que permite que Pods se encontrem por nome
   (ex.: um Pod da aplicação resolvendo `meu-service.default.svc.cluster.local`).

9. **local-path-provisioner (StorageClass padrão)**
   Provisionador de armazenamento local que permite a criação dinâmica de volumes
   persistentes (`PersistentVolume`) usando o disco do node, útil para testes com
   `PersistentVolumeClaim` sem depender de um storage externo.

10. **Rede Docker dedicada ("kind")**
    O Kind cria uma rede Docker própria (bridge) para isolar a comunicação entre os
    containers que representam os nodes do cluster.

11. **Contexto no kubeconfig**
    O provider `kind` gera/atualiza automaticamente um contexto chamado
    `kind-devops` no arquivo de kubeconfig, permitindo o uso imediato do `kubectl`
    apontando para o cluster recém-criado.

## Como reproduzir (passo a passo)

1. Ter Docker Desktop (ou Docker Engine) instalado e em execução.
2. Ter o Terraform instalado (>= 1.5.0).
3. Rodar:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
4. Validar o cluster:
   ```bash
   kubectl cluster-info --context kind-devops
   kubectl get nodes -o wide
   ```
5. (Opcional) Abrir o Lens e conectar ao contexto `kind-devops` para visualizar o
   cluster e os 3 nodes graficamente.
6. Para destruir tudo:
   ```bash
   terraform destroy -auto-approve
   ```

## Evidências

A imagem em `/evidencias` mostra, em uma única captura de tela:
- Saída de `kubectl cluster-info --context kind-devops`, confirmando que o control
  plane e o CoreDNS do cluster `devops` estão em execução.
- Saída de `kubectl get nodes -o wide`, confirmando 1 node `devops-control-plane`
  com role `control-plane` e 2 nodes (`devops-worker`, `devops-worker2`) com role
  `worker`, todos com status `Ready`.


oioioioi