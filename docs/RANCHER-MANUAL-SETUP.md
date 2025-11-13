# 🐮 Setup Manual do Rancher - Passo a Passo

## 📋 Executar Comandos na Ordem

### PASSO 1: Verificar Pré-requisitos

```bash
# Verificar se Docker está rodando
docker info
```

**Resultado esperado:** Informações do Docker sem erros.

**Se der erro:** Inicie o Docker Desktop ou serviço Docker.

---

### PASSO 2: Verificar se já existe container Rancher

```bash
# Listar todos os containers (rodando ou parados)
docker ps -a | grep rancher
```

**Se já existir:** 
- Se estiver rodando (UP), pule para PASSO 5
- Se estiver parado (Exited), execute: `docker start rancher` e pule para PASSO 5

**Se não existir:** Continue para PASSO 3

---

### PASSO 3: Criar e Iniciar Container Rancher

```bash
docker run -d \
  --name rancher \
  --restart=unless-stopped \
  -p 8080:80 -p 8443:443 \
  --privileged \
  rancher/rancher:latest
```

**Explicação dos parâmetros:**
- `-d` = Roda em background (detached)
- `--name rancher` = Nome do container
- `--restart=unless-stopped` = Reinicia automaticamente (exceto se você parar manualmente)
- `-p 8080:80` = Mapeia porta HTTP (80 do container → 8080 do host)
- `-p 8443:443` = Mapeia porta HTTPS (443 do container → 8443 do host)
- `--privileged` = Necessário para Rancher gerenciar containers
- `rancher/rancher:latest` = Imagem oficial mais recente

**Resultado esperado:**
```
Unable to find image 'rancher/rancher:latest' locally
latest: Pulling from rancher/rancher
...
Status: Downloaded newer image for rancher/rancher:latest
a1b2c3d4e5f6... (ID do container)
```

---

### PASSO 4: Aguardar Rancher Inicializar

```bash
# Acompanhar logs de inicialização (pressione Ctrl+C quando ver "Bootstrap Password:")
docker logs -f rancher
```

**O que você verá:**
```
...
2025/11/11 03:15:23 [INFO] Starting Rancher v2.8.0
...
2025/11/11 03:16:45 [INFO] Bootstrap Password: xPt9kLm3nQ2rS5vW8yB1cD4fG7hJ0k
...
```

**Aguardar até ver:** Mensagem `Bootstrap Password:` (leva 1-2 minutos)

**Pressione:** `Ctrl+C` para parar de seguir os logs

---

### PASSO 5: Obter Senha de Bootstrap

```bash
# Extrair apenas a senha
docker logs rancher 2>&1 | grep "Bootstrap Password:"
```

**Resultado esperado:**
```
Bootstrap Password: xPt9kLm3nQ2rS5vW8yB1cD4fG7hJ0k
```

**⚠️ IMPORTANTE:** Copie essa senha! Você vai precisar no próximo passo.

---

### PASSO 6: Salvar Senha em Arquivo de Evidência

```bash
# Criar arquivo com a senha
mkdir -p evidencias/rancher
docker logs rancher 2>&1 | grep "Bootstrap Password:" > evidencias/rancher/01-bootstrap-password.txt

# Adicionar informações extras
echo "" >> evidencias/rancher/01-bootstrap-password.txt
echo "Rancher URL: https://localhost:8443" >> evidencias/rancher/01-bootstrap-password.txt
echo "Data de instalação: $(date)" >> evidencias/rancher/01-bootstrap-password.txt

# Verificar conteúdo
cat evidencias/rancher/01-bootstrap-password.txt
```

**Resultado esperado:**
```
Bootstrap Password: xPt9kLm3nQ2rS5vW8yB1cD4fG7hJ0k

Rancher URL: https://localhost:8443
Data de instalação: Mon Nov 11 03:20:15 -03 2025
```

---

### PASSO 7: Verificar Container Rodando

```bash
# Ver status do container
docker ps | grep rancher
```

**Resultado esperado:**
```
a1b2c3d4e5f6   rancher/rancher:latest   "entrypoint.sh"   2 minutes ago   Up 2 minutes   0.0.0.0:8080->80/tcp, 0.0.0.0:8443->443/tcp   rancher
```

