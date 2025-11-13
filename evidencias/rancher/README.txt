# Evidências do Rancher

Esta pasta contém evidências do setup e uso do Rancher para gerenciamento do cluster Kubernetes.

## Arquivos Necessários:

1. **01-bootstrap-password.txt**
   - Gerado automaticamente pelo script setup-rancher.sh
   - Contém senha inicial de acesso ao Rancher

2. **02-dashboard-screenshot.png**
   - Screenshot do dashboard principal do Rancher
   - Deve mostrar cluster "unifiapay-kind" conectado e ativo

3. **03-pods-namespace-unifiapay.png**
   - Screenshot da tela de Workloads → Pods
   - Filtrado por namespace: unifiapay
   - Deve mostrar: 2x api-pagamentos + 1x auditoria-service

4. **04-cronjob-view.png**
   - Screenshot da tela de Workloads → CronJobs
   - Deve mostrar: cronjob-fechamento-reserva
   - Com schedule visível: "0 */6 * * *"

5. **05-logs-realtime.png**
   - Screenshot de logs em tempo real de um pod
   - Exemplo: logs do pod api-pagamentos mostrando transações PIX

## Como Capturar Screenshots:

### No Linux (com gnome-screenshot):
```bash
# Capturar janela do navegador (clicar na janela do Rancher)
gnome-screenshot -w -f evidencias/rancher/02-dashboard-screenshot.png
```

### No macOS:
```bash
# Cmd+Shift+4, depois Space, clicar na janela do Rancher
# Mover arquivo para: evidencias/rancher/02-dashboard-screenshot.png
```

### No Windows:
```bash
# Win+Shift+S (Snipping Tool)
# Salvar em: evidencias/rancher/02-dashboard-screenshot.png
```

## Dicas para Boas Evidências:

- ✅ Usar resolução alta (mínimo 1920x1080)
- ✅ Garantir que URL está visível (https://localhost:8443)
- ✅ Mostrar timestamp/data
- ✅ Capturar tela inteira, não recortar informações importantes
- ✅ Nomes dos pods devem estar legíveis
- ✅ Status dos pods deve estar visível (Running, Ready, etc.)

## Ordem Sugerida de Captura:

1. Executar: `./scripts/setup-rancher.sh`
2. Aguardar 1-2 minutos para Rancher inicializar
3. Acessar https://localhost:8443
4. Fazer login
5. Importar cluster Kind
6. Aguardar cluster ficar "Active"
7. **Screenshot 1:** Dashboard principal
8. Ir em Workloads → Pods → Namespace: unifiapay
9. **Screenshot 2:** Lista de pods
10. Ir em Workloads → CronJobs
11. **Screenshot 3:** CronJob
12. Clicar em um pod → View Logs
13. **Screenshot 4:** Logs em tempo real

## Arquivo Gerado Automaticamente:

- `01-bootstrap-password.txt` - ✅ Criado pelo script
