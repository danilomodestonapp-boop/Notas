# 📋 Automação de Tarefas

Sistema completo para gerenciar, arquivar e reportar tarefas diárias automaticamente.

## 🚀 Primeiros Passos

### 1️⃣ Configurar E-mail

Edite `scripts\config-email.ps1` e preencha seus dados:

```powershell
$EmailUsuario = "seu_email@gmail.com"
$SenhaUsuario = "sua_senha_ou_app_password"
$EmailDestinatario = "chefe@empresa.com"
$EmailCC = "coordenador@empresa.com"  # opcional
$HoraExecucao = "17:00"  # hora para enviar resumo
```

**Importante - Gmail com 2FA:**
- Acesse https://myaccount.google.com/apppasswords
- Gere uma **App Password** para seu script
- Use essa senha em `$SenhaUsuario`

### 2️⃣ Iniciar o Sistema Automático

```powershell
cd "C:\Users\dmo\Desktop\Notas"
powershell -NoProfile -File ".\scripts\iniciar.ps1"
```

Isso ativa:
- ✅ **Watch**: monitora o arquivo de tarefas quando salvo
- ✅ **Scheduler**: gera resumo todos os dias à hora configurada
- ✅ **Mailer**: envia resumo por e-mail automaticamente

## 📖 Como Usar

### Marcar Tarefas Concluídas

No arquivo `# Tarefas.md`, mude de:
```
- [ ] Minha tarefa
```

Para:
```
- [x] Minha tarefa
```

**Automático:** ao salvar, a tarefa é movida para `tarefas-concluidas.md`

### Gerar Resumo Manual

```powershell
cd "C:\Users\dmo\Desktop\Notas"
powershell -NoProfile -File ".\scripts\resumo-tarefas.ps1" -Date "2026-06-02"
```

Gera: `resumo-tarefas-2026-06-02.txt`

### Enviar E-mail Manual

```powershell
$config = ".\scripts\config-email.ps1"
. $config
powershell -NoProfile -File ".\scripts\enviar-resumo.ps1" `
  -EmailUsuario $EmailUsuario `
  -SenhaUsuario $SenhaUsuario `
  -EmailDestinatario $EmailDestinatario `
  -EmailCC $EmailCC `
  -Data "2026-06-02"
```

## 📂 Arquivos do Sistema

| Arquivo | Função |
|---------|--------|
| `# Tarefas.md` | Seu arquivo de tarefas diário |
| `tarefas-concluidas.md` | Arquivo de histórico (auto-gerado) |
| `resumo-tarefas-*.txt` | Resumos diários (auto-gerado) |
| `scripts/iniciar.ps1` | **PRINCIPAL** - inicia tudo |
| `scripts/config-email.ps1` | Configurações (edite aqui!) |
| `scripts/watch-tarefas.ps1` | Monitor em tempo real |
| `scripts/limpa_tarefas_completas.ps1` | Arquiva tarefas |
| `scripts/resumo-tarefas.ps1` | Gera resumo do dia |
| `scripts/enviar-resumo.ps1` | Envia por e-mail |

## ⚙️ Modos de Execução

### Daemon (Recomendado)
```powershell
& ".\scripts\iniciar.ps1" -Modo daemon
```
Roda em background, processa tudo automaticamente.

### Manual
```powershell
& ".\scripts\iniciar.ps1" -Modo manual
```
Mostra commands para executar manualmente quando precisar.

## 🔧 Troubleshooting

**E-mail não envia?**
- Verificar credenciais em `config-email.ps1`
- Se usar Gmail, gerar App Password (link acima)
- Verificar firewall/proxy bloqueando porta 587

**Tarefas não aparecem em concluídas?**
- Marque como `- [x]` (minúscula) ou `- [X]` (maiúscula)
- Salve o arquivo
- Execute `limpa_tarefas_completas.ps1`

**Resumo vazio?**
- Confirme que há tarefas marcadas com `[x]` ou `[X]` no arquivo
- Use `resumo-tarefas.ps1 -Date "YYYY-MM-DD"` com a data correta

## 📧 Exemplo de Resumo Enviado

```
Resumo de tarefas concluídas em 2026-06-02
===================================

- [x] ~~PARAMETRIZAR TS PARA OCULTAR TÍTULOS - TEAMS~~
- [x] ~~GERAR TESTE PARA VGR MMD~~
- [x] AJUDA ESCRITURAÇÃO DE NOTA DA BGP NOTA 1095
- [x] VERIFICAR EMISSÃO DE NOTA DA TSF
- [x] PREPARAR TREINAMENTO PMM
```

## 💡 Dicas

1. **Deixe rodando**: execute `iniciar.ps1` no startup do Windows para nunca perder
2. **Backup**: git está configurado em `.git/`, seus dados estão versionados
3. **Customizar hora**: edite `HoraExecucao` em `config-email.ps1`
4. **Múltiplos destinatários**: separe emails com `;` em `EmailDestinatario`

---

Feito com ❤️ para melhorar sua produtividade!