**Observar:**
- Status: `Up X minutes`
- Portas: `0.0.0.0:8443->443/tcp` (HTTPS funcionando)

---

### PASSO 8: Salvar Informações do Container

```bash
# Salvar status do container
docker ps | grep rancher > evidencias/rancher/02-rancher-container.txt

# Salvar logs de inicialização (primeiras 100 linhas)
docker logs rancher 2>&1 | head -n 100 > evidencias/rancher/03-rancher-init-logs.txt

# Verificar arquivos criados
ls -lh evidencias/rancher/
```

**Resultado esperado:**
```
total 12K
-rw-r--r-- 1 jvreis23 jvreis23  150 Nov 11 03:20 01-bootstrap-password.txt
-rw-r--r-- 1 jvreis23 jvreis23  280 Nov 11 03:21 02-rancher-container.txt
-rw-r--r-- 1 jvreis23 jvreis23 3.5K Nov 11 03:21 03-rancher-init-logs.txt
```

---

### PASSO 9: Acessar Interface Web do Rancher

**No navegador, abrir:**
```
https://localhost:8443
```

**O que vai acontecer:**
1. Navegador mostra aviso de certificado auto-assinado
2. Clicar em "Avançado" ou "Advanced"
3. Clicar em "Continuar para localhost (não seguro)" ou "Proceed to localhost (unsafe)"

**Tela de Login aparece! 🎉**

---

### PASSO 10: Fazer Primeiro Login

**Na tela de login:**

1. **Password:** Cole a senha de bootstrap que você copiou no PASSO 5
   ```
   xPt9kLm3nQ2rS5vW8yB1cD4fG7hJ0k
   ```

2. Clicar em **"Log in with Local User"**

3. **Nova senha:** Criar uma senha administrativa permanente
   - Sugestão: `UniFIAP@2024` (fácil de lembrar)
   - Confirmar senha

4. Marcar checkbox: "I agree to the terms and conditions"

5. Clicar em **"Continue"**

---

### PASSO 11: Configurar URL do Servidor

**Tela "Set Server URL":**

1. **Rancher Server URL:** Deixar padrão
   ```
   https://localhost:8443
   ```

2. Clicar em **"Save URL"**

**Dashboard principal do Rancher aparece! 🚀**

---

### PASSO 12: Capturar Screenshot do Dashboard

**📸 EVIDÊNCIA 1:** Screenshot do dashboard principal

**Como capturar:**
- **Linux:** `gnome-screenshot -w` (clicar na janela do navegador)
- **macOS:** `Cmd+Shift+4` depois `Space` (clicar na janela)
- **Windows:** `Win+Shift+S` (selecionar área)

**Salvar como:**
```
evidencias/rancher/04-dashboard-screenshot.png
```

---

### PASSO 13: Importar Cluster Kind

**No Rancher:**

1. Clicar no **menu hambúrguer (☰)** no canto superior esquerdo

2. Selecionar **"Cluster Management"**

3. Clicar em **"Import Existing"**

4. Selecionar **"Generic"** (Kubernetes genérico)

5. **Cluster Name:** Digite
   ```
   unifiapay-kind
   ```

6. Deixar outras opções padrão

7. Clicar em **"Create"**

8. **Importante:** Na próxima tela, você verá um comando `kubectl apply`

---

### PASSO 14: Verificar Cluster Kind Está Rodando

**Antes de executar o comando do Rancher, verificar:**

```bash
# Listar clusters Kind
kind get clusters
```

**Resultado esperado:**
```
unifiapay
```

**Se não aparecer nada:**
```bash
# Criar cluster Kind
kind create cluster --name unifiapay

# Aguardar cluster ficar pronto (1-2 minutos)
kubectl wait --for=condition=ready node --all --timeout=180s
```

---

### PASSO 15: Verificar Contexto do kubectl

```bash
# Ver contexto atual
kubectl config current-context
```

**Resultado esperado:**
```
kind-unifiapay
```

**Se for diferente:**
```bash
# Trocar para contexto do Kind
kubectl config use-context kind-unifiapay
```

---

### PASSO 16: Copiar Comando de Import do Rancher

**No Rancher, você verá algo como:**
```bash
kubectl apply -f https://localhost:8443/v3/import/xxxxxxxxxxxxxxxxxxxxxxxxx.yaml
```

