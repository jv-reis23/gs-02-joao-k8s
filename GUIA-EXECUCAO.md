# 🚀 Guia Completo de Execução - UniFIAP Pay SPB

Este guia fornece um passo a passo detalhado e testado para executar e testar todo o projeto do desafio UniFIAP Pay SPB.

> **⚠️ IMPORTANTE:** Siga os passos **exatamente na ordem** apresentada para evitar problemas.

> **📝 NOTA TÉCNICA:** Este projeto usa **hostPath** para volume compartilhado entre pods (ao invés de PVC), pois o Kind não suporta `ReadWriteMany` no provisioner padrão `local-path`. O diretório `/tmp/unifiapay-logs` é criado dentro do node do Kind e montado em todos os pods.

---

## 📋 Pré-requisitos

### Ferramentas Necessárias

1. **Docker** (versão 24.0 ou superior)
   ```bash
   docker --version
   # Se não tiver: https://docs.docker.com/get-docker/
   ```

2. **Docker Compose** (versão 2.0 ou superior)
   ```bash
   docker compose version
   # Já vem incluído no Docker Desktop
   ```

3. **Kind** (Kubernetes in Docker)
   ```bash
   kind --version
   # Se não tiver instalado:
   curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
   chmod +x ./kind
   sudo mv ./kind /usr/local/bin/kind
   ```

4. **kubectl** (CLI do Kubernetes)
   ```bash
   kubectl version --client
   # Se não tiver:
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```

5. **jq** (para formatar JSON nos testes)
   ```bash
   jq --version
   # Se não tiver:
   sudo apt-get install jq -y  # Ubuntu/Debian
   # ou
   brew install jq  # macOS
   ```

6. **Conta no Docker Hub** (para publicar imagens)
   ```bash
   docker login
   # Use suas credenciais do Docker Hub
   # Cadastre-se em: https://hub.docker.com/
   ```

---

## 🎯 PARTE 1: Configuração Inicial

### Passo 1: Clone ou navegue até o repositório

```bash
cd /home/SEU_USUARIO/Documentos/FIAP/CLOUD-DEVELOPER-K8S/gs-02-jvreis23-k8s
```

### Passo 2: Atualizar README com seus dados

Edite o arquivo `README.md` e preencha suas informações:

```bash
# Abrir o arquivo com seu editor favorito
nano README.md
# ou
code README.md
```

Altere as linhas:
```markdown
## Dados do Aluno
- Nome: [SEU NOME COMPLETO AQUI]  
- RM: [SEU RM AQUI]  
```

**Exemplo:**
```markdown
## Dados do Aluno
- Nome: jvreis23 Silva Santos
- RM: 556643
```

### Passo 3: Configurar variáveis de ambiente

Edite o arquivo `docker/.env`:

```bash
nano docker/.env
```

Configure os valores:
```bash
# Valor da reserva bancária inicial (1 milhão de reais)
RESERVA_BANCARIA_SALDO=1000000.00

# Caminho para logs (não alterar)
LOG_PATH=/var/logs/api
```

### Passo 4: Verificar chave PIX

O arquivo `docker/pix.key` já deve existir. Se não existir, crie:

```bash
echo "chave-pix-simulacao-unifiap-$(date +%s)" > docker/pix.key
cat docker/pix.key
```

---

## 🐳 PARTE 2: Build e Publicação das Imagens Docker (Etapa 1 - 1,5 pts)

### Passo 5: Criar pasta de evidências

```bash
mkdir -p evidencias/etapa1-docker
```

### Passo 6: Fazer build das imagens com Multi-Stage

**⚠️ IMPORTANTE:** 
- Substitua `SEU_DOCKERHUB_USER` pelo seu usuário do Docker Hub
- Substitua `SEU_RM` pelo seu RM

```bash
# Build da API de Pagamentos
docker build -t SEU_DOCKERHUB_USER/api-pagamentos:v1.SEU_RM ./api-pagamentos

# Build do Serviço de Auditoria  
docker build -t SEU_DOCKERHUB_USER/auditoria-service:v1.SEU_RM ./auditoria-service
```

**Exemplo real (substitua pelos seus dados):**
```bash
docker build -t jvreis23/api-pagamentos:v1.556643 ./api-pagamentos
docker build -t jvreis23/auditoria-service:v1.556643 ./auditoria-service
```

**📸 EVIDÊNCIA 1.1:** Tire screenshot do terminal mostrando o build multi-stage (você verá "stage-1", "builder", etc.)

### Passo 7: Verificar vulnerabilidades com Docker Scout

```bash
# Criar pasta se não existir
mkdir -p evidencias/etapa1-docker

# Varredura da API
docker scout cves SEU_DOCKERHUB_USER/api-pagamentos:v1.SEU_RM > evidencias/etapa1-docker/03-docker-scout-api.txt

# Varredura da Auditoria
docker scout cves SEU_DOCKERHUB_USER/auditoria-service:v1.SEU_RM > evidencias/etapa1-docker/03-docker-scout-auditoria.txt

# Ver resumo
cat evidencias/etapa1-docker/03-docker-scout-api.txt | head -n 50
```

**📸 EVIDÊNCIA 1.2:** Salve os arquivos `03-docker-scout-*.txt` mostrando análise de vulnerabilidades

### Passo 8: Publicar imagens no Docker Hub

```bash
# Fazer login (se ainda não fez)
docker login

# Push da API
docker push SEU_DOCKERHUB_USER/api-pagamentos:v1.SEU_RM

# Push da Auditoria
docker push SEU_DOCKERHUB_USER/auditoria-service:v1.SEU_RM
```

**Exemplo:**
```bash
docker push jvreis23/api-pagamentos:v1.556643
docker push jvreis23/auditoria-service:v1.556643
```

**📸 EVIDÊNCIA 1.3:** Tire screenshot do `docker push` mostrando o upload bem-sucedido

---

## 🌐 PARTE 3: Testar com Docker Local (Etapa 2 - 2,5 pts)

### Passo 9: Criar pasta de evidências da Etapa 2

```bash
mkdir -p evidencias/etapa2-rede
```

### Passo 10: Subir containers com Docker Compose

```bash
cd docker

# Subir todos os serviços
docker compose up -d

# Aguardar containers iniciarem
sleep 5

# Verificar se estão rodando
docker compose ps
```

**Resultado esperado:**
```
NAME                 STATUS          PORTS
api-pagamentos       Up X seconds    0.0.0.0:8080->8080/tcp
auditoria-service    Up X seconds
```

### Passo 11: Verificar rede Docker customizada (172.25.0.0/24)

```bash
# Inspecionar a rede
docker network inspect docker_unifiap_net > ../evidencias/etapa2-rede/01-docker-network-inspect.txt

# Ver resumo (deve mostrar subnet 172.25.0.0/24)
docker network inspect docker_unifiap_net | grep -A 5 "Subnet"
```

**📸 EVIDÊNCIA 2.1:** Arquivo `01-docker-network-inspect.txt` mostrando subnet `172.25.0.0/24`

### Passo 12: Testar comunicação entre containers

**Nota:** Os containers Python slim não têm o comando `ping`. Vamos usar `curl` para testar comunicação HTTP:

```bash
# Testar comunicação do auditoria-service para api-pagamentos
docker exec auditoria-service curl -s http://172.25.0.10:8080/health > ../evidencias/etapa2-rede/02-curl-auditoria-to-api.txt

# Ver resultado
cat ../evidencias/etapa2-rede/02-curl-auditoria-to-api.txt
```

**Resultado esperado:**
```json
{"status":"healthy","timestamp":"..."}
```

**📸 EVIDÊNCIA 2.2:** Arquivo `02-curl-auditoria-to-api.txt` mostrando comunicação bem-sucedida

### Passo 13: Verificar logs mostrando leitura de RESERVA_BANCARIA_SALDO

```bash
# Capturar logs da API
docker compose logs api-pagamentos | head -n 50 > ../evidencias/etapa2-rede/03-logs-env-vars.txt

# Ver se aparece a reserva bancária
grep "Reserva Bancária" ../evidencias/etapa2-rede/03-logs-env-vars.txt
```

