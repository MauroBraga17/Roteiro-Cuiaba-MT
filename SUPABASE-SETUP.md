# Configuração do Supabase — Etapa 2

Esta etapa prepara o banco e a autenticação sem publicar dados reais. Não envie
senha, chave secreta, `service_role` ou conexão do banco pela conversa.

## O que foi preparado

- Migração SQL em `supabase/migrations/202610120001_initial_private_schema.sql`.
- Tabelas privadas: perfis, cidades, médicos, locais, horários e visitas.
- RLS e privilégios mínimos para que cada usuário veja somente seus registros.
- Teste pgTAP com duas identidades em `supabase/tests/rls_isolation.test.sql`.
- Telas de login, recuperação e definição de nova senha.
- Configuração pública com valores marcadores em `config/supabase.js`.

## Passos manuais no painel do Supabase

1. Acesse <https://supabase.com/dashboard> e crie um projeto.
2. Escolha uma senha forte para o banco e guarde-a no gerenciador de senhas.
3. Não envie essa senha pela conversa e não coloque-a neste repositório.
4. No projeto, abra **SQL Editor** e execute o conteúdo da migração SQL.
5. Em **Authentication > URL Configuration**, informe como Site URL:
   `https://maurobraga17.github.io/Roteiro-Cuiaba-MT/`
6. Adicione às Redirect URLs:
   `https://maurobraga17.github.io/Roteiro-Cuiaba-MT/nova-senha.html`
7. Em **Authentication > Providers > Email**, mantenha login por e-mail ativo.
8. Para uso pessoal, desative novos cadastros públicos depois de criar sua conta.
9. No botão **Connect** do projeto, copie apenas a URL e a **Publishable key**.
10. Substitua os dois marcadores de `config/supabase.js` localmente. A chave
    pública pode ficar no navegador porque a proteção efetiva é feita pela RLS.

Nunca use a `Secret key` ou a antiga `service_role` no frontend.

## Usuário inicial

Crie o primeiro usuário em **Authentication > Users**. Use seu próprio e-mail e
não compartilhe a senha. O banco cria automaticamente um perfil vinculado a ele.

## Testes de segurança

Os testes exigem Supabase CLI, Docker e o pacote oficial/comunitário de helpers
descrito na documentação do Supabase. Depois de configurar o ambiente:

```powershell
supabase start
supabase test db
```

O teste verifica RLS nas seis tabelas, leitura isolada, inclusão própria,
bloqueio de inclusão cruzada, bloqueio de alteração/exclusão de outro usuário,
integridade das chaves estrangeiras e bloqueio de acesso sem login.

Não execute testes com dados reais. A publicação e a importação da planilha só
podem ocorrer depois de todos os testes passarem.

## Situação da integração

As telas atuais ainda usam `data/schedule-data.js`. Isto é intencional: a Etapa
2 não substitui a fonte de dados nem publica a nova versão. A proteção das telas
atuais e a migração dos dados serão feitas apenas nas etapas aprovadas seguintes.