**⚠️ ATENÇÃO:** O `xxxxxxxxx` será um hash único gerado pelo seu Rancher.

**Copiar o comando completo!**

---

### PASSO 17: Executar Comando de Import

**No terminal:**

```bash
# Colar e executar o comando copiado do Rancher
kubectl apply -f https://localhost:8443/v3/import/xxxxxxxxxxxxxxxxxxxxxxxxx.yaml
```

**Resultado esperado:**
```
clusterrole.rbac.authorization.k8s.io/proxy-clusterrole-kubeapiserver created
clusterrolebinding.rbac.authorization.k8s.io/proxy-role-binding-kubernetes-master created
namespace/cattle-system created
serviceaccount/cattle created
clusterrolebinding.rbac.authorization.k8s.io/cattle-admin-binding created
secret/cattle-credentials-xxxxxxx created
clusterrole.rbac.authorization.k8s.io/cattle-admin created
deployment.apps/cattle-cluster-agent created
service/cattle-cluster-agent created
```

---

### PASSO 18: Aguardar Cluster Conectar

**No Rancher:**

1. Voltar para **"Cluster Management"**

2. Aguardar 30-60 segundos

3. O cluster `unifiapay-kind` deve aparecer na lista

4. **Status:** Vai mudar de "Waiting" → "Provisioning" → **"Active"** ✅

5. **Ícone:** Deve ficar verde quando ativo

**Se demorar mais de 2 minutos:**
```bash
# Verificar pods do cattle-system
kubectl get pods -n cattle-system

# Deve ver:
# cattle-cluster-agent-xxxxx   Running
```

---

### PASSO 19: Capturar Screenshot do Cluster Conectado

**📸 EVIDÊNCIA 2:** Screenshot mostrando cluster conectado

**No Rancher:**
- Tela: "Cluster Management"
- Mostrar: Cluster `unifiapay-kind` com status "Active" e ícone verde

**Salvar como:**
```
evidencias/rancher/05-cluster-connected.png
```

---

### PASSO 20: Acessar Cluster no Rancher

**No Rancher:**

1. Clicar no cluster **"unifiapay-kind"**

2. Dashboard do cluster aparece

3. Ver recursos do cluster (nodes, pods, etc.)

---

### PASSO 21: Navegar para Namespace unifiapay

**No menu lateral esquerdo:**

1. Clicar em **"Workloads"**

2. Clicar em **"Pods"**

3. **No dropdown superior (namespace):** Selecionar **"unifiapay"**

4. Você deve ver os pods:
   - `api-pagamentos-xxxxx` (2 réplicas)
   - `api-pagamentos-yyyyy`
   - `auditoria-service-zzzzz`

**Se não aparecer nada:**
- Pode ser que os pods ainda não foram criados
- Execute: `kubectl get pods -n unifiapay` no terminal
- Se vazio, execute o deploy: `./scripts/deploy-k8s.sh`

---

### PASSO 22: Capturar Screenshot dos Pods

**📸 EVIDÊNCIA 3:** Screenshot dos pods no namespace unifiapay

**No Rancher:**
- Tela: Workloads → Pods
- Namespace: unifiapay (visível no dropdown)
- Mostrar: Lista de pods com status "Running"

**Salvar como:**
```
evidencias/rancher/06-pods-namespace-unifiapay.png
```

---

### PASSO 23: Visualizar CronJob

**No menu lateral esquerdo:**

1. Clicar em **"Workloads"**

2. Clicar em **"CronJobs"**

3. **Namespace:** Verificar que está em **"unifiapay"**

4. Você deve ver:
   - Nome: `cronjob-fechamento-reserva`
   - Schedule: `0 */6 * * *`
   - Last Schedule: (timestamp se já executou)

---

### PASSO 24: Capturar Screenshot do CronJob

**📸 EVIDÊNCIA 4:** Screenshot do CronJob

**No Rancher:**
- Tela: Workloads → CronJobs
- Namespace: unifiapay
- Mostrar: `cronjob-fechamento-reserva` com schedule visível

**Salvar como:**
```
evidencias/rancher/07-cronjob-view.png
```

---

### PASSO 25: Ver Logs de um Pod

**No Rancher:**

1. Voltar para **Workloads → Pods**