**Resultado esperado:**
```
api-pagamentos  | ... - INFO - Reserva Bancária inicializada: R$ 1000000.0
api-pagamentos  | ... - INFO - Reserva Bancária: R$ 1000000.0
```

**📸 EVIDÊNCIA 2.3:** Arquivo `03-logs-env-vars.txt` mostrando leitura da variável de ambiente

### Passo 14: Testar Fluxo Completo de PIX (IMPORTANTE!)

Este é o teste principal que demonstra o funcionamento do sistema SPB:

```bash
# Ainda dentro do diretório docker/

# 1. Ver saldo inicial
echo "=== SALDO INICIAL ==="
curl -s http://localhost:8080/api/v1/reserva | jq .
```

**Resultado esperado:**
```json
{
  "moeda": "BRL",
  "reserva_bancaria_saldo": 1000000.0
}
```

```bash
# 2. Enviar um PIX de R$ 250,00
echo "=== ENVIANDO PIX DE R$ 250 ==="
curl -s -X POST http://localhost:8080/api/v1/pix \
  -H "Content-Type: application/json" \
  -d '{
    "valor": 250.00,
    "chave_destino": "teste@fiap.com.br",
    "descricao": "Pagamento teste SPB"
  }' | jq .
```

**Resultado esperado:**
```json
{
  "sucesso": true,
  "transacao_id": "PIX-20251110...",
  "mensagem": "Pagamento registrado e aguardando liquidação",
  "valor": 250.0,
  "status": "AGUARDANDO_LIQUIDACAO"
}
```

```bash
# 3. Ver arquivo de instruções ANTES da liquidação
echo "=== ARQUIVO ANTES DA LIQUIDAÇÃO ==="
docker exec api-pagamentos cat /var/logs/api/instrucoes.log
```

**Resultado esperado:**
```json
{"transacao_id":"PIX-...",..."status":"AGUARDANDO_LIQUIDACAO",...}
```

```bash
# 4. Verificar saldo (ainda deve ser 1000000)
echo "=== SALDO ANTES DA LIQUIDAÇÃO ==="
curl -s http://localhost:8080/api/v1/reserva | jq .
```

**Resultado esperado:**
```json
{
  "moeda": "BRL",
  "reserva_bancaria_saldo": 1000000.0
}
```

```bash
# 5. Executar processo de liquidação (simula BACEN/STR)
echo "=== EXECUTANDO LIQUIDAÇÃO ==="
docker compose run --rm auditoria-service python app.py
```

**Resultado esperado no log:**
```
2025-11-10 ... - auditoria-service - INFO - === Iniciando Serviço de Auditoria e Liquidação ===
2025-11-10 ... - liquidacao-service - INFO - Total de instruções no livro-razão: 1
2025-11-10 ... - liquidacao-service - INFO - Transação liquidada: PIX-... - Valor: R$ 250.0
2025-11-10 ... - auditoria-service - INFO - Liquidações processadas: 1
```

```bash
# 6. Ver arquivo DEPOIS da liquidação (status deve mudar para LIQUIDADO)
echo "=== ARQUIVO DEPOIS DA LIQUIDAÇÃO ==="
docker exec api-pagamentos cat /var/logs/api/instrucoes.log
```

**Resultado esperado:**
```json
{"transacao_id":"PIX-...",..."status":"LIQUIDADO","timestamp_liquidacao":"...",...}
```

```bash
# 7. Verificar saldo atualizado (deve ser 999750)
echo "=== SALDO DEPOIS DA LIQUIDAÇÃO ==="
curl -s http://localhost:8080/api/v1/reserva | jq .
```

**Resultado esperado:**
```json
{
  "moeda": "BRL",
  "reserva_bancaria_saldo": 999750.0
}
```

**✅ SUCESSO!** O saldo diminuiu R$ 250,00, comprovando que:
- A API registrou a transação corretamente
- O auditoria-service processou a liquidação
- O saldo foi recalculado baseado nas transações LIQUIDADAS
- O volume compartilhado funciona (ambos containers acessam o mesmo arquivo)

### Passo 15: Testar PIX inválido (valor maior que reserva)

```bash
# Tentar enviar PIX maior que o saldo disponível
curl -s -X POST http://localhost:8080/api/v1/pix \
  -H "Content-Type: application/json" \
  -d '{
    "valor": 99999999.00,
    "chave_destino": "invalido@email.com",
    "descricao": "PIX que deve ser rejeitado"
  }' | jq .
```

**Resultado esperado:**
```json
{
  "sucesso": false,
  "mensagem": "Reserva bancária insuficiente",
  "valor_solicitado": 99999999.0,
  "reserva_disponivel": 999750.0
}
```

**✅ VALIDAÇÃO SPB FUNCIONANDO!** O sistema rejeitou o PIX porque não há saldo suficiente.

### Passo 16: Salvar evidências do fluxo completo

```bash
# Salvar histórico de transações
docker exec api-pagamentos cat /var/logs/api/instrucoes.log > ../evidencias/etapa2-rede/04-historico-transacoes.txt

# Ver resumo
cat ../evidencias/etapa2-rede/04-historico-transacoes.txt
```

### Passo 17: Parar containers Docker (opcional - apenas se for para Kubernetes)

```bash
# Voltar para raiz do projeto
cd ..

# Parar containers
docker compose -f docker/docker-compose.yml down
```

---

## ☸️ PARTE 4: Criar Cluster Kind

### Passo 18: Criar cluster Kubernetes local

```bash
# Criar cluster Kubernetes local
kind create cluster --name unifiapay

# Verificar cluster
kubectl cluster-info --context kind-unifiapay

# Ver nodes
kubectl get nodes
```

**Resultado esperado:**
```
NAME                      STATUS   ROLES           AGE   VERSION
unifiapay-control-plane   Ready    control-plane   ...   v1.27.x
```

### Passo 18.1: Configurar permissões no diretório de logs do Kind

**⚠️ IMPORTANTE:** Como usamos `hostPath` para volume compartilhado no Kind, precisamos criar e configurar permissões no diretório dentro do node do cluster:

```bash
# Criar diretório e definir permissões dentro do node do Kind
docker exec -it unifiapay-control-plane sh -c "mkdir -p /tmp/unifiapay-logs && chmod 777 /tmp/unifiapay-logs"

# Verificar que foi criado
docker exec -it unifiapay-control-plane ls -la /tmp/ | grep unifiapay
```

**Resultado esperado:**
```
drwxrwxrwx 2 root root 4096 Nov 10 12:34 unifiapay-logs
```

---

## ☸️ PARTE 6: Deploy no Kubernetes (Etapa 3 - 3,0 pts)

### Passo 20: Atualizar imagens nos manifests Kubernetes

**⚠️ MUITO IMPORTANTE:** Antes de aplicar os manifests, você DEVE atualizar as imagens com seu Docker Hub user e RM!

#### Arquivo 1: `k8s/05-deployment-api.yaml`

Abra o arquivo:
```bash
nano k8s/05-deployment-api.yaml
```

Procure pela linha (aproximadamente linha 26):
```yaml
image: jvreis23fiap/api-pagamentos:latest
```

**Altere para:**
```yaml
image: SEU_DOCKERHUB_USER/api-pagamentos:v1.SEU_RM
```

**Exemplo:**
```yaml
image: jvreis23/api-pagamentos:v1.556643
```

#### Arquivo 2: `k8s/06-deployment-auditoria.yaml`

Abra o arquivo:
```bash
nano k8s/06-deployment-auditoria.yaml
```

Procure pela linha (aproximadamente linha 26):
```yaml
image: jvreis23fiap/auditoria-service:latest
```

**Altere para:**
```yaml
image: SEU_DOCKERHUB_USER/auditoria-service:v1.SEU_RM
```

#### Arquivo 3: `k8s/08-cronjob-fechamento.yaml`

Abra o arquivo:
```bash
nano k8s/08-cronjob-fechamento.yaml
```

Procure pela linha (aproximadamente linha 17):
```yaml
image: jvreis23fiap/auditoria-service:latest
```

**Altere para:**
```yaml
image: SEU_DOCKERHUB_USER/auditoria-service:v1.SEU_RM
```

