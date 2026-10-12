# Migração segura para Supabase

## Estado protegido

- Versão funcional preservada: `pre-supabase-2026-10-12`
- Commit preservado: `258b095`
- Branch de implementação: `develop/supabase-migration`
- Branch de produção: `main`
- A branch `main` não deve receber merge automático.

As planilhas `Roteiro abril 2026 (1) (1).xlsx` e
`AgendaMedicos-Online.xlsx` permanecem fora do Git por conterem dados reais.
Elas não devem ser anexadas a issues, commits, testes ou Pull Requests.

## Regras de proteção

1. Fazer mudanças pequenas e testáveis somente na branch de desenvolvimento.
2. Revisar cada etapa por Pull Request antes de considerar merge.
3. Não remover a fonte de dados atual antes da validação completa do Supabase.
4. Nunca versionar senha, `service_role`, token administrativo ou planilha real.
5. Usar somente a chave pública de cliente no navegador, com RLS habilitada e testada.
6. Testar isolamento com dois usuários antes de migrar dados reais.
7. Não guardar dados médicos no cache público da PWA após a migração.

## Backup manual obrigatório

Antes da importação, manter uma cópia da planilha original fora desta pasta, de
preferência em uma área privada do OneDrive com histórico de versões. A cópia
deve ser aberta e conferida antes de iniciar a migração de dados.

## Procedimento de rollback

Se a versão em desenvolvimento apresentar problema, a aplicação publicada
continua na branch `main`. Para consultar a cópia protegida localmente:

```powershell
git switch --detach pre-supabase-2026-10-12
```

Para voltar ao desenvolvimento:

```powershell
git switch develop/supabase-migration
```

Se uma versão futura for publicada e precisar ser revertida, deve-se criar uma
nova branch a partir da tag protegida e abrir um Pull Request de restauração.
Não usar `git reset --hard` nem reescrever a branch principal.

## Plano aprovado

### Etapa 1 — Diagnóstico e proteção

- Auditar estrutura, dados, PWA e publicação.
- Identificar riscos de privacidade, cache, duplicidade e perda de dados.
- Preservar a versão atual com tag.
- Criar branch de desenvolvimento.
- Documentar backup, rollback e sequência de migração.

### Etapa 2 — Estrutura Supabase

- Criar tabelas relacionais e migrações SQL.
- Configurar autenticação e recuperação de senha.
- Aplicar RLS a todas as tabelas privadas.
- Testar isolamento com dois usuários.

### Etapa 3 — Cadastro e edição

- Implementar formulários responsivos para médicos, cidades, locais e horários.
- Validar dados e possíveis duplicidades.
- Manter registros inativos e histórico.

### Etapa 4 — Migração e integração

- Importar a planilha por área temporária e revisão humana.
- Integrar agenda, busca, dashboard e “Quem posso visitar agora?”.
- Remover dados reais do frontend somente depois da validação.

### Etapa 5 — Sincronização e publicação

- Testar iPhone, iPad, desktop, falhas de conexão e atualização da PWA.
- Revisar segurança e cache.
- Publicar por Pull Request aprovado, com rollback disponível.

## Critério para iniciar a Etapa 2

A Etapa 2 só começa após aprovação explícita do proprietário. A criação do
projeto Supabase será orientada passo a passo. Senhas e chaves secretas nunca
devem ser enviadas pela conversa.
