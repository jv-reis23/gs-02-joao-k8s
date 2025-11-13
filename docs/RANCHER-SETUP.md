# 🐮 Guia de Instalação do Rancher

## Visão Geral

O Rancher é uma plataforma de gerenciamento de containers que fornece uma interface web para administrar clusters Kubernetes. Neste projeto, usamos o Rancher para:

- 🖥️ Monitorar pods, deployments e services visualmente
- 📊 Visualizar logs em tempo real
- 🔍 Debuggar problemas de forma mais intuitiva
- 📈 Acompanhar métricas de recursos (CPU, memória)
- ⚙️ Gerenciar configurações do cluster

---

## Opção 1: Rancher com Docker (Recomendado para Kind)

### Passo 1: Subir o Rancher

```bash
docker run -d \
  --name rancher \
  --restart=unless-stopped \
  -p 8080:80 -p 8443:443 \
  --privileged \
  rancher/rancher:latest
```

**Explicação dos parâmetros:**
- `-d`: Roda em background
- `--name rancher`: Nome do container
- `--restart=unless-stopped`: Reinicia automaticamente
- `-p 8080:80 -p 8443:443`: Expõe portas HTTP/HTTPS
- `--privileged`: Necessário para Rancher gerenciar containers

### Passo 2: Aguardar Rancher Iniciar

```bash
# Acompanhar logs (aguarde mensagem "Bootstrap Password:")
docker logs -f rancher

# Quando ver "Bootstrap Password: xxxx", pressione Ctrl+C
```

### Passo 3: Obter Senha Inicial

```bash
# Pegar a senha de bootstrap
docker logs rancher 2>&1 | grep "Bootstrap Password:"
```

**Resultado esperado:**
```
Bootstrap Password: abc123def456ghi789jkl012mno345pqr
```

### Passo 4: Acessar Interface Web

1. Abrir navegador: https://localhost:8443
2. Aceitar certificado auto-assinado (avançar mesmo com aviso de segurança)
3. Fazer login com a senha obtida no Passo 3
4. Definir nova senha administrativa

### Passo 5: Conectar o Cluster Kind ao Rancher

**Opção A - Importar Cluster Existente (Recomendado):**

1. No Rancher, clicar em **"Cluster Management"**
2. Clicar em **"Import Existing"**
3. Selecionar **"Generic"**
4. Dar nome: `unifiapay-kind`
5. Copiar o comando `kubectl apply` gerado
6. Executar no terminal (já conectado no Kind):

```bash
kubectl apply -f https://rancher-url/v3/import/xxxxx.yaml
```

7. Aguardar cluster aparecer como **"Active"** no Rancher

**Opção B - Registrar Manualmente:**

```bash
# Obter kubeconfig do Kind
kind get kubeconfig --name unifiapay > ~/.kube/kind-unifiapay-config

# No Rancher:
# 1. Ir em "Cluster Management" → "Import Existing"
# 2. Upload do arquivo kind-unifiapay-config
```

### Passo 6: Explorar o Namespace `unifiapay`

1. No Rancher, selecionar cluster `unifiapay-kind`
2. Ir em **"Workloads"** → **"Pods"**
3. Filtrar por namespace: `unifiapay`
4. Ver pods em tempo real:
   - `api-pagamentos-xxxxx` (2 réplicas)
   - `auditoria-service-xxxxx` (1 réplica)

### Passo 7: Monitorar CronJobs

1. Ir em **"Workloads"** → **"CronJobs"**
2. Namespace: `unifiapay`
3. Visualizar: `cronjob-fechamento-reserva`
4. Ver histórico de execuções

### Passo 8: Ver Logs pelo Rancher

1. Clicar em qualquer pod
2. Menu: **"View Logs"**
3. Logs em tempo real aparecem na tela
4. Possível baixar logs ou filtrar por timestamp

---

## Opção 2: Rancher com Helm (Alternativa)

### Passo 1: Instalar Helm

```bash
# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# macOS
brew install helm

# Verificar instalação
helm version
```

### Passo 2: Adicionar Repositório Rancher

```bash
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
```

### Passo 3: Criar Namespace para Rancher

```bash
kubectl create namespace cattle-system
```