**💡 Dica:** Use o comando `sed` para substituir automaticamente:
```bash
# Substituir em todos os arquivos de uma vez (ajuste SEU_USER e SEU_RM)
sed -i 's|jvreis23fiap/api-pagamentos:latest|SEU_DOCKERHUB_USER/api-pagamentos:v1.SEU_RM|g' k8s/05-deployment-api.yaml
sed -i 's|jvreis23fiap/auditoria-service:latest|SEU_DOCKERHUB_USER/auditoria-service:v1.SEU_RM|g' k8s/06-deployment-auditoria.yaml
sed -i 's|jvreis23fiap/auditoria-service:latest|SEU_DOCKERHUB_USER/auditoria-service:v1.SEU_RM|g' k8s/08-cronjob-fechamento.yaml
```

### Passo 21: Fazer deploy no Kubernetes

**Opção 1: Usar o script automatizado (recomendado)**

```bash
# Tornar script executável
chmod +x scripts/deploy-k8s.sh

# Executar deploy
./scripts/deploy-k8s.sh
```

**Opção 2: Aplicar manualmente (passo a passo)**

```bash
# Aplicar na ordem correta
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secret.yaml
kubectl apply -f k8s/09-rbac-serviceaccount.yaml
kubectl apply -f k8s/10-rbac-role.yaml
kubectl apply -f k8s/11-rbac-rolebinding.yaml

# Aplicar deployments e services (PVC não é mais usado, volumes são hostPath)
kubectl apply -f k8s/05-deployment-api.yaml
kubectl apply -f k8s/06-deployment-auditoria.yaml
kubectl apply -f k8s/07-service-api.yaml
kubectl apply -f k8s/08-cronjob-fechamento.yaml
```

**⚠️ NOTA IMPORTANTE:** O projeto usa **hostPath** para volume compartilhado (ao invés de PVC), pois o Kind não suporta `ReadWriteMany` no provisioner padrão. O arquivo `k8s/04-pvc.yaml` está presente mas não é utilizado no deployment.

### Passo 22: Verificar pods rodando

```bash
# Ver todos os recursos do namespace
kubectl get all -n unifiapay

# Ver pods específicos
kubectl get pods -n unifiapay

# Aguardar pods ficarem Running
kubectl wait --for=condition=ready pod -l app=api-pagamentos -n unifiapay --timeout=120s
```

**Resultado esperado:**
```
NAME                                READY   STATUS    RESTARTS   AGE
pod/api-pagamentos-xxxxx            1/1     Running   0          30s
pod/api-pagamentos-yyyyy            1/1     Running   0          30s
pod/auditoria-service-zzzzz         1/1     Running   0          30s
```

**📸 EVIDÊNCIA 3.1:** Capture `kubectl get pods -n unifiapay` mostrando **2 réplicas** da API

### Passo 23: Ver logs dos pods

```bash
# Logs da API (primeiro pod)
kubectl logs -l app=api-pagamentos -n unifiapay --tail=50

# Logs da Auditoria
kubectl logs -l app=auditoria-service -n unifiapay --tail=50

# Se der erro, liste os pods e escolha um específico
kubectl get pods -n unifiapay
kubectl logs pod/NOME_DO_POD -n unifiapay
```

---

## 🐮 PARTE 5: Setup do Rancher (Gerenciamento Visual)

### Passo 19: O que é o Rancher e por que usar?

O **Rancher** é uma plataforma de gerenciamento de containers que fornece uma interface web intuitiva para administrar clusters Kubernetes.

**Benefícios para este projeto:**
- 🖥️ **Interface Visual:** Gerenciar pods, deployments e services sem comandos kubectl
- 📊 **Logs em Tempo Real:** Visualizar logs de qualquer pod diretamente no navegador
- 🔍 **Debug Intuitivo:** Identificar problemas mais rapidamente
- 📈 **Métricas:** Acompanhar CPU e memória dos pods
- ⚙️ **Gerenciamento Fácil:** Editar configurações, escalar pods, reiniciar serviços

---

## 📋 GUIA COMPLETO: Configurando SUSE Rancher para Gerenciar Clusters Kind Locais

Este guia documenta o processo completo para instalar o Rancher Desktop (para ter o Docker), rodar o Servidor SUSE Rancher (o painel de gerenciamento) em um contêiner Docker e, finalmente, importar um cluster `kind` (Kubernetes in Docker) local para gerenciamento.

**⚠️ A principal dificuldade é a configuração de rede, que é resolvida na Etapa 4 abaixo.**

---

### 1. Instalação do Rancher Desktop (Base)

O Rancher Desktop fornece o motor Docker (`dockerd (moby)`) necessário para rodar tanto o servidor Rancher quanto o cluster `kind`.

#### A. Instalar Dependências

```bash
sudo apt update
sudo apt install -y curl gpg pass
```

#### B. Adicionar Repositório Oficial do Rancher Desktop

```bash
# Adicionar a chave GPG
curl -s https://download.opensuse.org/repositories/isv:/Rancher:/stable/deb/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/isv-rancher-stable-archive-keyring.gpg > /dev/null

# Adicionar o repositório
echo 'deb [signed-by=/usr/share/keyrings/isv-rancher-stable-archive-keyring.gpg] https://download.opensuse.org/repositories/isv:/Rancher:/stable/deb/ ./' | sudo tee /etc/apt/sources.list.d/isv-rancher-stable.list > /dev/null
```

#### C. Instalar e Configurar

```bash
sudo apt update
sudo apt install rancher-desktop
```

**Após a instalação:**
1. Reinicie o computador (ou faça logout e login novamente)
2. Na primeira inicialização do aplicativo, configure:
   - **Container Engine:** `dockerd (moby)`
   - **Configure PATH:** `Automatic`

---

### 2. Instalação do SUSE Rancher Server (Painel de Gerenciamento)

Rodamos o painel central do Rancher (o servidor) dentro de um contêiner Docker.

#### A. Iniciar Contêiner do Servidor

```bash
sudo docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  rancher/rancher:latest
```

#### B. Configuração Inicial do Painel

1. **Aguarde 2-3 minutos** e acesse https://localhost no seu navegador
2. **Ignore o aviso de "Não seguro"** (certificado auto-assinado)
3. **Obtenha a senha de bootstrap:**

```bash
# Primeiro, encontre o ID do container
sudo docker ps

# Use o ID do container para pegar a senha
sudo docker logs <ID_DO_CONTAINER> 2>&1 | grep "Bootstrap Password:"
```

4. **Cole a senha no navegador**
5. **Crie sua nova senha de admin** e finalize a configuração inicial

---

### 3. Criação do Cluster Kind

Crie o cluster Kubernetes de desenvolvimento que será importado para o Rancher.

```bash
# O nome 'unifiapay' cria um contexto 'kind-unifiapay'
kind create cluster --name unifiapay
```

---

### 4. Importando o Cluster Kind (Com Correção de Rede) ⚠️ CRÍTICO

**Esta é a etapa crucial.** O contêiner do kind (que está em uma rede Docker própria) precisa enxergar o contêiner do Servidor Rancher (que está na rede bridge padrão). A solução é usar o **IP da máquina host** (seu Ubuntu).

#### A. Encontrar o IP do Host

No terminal do seu Ubuntu, encontre seu IP de rede local (LAN):

```bash
hostname -I
```

**Anote o IP principal** (exemplo: `192.168.0.9` ou `192.168.1.100`)

#### B. Configurar o server-url no Painel Rancher

