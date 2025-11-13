# 📋 PLANEJAMENTO COMPLETO - SETUP RANCHER

## 🎯 Objetivo
Instalar e configurar o Rancher para gerenciamento visual do cluster Kubernetes Kind com o namespace `unifiapay`.

---

## ✅ O QUE FOI CRIADO

### 1. Documentação
- ✅ **docs/RANCHER-SETUP.md** - Guia completo (Docker e Helm)
- ✅ **Seção no README.md** - Instruções resumidas (seção 2.3)
- ✅ **Seção no GUIA-EXECUCAO.md** - Passo-a-passo detalhado (PARTE 4)
- ✅ **evidencias/rancher/README.txt** - Instruções para evidências

### 2. Scripts
- ✅ **scripts/setup-rancher.sh** - Script automatizado de instalação
  - Verifica se Docker está rodando
  - Cria container Rancher
  - Extrai senha de bootstrap
  - Salva credenciais automaticamente

### 3. Estrutura de Evidências
- ✅ **evidencias/rancher/** - Pasta criada
- ✅ Lista de evidências necessárias documentada

---

## 🚀 COMO EXECUTAR (3 OPÇÕES)

### Opção 1: Script Automatizado (RECOMENDADO) ⭐

```bash
# 1. Tornar executável
chmod +x scripts/setup-rancher.sh

# 2. Executar
./scripts/setup-rancher.sh

# 3. Aguardar 1-2 minutos

# 4. Acessar https://localhost:8443

# 5. Login com senha mostrada no terminal

# 6. Importar cluster Kind via interface
```

**Tempo estimado:** 5 minutos

---

### Opção 2: Docker Manual

```bash
# 1. Subir container
docker run -d \
  --name rancher \
  --restart=unless-stopped \
  -p 8080:80 -p 8443:443 \
  --privileged \
  rancher/rancher:latest

# 2. Aguardar inicializar (60-120 segundos)
sleep 90

# 3. Obter senha
docker logs rancher 2>&1 | grep "Bootstrap Password:"

# 4. Acessar https://localhost:8443

# 5. Login e configurar

# 6. Importar cluster Kind
```

**Tempo estimado:** 5-7 minutos

---

### Opção 3: Helm (Mais Complexo)

```bash
# 1. Instalar Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 2. Adicionar repo Rancher
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

# 3. Criar namespace
kubectl create namespace cattle-system

# 4. Instalar cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=120s

# 5. Instalar Rancher
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.localhost \
  --set bootstrapPassword=admin \
  --set replicas=1

# 6. Aguardar deploy
kubectl -n cattle-system rollout status deploy/rancher

# 7. Port-forward
kubectl -n cattle-system port-forward svc/rancher 8443:443 &

# 8. Acessar https://localhost:8443
```

**Tempo estimado:** 15-20 minutos

---

## 📊 COMPARAÇÃO DAS OPÇÕES

| Critério | Script (Opção 1) | Docker Manual | Helm |
|----------|------------------|---------------|------|
| **Complexidade** | ⭐ Muito Simples | ⭐⭐ Simples | ⭐⭐⭐⭐ Complexo |
| **Tempo** | 5 min | 5-7 min | 15-20 min |
| **Dependências** | Docker | Docker | Docker + Helm + cert-manager |
| **Erros comuns** | Poucos | Médio | Muitos |
| **Adequado para demo** | ✅ IDEAL | ✅ Bom | ⚠️ Exagero |
| **Recomendado** | ✅ **SIM** | ✅ Sim | ❌ Não para este projeto |

---

## 🎓 RECOMENDAÇÃO PARA O PROJETO ACADÊMICO

### Use a **Opção 1 (Script Automatizado)** porque:

1. ✅ **Mais rápido** - 1 comando apenas
2. ✅ **Menos erros** - Script já testado
3. ✅ **Auto-documenta** - Gera evidências automaticamente
4. ✅ **Fácil de reproduzir** - Professor pode executar facilmente
5. ✅ **Foco no projeto** - Menos tempo configurando, mais tempo testando

### **NÃO use Helm** porque:

1. ❌ Adiciona complexidade desnecessária
2. ❌ Requer instalação de mais ferramentas
3. ❌ Mais pontos de falha (cert-manager, namespace, etc.)
4. ❌ Mais difícil de explicar na apresentação
5. ❌ Não agrega valor para demonstração acadêmica

---

## 📝 CHECKLIST DE EXECUÇÃO

### Pré-requisitos
- [ ] Docker instalado e rodando
- [ ] Cluster Kind criado (`kind create cluster --name unifiapay`)
- [ ] Pods do projeto rodando no namespace `unifiapay`
- [ ] Porta 8443 disponível (não usada por outro serviço)

### Instalação
- [ ] Executar `./scripts/setup-rancher.sh`
- [ ] Aguardar mensagem "Setup concluído!"
- [ ] Anotar senha de bootstrap mostrada

### Configuração
- [ ] Acessar https://localhost:8443
- [ ] Aceitar certificado auto-assinado
- [ ] Login com senha de bootstrap
- [ ] Definir nova senha administrativa
- [ ] Salvar nova senha em local seguro

### Integração com Kind
- [ ] Cluster Management → Import Existing → Generic
- [ ] Nome: `unifiapay-kind`
- [ ] Copiar comando `kubectl apply`
- [ ] Executar comando no terminal
- [ ] Aguardar cluster ficar "Active"

### Validação
- [ ] Cluster aparece como "Active" no Rancher
- [ ] Consegue ver namespace `unifiapay`
- [ ] Pods visíveis: 2x api-pagamentos + 1x auditoria-service
- [ ] CronJob visível: `cronjob-fechamento-reserva`
- [ ] Logs em tempo real funcionando

### Evidências
- [ ] Screenshot: Dashboard com cluster conectado
- [ ] Screenshot: Pods do namespace unifiapay
- [ ] Screenshot: CronJob view
- [ ] Screenshot: Logs em tempo real
- [ ] Arquivo: `01-bootstrap-password.txt` (auto-gerado)
- [ ] Arquivo: `02-rancher-container.txt`
- [ ] Arquivo: `03-rancher-init-logs.txt`

---

## ⚠️ PROBLEMAS COMUNS E SOLUÇÕES

### 1. Porta 8443 já em uso
```bash
# Verificar quem está usando
lsof -i :8443

# Parar serviço conflitante ou usar porta diferente:
docker run -d --name rancher -p 9443:443 rancher/rancher:latest
# Acessar em: https://localhost:9443
```

### 2. Senha de bootstrap não aparece
```bash
# Aguardar mais 30 segundos e tentar novamente
docker logs rancher 2>&1 | grep "Bootstrap Password:"

# Se ainda não aparecer, resetar:
docker exec -it rancher reset-password
```

### 3. Cluster Kind não conecta
```bash
# Verificar contexto kubectl
kubectl config current-context

# Deve retornar: kind-unifiapay
# Se não, trocar contexto:
kubectl config use-context kind-unifiapay

# Tentar comando de import novamente
```

### 4. Certificado SSL recusado
```bash
# No navegador:
# Chrome: "Avançado" → "Continuar para localhost"
# Firefox: "Avançado" → "Aceitar o risco"
# Edge: "Avançado" → "Continuar para localhost"
```

---

## 🎯 PRÓXIMOS PASSOS APÓS INSTALAÇÃO

1. **Explorar Interface:**
   - Familiarizar-se com menus
   - Testar navegação entre recursos
   - Ver logs de diferentes pods

2. **Monitorar Fluxo PIX:**
   - Enviar transação PIX via API
   - Acompanhar logs no Rancher em tempo real
   - Ver transação sendo registrada

3. **Executar Liquidação:**
   - Criar Job manual do CronJob via Rancher
   - Acompanhar execução
   - Ver logs de processamento

4. **Capturar Evidências:**
   - Tirar screenshots conforme checklist
   - Salvar em `evidencias/rancher/`
   - Documentar no README

5. **Preparar Apresentação:**
   - Demonstrar gerenciamento visual vs linha de comando
   - Mostrar facilidade de debug com Rancher
   - Destacar benefícios em produção

---

## 📚 RECURSOS ADICIONAIS

- **Documentação Oficial:** https://rancher.com/docs/
- **Vídeo Tutorial:** https://www.youtube.com/watch?v=oXPgJGqOjQE
- **Rancher Academy:** https://academy.rancher.com/
- **Community Forum:** https://forums.rancher.com/

---

## ✅ RESUMO EXECUTIVO

**Tempo total estimado:** 10-15 minutos (instalação + configuração + evidências)

**Comando único para setup:**
```bash
./scripts/setup-rancher.sh
```

**URL de acesso:**
```
https://localhost:8443
```

**Evidências geradas automaticamente:**
- `evidencias/rancher/01-bootstrap-password.txt`

**Screenshots manuais necessários:**
- Dashboard (cluster conectado)
- Pods namespace unifiapay
- CronJob view
- Logs em tempo real

---

**🎓 BOA SORTE COM O PROJETO!** 🚀
