#!/bin/bash

###############################################################################
# Script de Configuração Inicial
# Uso: ./setup-inicial.sh
###############################################################################

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Configuração Inicial - UniFIAP Pay SPB${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verificar pré-requisitos
echo -e "${BLUE}Verificando pré-requisitos...${NC}"
echo ""

# Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker instalado:${NC} $(docker --version)"
else
    echo -e "${RED}✗ Docker não encontrado!${NC}"
    echo "Instale: https://docs.docker.com/get-docker/"
    exit 1
fi

# Kind
if command -v kind &> /dev/null; then
    echo -e "${GREEN}✓ Kind instalado:${NC} $(kind --version)"
else
    echo -e "${RED}✗ Kind não encontrado!${NC}"
    echo "Instale: curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64"
    exit 1
fi

# kubectl
if command -v kubectl &> /dev/null; then
    echo -e "${GREEN}✓ kubectl instalado:${NC} $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
    echo -e "${RED}✗ kubectl não encontrado!${NC}"
    echo "Instale: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# jq
if command -v jq &> /dev/null; then
    echo -e "${GREEN}✓ jq instalado:${NC} $(jq --version)"
else
    echo -e "${YELLOW}⚠ jq não encontrado (necessário para testes)${NC}"
    echo "Instale: sudo apt-get install jq -y"
fi

echo ""
echo -e "${GREEN}Todos os pré-requisitos estão OK!${NC}"
echo ""

# Solicitar informações do aluno
echo -e "${YELLOW}Por favor, forneça suas informações:${NC}"
echo ""

read -p "Seu nome completo: " NOME_ALUNO
read -p "Seu RM: " RM_ALUNO
read -p "Seu usuário do Docker Hub: " DOCKERHUB_USER

echo ""
echo -e "${BLUE}Configurando ambiente...${NC}"
echo ""

# Criar arquivo .env
cat > docker/.env << EOF
# Configurações UniFIAP Pay SPB
RESERVA_BANCARIA_SALDO=1000000.00

# Dados do Aluno
ALUNO_RM=${RM_ALUNO}
DOCKERHUB_USER=${DOCKERHUB_USER}
EOF

echo -e "${GREEN}✓ Arquivo docker/.env criado${NC}"

# Criar chave PIX
echo "chave-pix-simulacao-unifiap-$(date +%s)" > docker/pix.key
echo -e "${GREEN}✓ Arquivo docker/pix.key criado${NC}"

# Atualizar README.md com dados do aluno
sed -i "s/\[Seu Nome Completo\]/${NOME_ALUNO}/g" README.md
sed -i "s/\[Seu Registro de Matrícula\]/${RM_ALUNO}/g" README.md
echo -e "${GREEN}✓ README.md atualizado${NC}"

# Criar diretórios de evidências
mkdir -p evidencias/etapa1-docker
mkdir -p evidencias/etapa2-rede
mkdir -p evidencias/etapa3-k8s-deploy
mkdir -p evidencias/etapa4-seguranca
echo -e "${GREEN}✓ Diretórios de evidências criados${NC}"

# Atualizar manifests com imagens personalizadas
echo ""
echo -e "${YELLOW}Atualizando manifests Kubernetes...${NC}"

# Deployment API
sed -i "s|image:.*api-pagamentos.*|image: ${DOCKERHUB_USER}/api-pagamentos:v1.${RM_ALUNO}|g" k8s/05-deployment-api.yaml
echo -e "${GREEN}✓ k8s/05-deployment-api.yaml atualizado${NC}"

# Deployment Auditoria
sed -i "s|image:.*auditoria-service.*|image: ${DOCKERHUB_USER}/auditoria-service:v1.${RM_ALUNO}|g" k8s/06-deployment-auditoria.yaml
echo -e "${GREEN}✓ k8s/06-deployment-auditoria.yaml atualizado${NC}"

# CronJob
sed -i "s|image:.*auditoria-service.*|image: ${DOCKERHUB_USER}/auditoria-service:v1.${RM_ALUNO}|g" k8s/08-cronjob-fechamento.yaml
echo -e "${GREEN}✓ k8s/08-cronjob-fechamento.yaml atualizado${NC}"

# Criar arquivo de referência rápida
cat > COMANDOS-RAPIDOS.md << EOF
# 🚀 Comandos Rápidos - UniFIAP Pay SPB

## Suas Informações
- Nome: ${NOME_ALUNO}
- RM: ${RM_ALUNO}
- Docker Hub: ${DOCKERHUB_USER}

## Build das Imagens
\`\`\`bash
# API
docker build -t ${DOCKERHUB_USER}/api-pagamentos:v1.${RM_ALUNO} ./api-pagamentos

# Auditoria
docker build -t ${DOCKERHUB_USER}/auditoria-service:v1.${RM_ALUNO} ./auditoria-service
\`\`\`

## Push das Imagens
\`\`\`bash
docker login
docker push ${DOCKERHUB_USER}/api-pagamentos:v1.${RM_ALUNO}
docker push ${DOCKERHUB_USER}/auditoria-service:v1.${RM_ALUNO}
\`\`\`

## Kind
\`\`\`bash
# Criar cluster
kind create cluster --name unifiapay

# Deletar cluster
kind delete cluster --name unifiapay
\`\`\`

## Deploy Kubernetes
\`\`\`bash
./scripts/deploy-k8s.sh
\`\`\`

## Testar API
\`\`\`bash
./scripts/test-api.sh
\`\`\`

## Ver Pods
\`\`\`bash
kubectl get pods -n unifiapay
\`\`\`

## Ver Logs
\`\`\`bash
kubectl logs -l app=api-pagamentos -n unifiapay --tail=50
\`\`\`
EOF

echo -e "${GREEN}✓ COMANDOS-RAPIDOS.md criado${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Configuração Inicial Concluída!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo "1. Fazer login no Docker Hub: ${BLUE}docker login${NC}"
echo "2. Fazer build das imagens (ver COMANDOS-RAPIDOS.md)"
echo "3. Seguir o GUIA-EXECUCAO.md passo a passo"
echo ""
echo -e "${GREEN}Boa sorte! 🚀${NC}"