1. No painel do Rancher (em https://localhost), vá para o menu **☰ > Global Settings**
2. Encontre a configuração **`server-url`**
3. Clique nos **três pontinhos ( ⋮ )** e em **"Edit Setting"**
4. Defina o valor para o **IP do seu host** (ex: `https://192.168.0.9`)
5. Clique em **"Save"**

#### C. Importar o Cluster no Painel

1. No painel, vá para **☰ > Cluster Management**
2. Clique em **"Import Existing"**
3. Escolha **"Generic"**
4. Dê um nome (ex: `unifiapay-kind`)
5. Clique em **"Create"**
6. Na tela de registro, **copie o segundo comando** (o que começa com `curl --insecure...`)
   - ⚠️ Este comando agora conterá o IP do seu host!

#### D. Executar Comandos de Importação no Terminal

Execute estes dois comandos no seu terminal:

```bash
# 1. Ative o contexto do cluster kind
kubectl config use-context kind-unifiapay

# 2. Cole o comando 'curl' copiado do painel (com o IP do seu host)
# Exemplo (SUBSTITUA pela URL real gerada pelo Rancher):
curl --insecure -sfL https://192.168.0.9/v3/import/xxxxxxxxxxxxx.yaml | kubectl apply -f -
```

**⏳ Aguarde 1 ou 2 minutos**, e o cluster aparecerá como **"Active"** no painel do Rancher!

---

### 5. Verificação Final

#### No Painel Rancher:

1. **Cluster Management** → Deve ver `unifiapay-kind` com status **Active** ✅
2. **Clique no cluster** → **Workloads** → **Pods**
3. **Selecione namespace:** `unifiapay`
4. **Verifique pods visíveis:**
   - `api-pagamentos-xxxxx` (2 réplicas)
   - `auditoria-service-xxxxx` (1 réplica)

#### No Terminal:

```bash
# Verificar que kubectl funciona
kubectl get pods -n unifiapay

# Verificar contexto
kubectl config current-context
# Deve retornar: kind-unifiapay
```

---

### 6. Troubleshooting Comum

**Problema:** Cluster fica "Pending" ou "Waiting"

**Solução:**
```bash
# Verificar logs do agente Rancher no cluster
kubectl logs -n cattle-system -l app=rancher

# Verificar se o server-url está correto
kubectl get settings.management.cattle.io server-url -o yaml
```

**Problema:** Erro de certificado SSL

**Solução:** O comando `curl --insecure` já ignora validação SSL. Certifique-se de copiar o comando completo do painel.

**Problema:** Pods do Rancher não iniciam

**Solução:**
```bash
# Verificar pods do sistema Rancher
kubectl get pods -n cattle-system

# Ver logs de algum pod com problema
kubectl logs -n cattle-system <POD_NAME>
```

---

### 7. Comandos Úteis do Rancher

```bash
# Ver logs do servidor Rancher
sudo docker logs -f <RANCHER_CONTAINER_ID>

# Verificar status do container
sudo docker ps | grep rancher

# Parar Rancher (mantém dados)
sudo docker stop <RANCHER_CONTAINER_ID>

# Reiniciar Rancher
sudo docker restart <RANCHER_CONTAINER_ID>

# Remover Rancher completamente
sudo docker stop <RANCHER_CONTAINER_ID>
sudo docker rm <RANCHER_CONTAINER_ID>

# Resetar senha administrativa (se esquecer)
sudo docker exec -it <RANCHER_CONTAINER_ID> reset-password
```

---

**✅ Configuração Completa!** Agora você pode gerenciar seu cluster Kind visualmente através do painel Rancher.

---

### Passo 15.2: Instalar Rancher com Docker (Recomendado)

**Opção A - Usar Script Automatizado (Mais Fácil):**

```bash
# Tornar script executável
chmod +x scripts/setup-rancher.sh

# Executar setup
./scripts/setup-rancher.sh
```

O script irá:
- ✅ Verificar se Docker está rodando
- ✅ Criar container Rancher
- ✅ Aguardar inicialização
- ✅ Extrair senha de bootstrap
- ✅ Salvar credenciais em `evidencias/rancher/01-bootstrap-password.txt`

**Opção B - Manual:**

```bash
# Subir container Rancher
docker run -d \
  --name rancher \
  --restart=unless-stopped \
  -p 8080:80 -p 8443:443 \
  --privileged \
  rancher/rancher:latest

# Aguardar 1-2 minutos para inicializar
sleep 60

# Obter senha de bootstrap
docker logs rancher 2>&1 | grep "Bootstrap Password:"
```

**Resultado esperado:**
```
Bootstrap Password: abc123def456ghi789jkl012mno345pqr
```

### Passo 15.3: Acessar Interface Web do Rancher

1. **Abrir navegador:** https://localhost:8443

2. **Aceitar certificado auto-assinado:**
   - Chrome/Edge: "Avançado" → "Continuar para localhost (não seguro)"
   - Firefox: "Avançado" → "Aceitar o risco e continuar"

3. **Fazer login:**
   - Usar senha de bootstrap obtida no passo anterior

4. **Definir nova senha:**
   - Criar senha administrativa permanente
   - Exemplo: `UniFIAP@2024`
   - Confirmar senha

5. **Configurações iniciais:**
   - Server URL: deixar padrão `https://localhost:8443`
   - Clicar em "Save URL"

**📸 EVIDÊNCIA RANCHER 1:** Screenshot da tela de login/dashboard inicial

### Passo 15.4: Conectar Cluster Kind ao Rancher

1. **No Rancher, clicar em "Cluster Management"** (menu hambúrguer no canto superior esquerdo)

2. **Clicar em "Import Existing"**

3. **Selecionar "Generic"** (Kubernetes genérico)

4. **Configurar cluster:**
   - **Cluster Name:** `unifiapay-kind`
   - Deixar outras opções padrão

5. **Clicar em "Create"**

6. **Copiar comando kubectl apply:**
   - Rancher irá gerar um comando parecido com:
   ```bash
   kubectl apply -f https://localhost:8443/v3/import/xxxxxxxxxxxxx.yaml
   ```

7. **Executar comando no terminal:**
   ```bash
   # Verificar que está no contexto correto
   kubectl config current-context
   # Deve retornar: kind-unifiapay
   
   # Executar comando copiado do Rancher
   kubectl apply -f https://localhost:8443/v3/import/xxxxxxxxxxxxx.yaml
   ```

8. **Aguardar 30-60 segundos**

9. **Verificar no Rancher:**
   - O cluster `unifiapay-kind` deve aparecer com status **"Active"** e ícone verde

**📸 EVIDÊNCIA RANCHER 2:** Screenshot mostrando cluster `unifiapay-kind` conectado e ativo

### Passo 15.5: Explorar Namespace `unifiapay` no Rancher

1. **Clicar no cluster `unifiapay-kind`**

2. **Ir em "Workloads" → "Pods"** (menu lateral esquerdo)

3. **Filtrar por namespace:**
   - No dropdown superior, selecionar: `unifiapay`

4. **Verificar pods visíveis:**
   - `api-pagamentos-xxxxx` (deve ter 2 réplicas)
   - `api-pagamentos-yyyyy`
   - `auditoria-service-zzzzz`

5. **Ver detalhes de um pod:**
   - Clicar em qualquer pod
   - Ver informações: Status, IP, Node, Resources, etc.

**📸 EVIDÊNCIA RANCHER 3:** Screenshot da lista de pods no namespace `unifiapay`

### Passo 15.6: Visualizar CronJob no Rancher

1. **Ir em "Workloads" → "CronJobs"**

2. **Verificar:**
   - Nome: `cronjob-fechamento-reserva`
   - Schedule: `0 */6 * * *` (a cada 6 horas)
   - Last Schedule: timestamp da última execução (se já executou)

3. **Clicar no CronJob para ver detalhes:**
   - Ver configuração completa
   - Histórico de Jobs executados

**📸 EVIDÊNCIA RANCHER 4:** Screenshot do CronJob visível no Rancher

### Passo 15.7: Ver Logs em Tempo Real

1. **Ir em "Workloads" → "Pods"**

2. **Clicar em um pod da API** (ex: `api-pagamentos-xxxxx`)

3. **Clicar em "View Logs"** (botão no canto superior direito)

4. **Observar logs em tempo real:**
   - Deve ver logs da aplicação Flask
   - Mensagens de inicialização
   - Requisições HTTP (se houver)

5. **Testar logs durante transação:**
   ```bash
   # Em outro terminal, enviar PIX
   kubectl -n unifiapay port-forward svc/api-pagamentos-service 30080:8080 &
   curl -s -X POST http://localhost:30080/api/v1/pix \
     -H "Content-Type: application/json" \
     -d '{"valor": 100, "chave_destino": "teste@fiap.com", "descricao": "Teste Rancher"}'
   ```

6. **No Rancher, ver log aparecer em tempo real**

**📸 EVIDÊNCIA RANCHER 5:** Screenshot de logs em tempo real mostrando transações PIX

### Passo 15.8: Monitorar Recursos (CPU/Memória)

1. **Ir em "Workloads" → "Pods"**

2. **Observar colunas de recursos:**
   - CPU usage
   - Memory usage
   - Status

3. **Clicar em um pod → aba "Metrics":**
   - Gráficos de CPU ao longo do tempo
   - Gráficos de memória ao longo do tempo

**Nota:** Métricas podem levar alguns minutos para aparecer.

### Passo 15.9: Salvar Evidências do Rancher

```bash
# Criar pasta se não existir
mkdir -p evidencias/rancher

# Senha de bootstrap já foi salva automaticamente pelo script em:
# evidencias/rancher/01-bootstrap-password.txt

# Capturar informações do container
docker ps | grep rancher > evidencias/rancher/02-rancher-container.txt

# Capturar logs de inicialização
docker logs rancher | head -n 100 > evidencias/rancher/03-rancher-init-logs.txt

# Screenshots (fazer manualmente):
# - Dashboard com cluster conectado
# - Pods do namespace unifiapay
# - CronJob
# - Logs em tempo real
# Salvar como:
# - evidencias/rancher/04-dashboard-screenshot.png
# - evidencias/rancher/05-pods-namespace.png
# - evidencias/rancher/06-cronjob-view.png
# - evidencias/rancher/07-logs-realtime.png
```

**📸 EVIDÊNCIAS RANCHER - Checklist:**
- [ ] `01-bootstrap-password.txt` - ✅ Auto-gerado
- [ ] `02-rancher-container.txt` - ✅ Comando acima
- [ ] `03-rancher-init-logs.txt` - ✅ Comando acima
- [ ] `04-dashboard-screenshot.png` - ⚠️ Manual
- [ ] `05-pods-namespace.png` - ⚠️ Manual
- [ ] `06-cronjob-view.png` - ⚠️ Manual
- [ ] `07-logs-realtime.png` - ⚠️ Manual

### Passo 15.10: Comandos Úteis do Rancher

```bash
# Ver logs do Rancher
docker logs -f rancher

# Verificar status do container
docker ps | grep rancher

# Parar Rancher (mantém dados)
docker stop rancher

# Reiniciar Rancher
docker restart rancher

# Remover Rancher completamente
docker stop rancher && docker rm rancher

# Resetar senha administrativa (se esquecer)
docker exec -it rancher reset-password
```

---

## 🧪 PARTE 7: Testar a API no Kubernetes

### Passo 24: Testar API com port-forward

**Opção 1: Usar o script automatizado (mais fácil)**

```bash
# Tornar script executável
chmod +x scripts/test-api.sh

# Executar testes (o script inicia port-forward automaticamente)
./scripts/test-api.sh
```

O script fará:
- ✅ Iniciar port-forward automaticamente (localhost:30080 → service:8080)
- ✅ Health check
- ✅ Consultar reserva bancária
- ✅ Enviar PIX válido (R$ 100)
- ✅ Enviar PIX inválido (valor > reserva)
- ✅ Encerrar port-forward automaticamente

**Opção 2: Testar manualmente**

```bash
# Terminal 1: Iniciar port-forward (deixe rodando)
kubectl -n unifiapay port-forward svc/api-pagamentos-service 30080:8080
```

```bash
# Terminal 2: Executar testes
# Health check
curl -s http://localhost:30080/health | jq .

# Consultar reserva
curl -s http://localhost:30080/api/v1/reserva | jq .

# Enviar PIX
curl -s -X POST http://localhost:30080/api/v1/pix \
  -H "Content-Type: application/json" \
  -d '{
    "valor": 100.00,
    "chave_destino": "teste@fiap.com.br",
    "descricao": "Teste PIX Kubernetes"
  }' | jq .
```

**Quando terminar:** Pressione `Ctrl+C` no Terminal 1 para parar o port-forward.

---

## 📊 PARTE 8: Validar Volume Compartilhado (Livro-Razão)

### Passo 25: Verificar arquivo compartilhado entre pods

Este passo comprova que todos os pods (API e Auditoria) compartilham o mesmo volume hostPath e conseguem ler/escrever no mesmo arquivo `instrucoes.log`.

```bash
# Listar pods para pegar os nomes
kubectl get pods -n unifiapay

# Acessar primeiro pod da API
POD1=$(kubectl get pods -n unifiapay -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}')
echo "Pod 1 da API: $POD1"
kubectl exec -n unifiapay $POD1 -- cat /var/logs/api/instrucoes.log > evidencias/etapa3-k8s/03-volume-compartilhado-api-pod1.txt

# Acessar segundo pod da API
POD2=$(kubectl get pods -n unifiapay -l app=api-pagamentos -o jsonpath='{.items[1].metadata.name}')
echo "Pod 2 da API: $POD2"
kubectl exec -n unifiapay $POD2 -- cat /var/logs/api/instrucoes.log > evidencias/etapa3-k8s/03-volume-compartilhado-api-pod2.txt

# Acessar pod de Auditoria
POD_AUDIT=$(kubectl get pods -n unifiapay -l app=auditoria-service -o jsonpath='{.items[0].metadata.name}')
echo "Pod Auditoria: $POD_AUDIT"
kubectl exec -n unifiapay $POD_AUDIT -- cat /var/logs/api/instrucoes.log > evidencias/etapa3-k8s/03-volume-compartilhado-auditoria.txt

# Comparar arquivos para confirmar que são idênticos
echo "=== COMPARANDO ARQUIVOS ==="
diff evidencias/etapa3-k8s/03-volume-compartilhado-api-pod1.txt evidencias/etapa3-k8s/03-volume-compartilhado-api-pod2.txt
diff evidencias/etapa3-k8s/03-volume-compartilhado-api-pod1.txt evidencias/etapa3-k8s/03-volume-compartilhado-auditoria.txt
```

**✅ VALIDAÇÃO:** O comando `diff` não deve retornar nenhuma diferença (saída vazia), comprovando que todos os três pods acessam **EXATAMENTE o mesmo arquivo** através do volume hostPath compartilhado!

**📸 EVIDÊNCIA 3.2:** Salve os 3 arquivos gerados e capture o resultado do `diff` mostrando que são idênticos

---

## 📈 PARTE 9: Testar Escala Horizontal

### Passo 26: Escalar réplicas da API

```bash
# Ver estado atual (deve ter 2 réplicas)
kubectl get deployment api-pagamentos -n unifiapay

# Escalar para 3 réplicas
kubectl scale deployment api-pagamentos --replicas=3 -n unifiapay

# Acompanhar criação do novo pod
kubectl get pods -n unifiapay -l app=api-pagamentos -w
# Aguarde até ver 3 pods com status Running
# Pressione Ctrl+C para parar o watch
```

**Resultado esperado:**
```
NAME                              READY   STATUS    RESTARTS   AGE
api-pagamentos-xxxxx              1/1     Running   0          5m
api-pagamentos-yyyyy              1/1     Running   0          5m
api-pagamentos-zzzzz              1/1     Running   0          10s  <-- Novo pod
```

**📸 EVIDÊNCIA 3.3:** Capture `kubectl scale` e depois `kubectl get pods` mostrando **3 réplicas**

### Passo 27: Voltar para 2 réplicas

```bash
kubectl scale deployment api-pagamentos --replicas=2 -n unifiapay

# Verificar
kubectl get pods -n unifiapay -l app=api-pagamentos
```

---

## ⏰ PARTE 10: Testar CronJob de Liquidação Automática

### Passo 28: Entender o CronJob (Simula BACEN/STR)

O CronJob `cronjob-fechamento-reserva` simula o **Sistema de Transferência de Reservas (STR)** do Banco Central, que processa liquidações em horários programados.

**Configuração atual:** `schedule: "0 */6 * * *"` → Executa a cada 6 horas

```bash
# Ver configuração do CronJob
kubectl get cronjob -n unifiapay

# Ver detalhes incluindo schedule
kubectl describe cronjob cronjob-fechamento-reserva -n unifiapay
```

**📸 EVIDÊNCIA 4.1:** Capture `kubectl describe cronjob` mostrando o **schedule configurado**

### Passo 29: Testar liquidação manual (sem esperar CronJob)

Para não precisar aguardar 6 horas, vamos criar um Job manual:

```bash
# Criar Job a partir do CronJob
kubectl create job liquidacao-manual --from=cronjob/cronjob-fechamento-reserva -n unifiapay

# Acompanhar execução
kubectl get jobs -n unifiapay -w
# Aguarde status: COMPLETIONS = 1/1
# Pressione Ctrl+C

# Ver logs do Job
kubectl logs -n unifiapay -l job-name=liquidacao-manual

# Ver arquivo atualizado
POD=$(kubectl get pods -n unifiapay -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n unifiapay $POD -- cat /var/logs/api/instrucoes.log
```

**✅ VALIDAÇÃO:** As transações devem ter status **LIQUIDADO** e o saldo deve ter diminuído!

**📸 EVIDÊNCIA 4.2:** Capture:
1. `kubectl create job` (criação do Job manual)
2. `kubectl logs` (logs mostrando processamento)
3. Arquivo instrucoes.log com status=LIQUIDADO

### Passo 30: Limpar Job manual

```bash
kubectl delete job liquidacao-manual -n unifiapay
```

---

## 🔐 PARTE 11: Validar Segurança (RBAC + Security Context)

### Passo 31: Verificar RBAC configurado

```bash
# Ver ServiceAccount
kubectl get serviceaccount -n unifiapay

# Ver Role (permissões)
kubectl get role -n unifiapay
kubectl describe role unifiapay-role -n unifiapay > evidencias/etapa4-seguranca/01-rbac-role.txt

# Ver RoleBinding (associação)
kubectl get rolebinding -n unifiapay
kubectl describe rolebinding unifiapay-rolebinding -n unifiapay > evidencias/etapa4-seguranca/02-rbac-rolebinding.txt
```

**✅ VALIDAÇÃO:** Deve mostrar que o ServiceAccount `unifiapay-sa` tem permissões de **get, list, watch** em **pods e services**.

**📸 EVIDÊNCIA 4.3:** Capture `kubectl describe role` e `kubectl describe rolebinding`

### Passo 32: Verificar Security Context

```bash
# Ver configuração de segurança da API
kubectl get deployment api-pagamentos -n unifiapay -o yaml | grep -A 10 securityContext > evidencias/etapa4-seguranca/03-security-context-api.txt

# Ver configuração de segurança da Auditoria
kubectl get deployment auditoria-service -n unifiapay -o yaml | grep -A 10 securityContext > evidencias/etapa4-seguranca/04-security-context-auditoria.txt

# Visualizar
cat evidencias/etapa4-seguranca/03-security-context-api.txt
```

**✅ VALIDAÇÃO:** Deve mostrar:
- `runAsNonRoot: true` → Não executa como root
- `readOnlyRootFilesystem: false` → Filesystem read-write (necessário para logs)
- `allowPrivilegeEscalation: false` → Sem escalada de privilégios
- `runAsUser: 1000` → Executa como usuário não-privilegiado

**📸 EVIDÊNCIA 4.4:** Capture saída mostrando **securityContext** configurado

### Passo 32.1: Testar permissões RBAC

```bash
# Criar pasta para evidências de permissões
mkdir -p evidencias/etapa4-seguranca

# Testar permissões da ServiceAccount unifiapay-sa
echo "=== TESTANDO PERMISSÕES RBAC ===" > evidencias/etapa4-seguranca/05-rbac-permissions-test.txt

# Testar listar pods (DEVE retornar 'yes')
echo "Pode listar pods?" >> evidencias/etapa4-seguranca/05-rbac-permissions-test.txt
kubectl auth can-i list pods -n unifiapay --as=system:serviceaccount:unifiapay:unifiapay-sa >> evidencias/etapa4-seguranca/05-rbac-permissions-test.txt

# Testar deletar pods (DEVE retornar 'no')
echo "Pode deletar pods?" >> evidencias/etapa4-seguranca/05-rbac-permissions-test.txt
kubectl auth can-i delete pods -n unifiapay --as=system:serviceaccount:unifiapay:unifiapay-sa >> evidencias/etapa4-seguranca/05-rbac-permissions-test.txt

# Testar criar deployments (DEVE retornar 'no')
echo "Pode criar deployments?" >> evidencias/etapa4-seguranca/05-rbac-permissions-test.txt
kubectl auth can-i create deployments -n unifiapay --as=system:serviceaccount:unifiapay:unifiapay-sa >> evidencias/etapa4-seguranca/05-rbac-permissions-test.txt

# Ver resultado
cat evidencias/etapa4-seguranca/05-rbac-permissions-test.txt
```

**✅ VALIDAÇÃO:** 
- Listar pods: **yes** ✓
- Deletar pods: **no** ✓
- Criar deployments: **no** ✓

Isso prova que o RBAC está configurado corretamente com **permissões restritas** (apenas leitura).

**📸 EVIDÊNCIA 4.5:** Arquivo `05-rbac-permissions-test.txt` mostrando permissões restritas

---

##  PARTE 12: Coleta Completa de Evidências

Este checklist garante que você coletou todas as evidências necessárias para atingir a nota máxima (9,0 pontos).

### ✅ Etapa 1: Docker e Imagem Segura (1,5 pts)

- [ ] **EVIDÊNCIA 1.1:** Screenshot do `docker build` mostrando multi-stage build (layers sendo criadas)
- [ ] **EVIDÊNCIA 1.2:** Screenshot do `docker push` com tag `v1.SEU_RM` sendo enviada ao Docker Hub
- [ ] **EVIDÊNCIA 1.3:** Output do `docker scout cves` mostrando scan de vulnerabilidades
- [ ] **EVIDÊNCIA 1.4:** Screenshot do `docker images` mostrando tamanho reduzido da imagem (< 200MB)

**Comando para capturar:**
```bash
ls -lh evidencias/etapa1-docker/
```

### ✅ Etapa 2: Rede, Comunicação e Segmentação (2,5 pts)

- [ ] **EVIDÊNCIA 2.1:** Output de `docker network inspect unifiap_net` mostrando subnet 172.25.0.0/24
- [ ] **EVIDÊNCIA 2.2:** Logs de ping/curl entre containers `api-pagamentos` e `auditoria-service`
- [ ] **EVIDÊNCIA 2.3:** Logs da API mostrando leitura de `RESERVA_BANCARIA_SALDO` da variável de ambiente
- [ ] **EVIDÊNCIA 2.4:** Screenshot do arquivo `instrucoes.log` com transações PIX registradas

**Comando para capturar:**
```bash
ls -lh evidencias/etapa2-rede/
```

### ✅ Etapa 3: Kubernetes – Estrutura, Escala e Deploy (3,0 pts)

- [ ] **EVIDÊNCIA 3.1:** `kubectl get pods -n unifiapay` mostrando **2 réplicas** da API em Running
- [ ] **EVIDÊNCIA 3.2:** Logs dos 3 pods (2 API + 1 Auditoria) mostrando **mesmo arquivo** instrucoes.log
- [ ] **EVIDÊNCIA 3.3:** `kubectl scale` e `kubectl get pods` mostrando aumento para **3 réplicas**
- [ ] **EVIDÊNCIA 3.4:** PIX transaction flow completo:
  - Saldo inicial: R$ 1.000.000
  - Envio PIX R$ 250 (status: AGUARDANDO_LIQUIDACAO)
  - Execução liquidação manual
  - Arquivo atualizado (status: LIQUIDADO)
  - Saldo final: R$ 999.750

**Comando para capturar:**
```bash
ls -lh evidencias/etapa3-k8s/
```

### ✅ Etapa 4: Kubernetes – Segurança, Observação e Operação (2,0 pts)

- [ ] **EVIDÊNCIA 4.1:** `kubectl describe cronjob` mostrando schedule configurado (`*/5 * * * *`)
- [ ] **EVIDÊNCIA 4.2:** Logs do Job manual de liquidação processando transações
- [ ] **EVIDÊNCIA 4.3:** `kubectl describe role` e `kubectl describe rolebinding` mostrando RBAC
- [ ] **EVIDÊNCIA 4.4:** Output do `kubectl get deployment -o yaml` mostrando `securityContext`:
  - `runAsNonRoot: true`
  - `readOnlyRootFilesystem: true`
  - `allowPrivilegeEscalation: false`
- [ ] **EVIDÊNCIA 4.5:** `kubectl auth can-i` mostrando permissões restritas da ServiceAccount

**Comando para capturar:**
```bash
ls -lh evidencias/etapa4-seguranca/
```

### 📊 Verificação Final

```bash
# Contar arquivos de evidências
echo "=== EVIDÊNCIAS COLETADAS ==="
echo "Etapa 1 (Docker):"
ls evidencias/etapa1-docker/ | wc -l
echo ""
echo "Etapa 2 (Rede):"
ls evidencias/etapa2-rede/ | wc -l
echo ""
echo "Etapa 3 (Kubernetes):"
ls evidencias/etapa3-k8s/ | wc -l
echo ""
echo "Etapa 4 (Segurança):"
ls evidencias/etapa4-seguranca/ | wc -l
```

**Meta:** Mínimo de **15 arquivos de evidências** distribuídos pelas 4 etapas.

---

## 🧹 PARTE 13: Limpeza e Encerramento

### Passo 33: Salvar evidências finais

Antes de deletar o ambiente, garanta que salvou todas as evidências:

```bash
# Criar arquivo resumo
cat > evidencias/RESUMO-EXECUCAO.txt << EOF
=== UNIFIPAY SPB - RESUMO DE EXECUÇÃO ===
Aluno: [SEU NOME]
RM: [SEU RM]
Data: $(date)

DOCKER IMAGES:
$(docker images | grep -E "api-pagamentos|auditoria-service")

KUBERNETES RESOURCES:
Namespace: unifiapay
Pods: $(kubectl get pods -n unifiapay --no-headers | wc -l)
Services: $(kubectl get svc -n unifiapay --no-headers | wc -l)
PVC: $(kubectl get pvc -n unifiapay --no-headers | wc -l)
CronJob: $(kubectl get cronjob -n unifiapay --no-headers | wc -l)

TRANSAÇÕES PROCESSADAS:
$(POD=$(kubectl get pods -n unifiapay -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}'); kubectl exec -n unifiapay $POD -- wc -l /var/logs/api/instrucoes.log 2>/dev/null || echo "0")

STATUS: ✅ CONCLUÍDO
EOF

cat evidencias/RESUMO-EXECUCAO.txt
```

### Passo 34: Deletar recursos Kubernetes (opcional)

```bash
# Deletar todos os recursos do namespace
kubectl delete namespace unifiapay

# Verificar que foi deletado
kubectl get ns | grep unifiapay
```

### Passo 35: Deletar cluster Kind (opcional)

```bash
# Deletar cluster
kind delete cluster --name unifiapay

# Verificar clusters restantes
kind get clusters
```

### Passo 36: Limpar containers Docker (opcional)

```bash
# Parar containers se ainda estiverem rodando
docker compose -f docker/docker-compose.yml down

# Remover rede Docker
docker network rm unifiap_net

# Remover volumes (CUIDADO: apaga dados)
docker volume prune -f
```

### Passo 37: Remover imagens locais (opcional)

```bash
# Remover apenas imagens do projeto
docker rmi SEU_DOCKERHUB_USER/api-pagamentos:v1.SEU_RM
docker rmi SEU_DOCKERHUB_USER/auditoria-service:v1.SEU_RM

# Ou limpar todas imagens não utilizadas
docker image prune -a
```

---

## 🆘 PARTE 14: Troubleshooting e Soluções Comuns

### ❌ Problema 1: Pods não iniciam (ImagePullBackOff)

**Sintoma:**
```bash
kubectl get pods -n unifiapay
# NAME                    READY   STATUS             RESTARTS   AGE
# api-pagamentos-xxxxx    0/1     ImagePullBackOff   0          2m
```

**Causa:** Imagem não existe no Docker Hub ou nome incorreto.

**Solução:**
```bash
# 1. Verificar se fez push da imagem
docker images | grep api-pagamentos

# 2. Verificar nome da imagem no manifest
kubectl get deployment api-pagamentos -n unifiapay -o yaml | grep image:

# 3. Fazer push novamente
docker push SEU_DOCKERHUB_USER/api-pagamentos:v1.SEU_RM

# 4. Reiniciar deployment
kubectl rollout restart deployment api-pagamentos -n unifiapay
```

### ❌ Problema 2: PVC fica Pending
### ❌ Problema 2: PVC fica Pending

**Sintoma:**
```bash
kubectl get pvc -n unifiapay
# NAME                   STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# unifiapay-logs-pvc     Pending                                      standard       2m
```

**⚠️ NOTA:** Este projeto usa **hostPath** para volumes, então PVC não é mais utilizado. Se você aplicou o `04-pvc.yaml` por engano, pode ignorar ou deletar:

```bash
kubectl delete pvc unifiapay-logs-pvc -n unifiapay
```

**Explicação:** O Kind não suporta `ReadWriteMany` no provisioner padrão. Por isso, mudamos para `hostPath` que permite que múltiplos pods acessem o mesmo diretório `/tmp/unifiapay-logs` dentro do node do Kind.

### ❌ Problema 3: Port-forward não funciona

**Sintoma:**
```bash
kubectl port-forward svc/api-pagamentos-service 30080:8080 -n unifiapay
# Error: unable to forward port...
```

**Solução:**
```bash
# 1. Verificar se service existe
kubectl get svc -n unifiapay

# 2. Verificar se pods estão Running
kubectl get pods -n unifiapay

# 3. Verificar endpoints do service
kubectl get endpoints api-pagamentos-service -n unifiapay

# 4. Se vazio, aguardar pods iniciarem
kubectl wait --for=condition=ready pod -l app=api-pagamentos -n unifiapay --timeout=120s

# 5. Tentar port-forward diretamente no pod
POD=$(kubectl get pods -n unifiapay -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward pod/$POD 30080:8080 -n unifiapay
```

### ❌ Problema 4: Saldo não diminui após PIX

**Sintoma:** Enviei PIX de R$ 250 mas saldo continua R$ 1.000.000

**Causa:** Liquidação não foi executada (transação ficou AGUARDANDO_LIQUIDACAO).

**Solução:**
```bash
# 1. Verificar status das transações no arquivo
POD=$(kubectl get pods -n unifiapay -l app=api-pagamentos -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n unifiapay $POD -- cat /var/logs/api/instrucoes.log

# 2. Se status=AGUARDANDO_LIQUIDACAO, executar liquidação manual
kubectl create job liquidacao-manual --from=cronjob/cronjob-fechamento-reserva -n unifiapay

# 3. Aguardar Job completar
kubectl wait --for=condition=complete job/liquidacao-manual -n unifiapay --timeout=60s

# 4. Verificar logs do Job
kubectl logs job/liquidacao-manual -n unifiapay

# 5. Conferir arquivo novamente (deve ter status=LIQUIDADO)
kubectl exec -n unifiapay $POD -- cat /var/logs/api/instrucoes.log

# 6. Consultar saldo novamente
kubectl port-forward svc/api-pagamentos-service 30080:8080 -n unifiapay &
sleep 2
curl -s http://localhost:30080/api/v1/reserva | jq .
pkill -f "port-forward.*30080"
```

### ❌ Problema 5: Conflito de rede Docker (172.25.0.0/24)

**Sintoma:**
```bash
docker compose up
# Error response from daemon: Pool overlaps with other one on this address space
```

**Solução:**
```bash
# 1. Listar redes existentes
docker network ls

# 2. Identificar rede conflitante
docker network inspect NOME_DA_REDE | grep Subnet

# 3. Remover rede conflitante (se não estiver em uso)
docker network rm NOME_DA_REDE

# 4. Ou alterar subnet no docker-compose.yml
# Editar docker/docker-compose.yml linha com subnet: 172.25.0.0/24
# Trocar para: subnet: 172.26.0.0/24
```

### ❌ Problema 6: CronJob não executa automaticamente

**Sintoma:** CronJob configurado mas liquidações não acontecem.

**Solução:**
```bash
# 1. Verificar se CronJob está ativo
kubectl get cronjob -n unifiapay

# 2. Ver histórico de execuções
kubectl get jobs -n unifiapay

# 3. Verificar schedule (deve ser 0 */6 * * * para cada 6 horas)
kubectl describe cronjob cronjob-fechamento-reserva -n unifiapay | grep Schedule

# 4. Se schedule estiver incorreto, editar
kubectl edit cronjob cronjob-fechamento-reserva -n unifiapay
# Alterar linha: schedule: "0 */6 * * *"
# Para testes mais frequentes use: schedule: "*/5 * * * *" (cada 5 minutos)

# 5. Aguardar próxima execução ou criar Job manual
kubectl create job teste-cronjob --from=cronjob/cronjob-fechamento-reserva -n unifiapay
```

### ❌ Problema 7: Pods não conseguem escrever no volume (Permission denied)

**Sintoma:**
```bash
kubectl logs POD_NAME -n unifiapay
# PermissionError: [Errno 13] Permission denied: '/var/logs/api/instrucoes.log'
```

**Causa:** Diretório hostPath no node do Kind não tem permissões adequadas.

**Solução:**
```bash
# Configurar permissões dentro do node do Kind
docker exec -it unifiapay-control-plane sh -c "mkdir -p /tmp/unifiapay-logs && chmod 777 /tmp/unifiapay-logs"

# Verificar permissões
docker exec -it unifiapay-control-plane ls -la /tmp/ | grep unifiapay

# Reiniciar pods para usar novo diretório
kubectl rollout restart deployment api-pagamentos -n unifiapay
kubectl rollout restart deployment auditoria-service -n unifiapay

# Aguardar pods iniciarem
kubectl wait --for=condition=ready pod -l app=api-pagamentos -n unifiapay --timeout=120s
```

**✅ VALIDAÇÃO:** Agora os pods devem conseguir escrever no arquivo sem erros.

---

## 📚 PARTE 15: Comandos Úteis de Referência

### Kubernetes - Comandos Essenciais

```bash
# Ver todos os recursos do namespace
kubectl get all -n unifiapay

# Ver logs em tempo real
kubectl logs -f NOME_DO_POD -n unifiapay

# Ver logs de todos os pods com label
kubectl logs -l app=api-pagamentos -n unifiapay --tail=100

# Entrar em um pod
kubectl exec -it NOME_DO_POD -n unifiapay -- /bin/sh

# Ver eventos do namespace
kubectl get events -n unifiapay --sort-by='.lastTimestamp'

# Ver uso de recursos
kubectl top pods -n unifiapay
kubectl top nodes

# Reiniciar deployment
kubectl rollout restart deployment api-pagamentos -n unifiapay

# Ver histórico de rollout
kubectl rollout history deployment api-pagamentos -n unifiapay

# Deletar pod específico (será recriado automaticamente)
kubectl delete pod NOME_DO_POD -n unifiapay
```

### Docker - Comandos Essenciais

```bash
# Ver containers rodando
docker ps

# Ver todos containers (incluindo parados)
docker ps -a

# Ver logs de um container
docker logs CONTAINER_NAME -f

# Entrar em um container
docker exec -it CONTAINER_NAME /bin/sh

# Ver redes
docker network ls
docker network inspect unifiap_net

# Ver volumes
docker volume ls
docker volume inspect VOLUME_NAME

# Ver uso de disco
docker system df

# Limpar recursos não utilizados
docker system prune -a
```

### Kind - Comandos Essenciais

```bash
# Criar cluster
kind create cluster --name unifiapay

# Listar clusters
kind get clusters

# Ver nodes do cluster
kind get nodes --name unifiapay

# Deletar cluster
kind delete cluster --name unifiapay

# Carregar imagem local no cluster
kind load docker-image IMAGEM:TAG --name unifiapay

# Ver configuração do cluster
kubectl cluster-info --context kind-unifiapay
```

---

## 🎯 CHECKLIST FINAL DE ENTREGA

### ✅ Antes de Enviar o Projeto

- [ ] **README.md atualizado** com seu nome e RM
- [ ] **Imagens no Docker Hub** com tag `v1.SEU_RM`
- [ ] **Evidências coletadas** em `/evidencias/` (mínimo 15 arquivos)
- [ ] **GUIA-EXECUCAO.md** testado do início ao fim
- [ ] **Testes executados com sucesso:**
  - [ ] Docker Compose funcionando
  - [ ] PIX enviado e registrado
  - [ ] Liquidação processada corretamente
  - [ ] Saldo diminuiu após liquidação
  - [ ] Kind cluster criado
  - [ ] Pods em Running
  - [ ] Escala horizontal testada
  - [ ] CronJob executado
  - [ ] RBAC validado
  - [ ] Security Context verificado

### 📦 Estrutura de Entrega

```
gs-02-SEU_NOME-k8s/
├── README.md                        # ✅ Com nome e RM
├── GUIA-EXECUCAO.md                 # ✅ Completo e testado
├── api-pagamentos/                  # ✅ Código da API
├── auditoria-service/               # ✅ Código do serviço
├── docker/                          # ✅ Dockerfiles e compose
├── k8s/                             # ✅ Manifests Kubernetes
├── scripts/                         # ✅ Scripts de automação
└── evidencias/                      # ✅ Screenshots e logs
    ├── etapa1-docker/
    ├── etapa2-rede/
    ├── etapa3-k8s/
    └── etapa4-seguranca/
```

---

## 🏆 Conclusão

Parabéns! 🎉 Você concluiu com sucesso o desafio **UniFIAP Pay SPB**.

**O que você implementou:**
- ✅ Sistema de pagamentos simulando SPB brasileiro
- ✅ Docker multi-stage builds com segurança
- ✅ Rede isolada e comunicação entre containers (172.25.0.0/24)
- ✅ Kubernetes com Kind (namespace, deployments, services)
- ✅ Escala horizontal automática (2+ réplicas)
- ✅ Volume compartilhado hostPath como livro-razão (instrucoes.log)
- ✅ CronJob para liquidação automática (simula STR/BACEN)
- ✅ RBAC com ServiceAccount de permissões restritas
- ✅ Security Context (runAsNonRoot, capabilities drop)
- ✅ Fluxo completo de PIX com liquidação

**Decisões técnicas importantes:**
- **hostPath vs PVC:** Optou-se por hostPath porque Kind (Kubernetes local) não suporta ReadWriteMany no provisioner padrão
- **Permissões 777 no /tmp/unifiapay-logs:** Necessário para permitir que múltiplos pods (com runAsUser: 1000) escrevam no mesmo arquivo
- **readOnlyRootFilesystem: false:** Necessário porque a aplicação precisa escrever logs localmente antes de sincronizar no volume compartilhado

**Pontuação esperada:** 9,0 pontos (se todas evidências foram coletadas)

**Próximos passos:**
1. Revisar todas evidências coletadas
2. Zipar o projeto completo
3. Enviar conforme orientações do professor
4. Aguardar feedback

**Dúvidas?** Revise a seção de Troubleshooting ou consulte os logs dos pods/containers.

---

**Desenvolvido para FIAP - Cloud Computing & DevOps**  
**Disciplina:** Computational Thinking Using Python  
**Challenge:** Global Solution 2024

---

# Acessar shell do pod
kubectl exec -it POD_NAME -n unifiapay -- /bin/sh

# Ver uso de recursos
kubectl top nodes
kubectl top pods -n unifiapay

# Ver configuração do cluster
kubectl config view

# Listar contextos
kubectl config get-contexts
```

---

## ✅ Conclusão

Seguindo este guia, você terá:

1. ✅ Construído imagens Docker multi-stage seguras
2. ✅ Publicado imagens no Docker Hub com seu RM
3. ✅ Testado rede Docker isolada
4. ✅ Feito deploy completo no Kubernetes (Kind)
5. ✅ Validado volume compartilhado entre pods
6. ✅ Testado escala horizontal
7. ✅ Validado CronJob
8. ✅ Comprovado segurança (RBAC, securityContext, limites)
9. ✅ Coletado todas as evidências necessárias

**Total de pontos:** 9,0 pts 🎯

---

**Dúvidas?** Revise os logs e eventos do Kubernetes para diagnosticar problemas!

**Boa sorte! 🚀**