### Passo 4: Instalar cert-manager (Dependência)

```bash
# Adicionar repo do cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Aguardar pods ficarem prontos
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=120s
```

### Passo 5: Instalar Rancher com Helm

```bash
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.localhost \
  --set bootstrapPassword=admin \
  --set replicas=1
```

### Passo 6: Aguardar Deploy

```bash
kubectl -n cattle-system rollout status deploy/rancher
kubectl -n cattle-system get pods
```

### Passo 7: Acessar Interface

```bash
# Port-forward
kubectl -n cattle-system port-forward svc/rancher 8443:443 &

# Abrir navegador
open https://localhost:8443
```

---

## Comparação: Docker vs Helm

| Critério | Docker | Helm |
|----------|--------|------|
| **Complexidade** | ⭐ Muito simples (1 comando) | ⭐⭐⭐ Médio (vários passos) |
| **Dependências** | Apenas Docker | Docker + Helm + cert-manager |
| **Tempo setup** | ~2 minutos | ~10 minutos |
| **Integração Kind** | ⭐⭐⭐ Excelente | ⭐⭐ Bom |
| **Adequado para demo** | ✅ Sim | ✅ Sim (mais robusto) |
| **Recomendado para produção** | ❌ Não | ✅ Sim |

**Recomendação para este projeto:** **Docker** (mais simples e rápido)

---

## Evidências para o Projeto

### Screenshots necessários:

1. **Dashboard Rancher** mostrando cluster Kind conectado
2. **Lista de Pods** no namespace `unifiapay` (2 API + 1 Auditoria)
3. **CronJob** `cronjob-fechamento-reserva` visível
4. **Logs em tempo real** de um pod da API
5. **Métricas de recursos** (CPU/Memória)

### Comandos para evidências:

```bash
# 1. Capturar URL do Rancher
echo "Rancher running at: https://localhost:8443" > evidencias/rancher/01-rancher-url.txt

# 2. Listar container Rancher
docker ps | grep rancher > evidencias/rancher/02-rancher-container.txt

# 3. Logs de inicialização
docker logs rancher | head -n 50 > evidencias/rancher/03-rancher-logs.txt

# 4. Screenshot: Dashboard completo (fazer manualmente)

# 5. Screenshot: Pods do namespace unifiapay (fazer manualmente)
```

---

## Troubleshooting

### Problema 1: Porta 8443 já em uso

**Solução:**
```bash
# Usar portas diferentes
docker run -d --name rancher -p 9080:80 -p 9443:443 rancher/rancher:latest

# Acessar em: https://localhost:9443
```

### Problema 2: Rancher não conecta no Kind

**Solução:**
```bash
# Verificar que Kind está rodando
kind get clusters

# Verificar contexto kubectl
kubectl config current-context

# Deve retornar: kind-unifiapay
```

### Problema 3: Certificado inválido no navegador

**Solução:**
- Chrome/Edge: Clicar em "Avançado" → "Continuar para localhost (não seguro)"
- Firefox: "Avançado" → "Aceitar o risco e continuar"

### Problema 4: Senha de bootstrap não aparece

**Solução:**
```bash
# Resetar senha
docker exec -it rancher reset-password

# Ou parar e reiniciar
docker stop rancher
docker rm rancher
# Executar novamente o docker run
```

---

## Limpeza (Remover Rancher)

### Se instalou com Docker:

```bash
docker stop rancher
docker rm rancher
```

### Se instalou com Helm:

```bash
helm uninstall rancher -n cattle-system
kubectl delete namespace cattle-system
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

---

## Próximos Passos

Após configurar o Rancher:

1. ✅ Explorar interface de gerenciamento
2. ✅ Monitorar pods em tempo real
3. ✅ Visualizar logs dos serviços
4. ✅ Acompanhar execução do CronJob
5. ✅ Capturar screenshots para evidências
6. ✅ Demonstrar na apresentação do projeto

---

**Referências:**
- Documentação Rancher: https://rancher.com/docs/
- Rancher Docker Install: https://rancher.com/docs/rancher/v2.6/en/installation/other-installation-methods/single-node-docker/
- Kind + Rancher: https://rancher.com/docs/k3s/latest/en/installation/