2. Namespace: **unifiapay**

3. Clicar em qualquer pod da **api-pagamentos**

4. Clicar no botão **"View Logs"** (canto superior direito)

5. Logs aparecem em tempo real! 📊

---

### PASSO 26: Enviar PIX e Ver Log em Tempo Real

**Abrir novo terminal (manter Rancher aberto):**

```bash
# Port-forward para API
kubectl -n unifiapay port-forward svc/api-pagamentos-service 30080:8080 &

# Aguardar 2 segundos
sleep 2

# Enviar PIX
curl -s -X POST http://localhost:30080/api/v1/pix \
  -H "Content-Type: application/json" \
  -d '{
    "valor": 150.00,
    "chave_destino": "teste.rancher@fiap.com",
    "descricao": "Teste via Rancher"
  }' | jq .
```

**No Rancher (tela de logs):**
- Você deve ver log aparecer em tempo real mostrando a transação PIX! 🎉

---

### PASSO 27: Capturar Screenshot dos Logs

**📸 EVIDÊNCIA 5:** Screenshot dos logs em tempo real

**No Rancher:**
- Tela: Pod → View Logs
- Mostrar: Logs do pod com transação PIX visível

**Salvar como:**
```
evidencias/rancher/08-logs-realtime.png
```

---

### PASSO 28: Parar Port-Forward

```bash
# Matar port-forward que está em background
pkill -f "port-forward.*30080"
```

---

### PASSO 29: Verificar Todas as Evidências

```bash
# Listar arquivos de evidências
ls -lh evidencias/rancher/

# Contar arquivos
ls -1 evidencias/rancher/ | wc -l
```

**Resultado esperado:**
```
total 32K
-rw-r--r-- 1 jvreis23 jvreis23  150 Nov 11 03:20 01-bootstrap-password.txt
-rw-r--r-- 1 jvreis23 jvreis23  280 Nov 11 03:21 02-rancher-container.txt
-rw-r--r-- 1 jvreis23 jvreis23 3.5K Nov 11 03:21 03-rancher-init-logs.txt
-rw-r--r-- 1 jvreis23 jvreis23  450K Nov 11 03:35 04-dashboard-screenshot.png
-rw-r--r-- 1 jvreis23 jvreis23  380K Nov 11 03:40 05-cluster-connected.png
-rw-r--r-- 1 jvreis23 jvreis23  420K Nov 11 03:42 06-pods-namespace-unifiapay.png
-rw-r--r-- 1 jvreis23 jvreis23  390K Nov 11 03:44 07-cronjob-view.png
-rw-r--r-- 1 jvreis23 jvreis23  410K Nov 11 03:46 08-logs-realtime.png

8 (total de arquivos)
```

---

## ✅ CHECKLIST FINAL

- [ ] Container Rancher rodando (`docker ps | grep rancher`)
- [ ] Senha de bootstrap salva (`evidencias/rancher/01-bootstrap-password.txt`)
- [ ] Acesso à interface web (https://localhost:8443)
- [ ] Login realizado com sucesso
- [ ] Cluster Kind conectado e status "Active"
- [ ] Pods do namespace `unifiapay` visíveis
- [ ] CronJob visível no Rancher
- [ ] Logs em tempo real funcionando
- [ ] 8 evidências coletadas (3 arquivos .txt + 5 screenshots .png)

---

## 🔧 COMANDOS ÚTEIS

```bash
# Ver logs do Rancher
docker logs rancher

# Ver logs em tempo real
docker logs -f rancher

# Parar Rancher (mantém dados)
docker stop rancher

# Reiniciar Rancher
docker restart rancher

# Ver status do container
docker ps | grep rancher

# Remover Rancher completamente (apaga tudo!)
docker stop rancher
docker rm rancher

# Resetar senha administrativa (se esquecer)
docker exec -it rancher reset-password
```

---

## 🎯 PRONTO!

Rancher está funcionando e integrado com o cluster Kind! 🎉

Você pode agora:
- ✅ Gerenciar pods visualmente
- ✅ Ver logs em tempo real
- ✅ Monitorar recursos
- ✅ Executar CronJobs manualmente
- ✅ Demonstrar na apresentação do projeto

**Próximo passo:** Atualizar README.md com seu nome e RM! 📝
