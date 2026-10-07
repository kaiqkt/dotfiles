# Revisão dos dotfiles

Data: 2026-10-03.

Revisão dos arquivos próprios do repositório: instalação/desinstalação,
Homebrew, asdf, Zsh, tmux, yabai/skhd, Sketchybar, Matugen/flavours, Kitty,
Neovim, VS Code, Lazygit, Git, Colima, Borders, FZF, Bat e Fastfetch.
Dependências baixadas em `tmux/plugins/` e `zsh/plugins/` foram consultadas
quando necessário para entender integrações; seus arquivos não foram editados.
As mudanças de limpeza anteriores nesta conversa foram preservadas.

## Problemas corrigidos

| Prioridade | Área | Problema e correção |
| --- | --- | --- |
| Alta | Worktrees | A remoção usava `rm -rf`, descartando arquivos locais mesmo sem `--force`. Agora usa `git worktree remove` e recusa alterações locais na remoção normal. |
| Alta | Worktrees | `wt:remove --force` não repassava a opção ao helper. Agora o modo explícito de remoção forçada é respeitado. |
| Alta | Popups tmux | O caminho escolhido era enviado como texto de shell sem escape. Espaços e caracteres especiais podiam quebrar o comando ou executar outra ação. Agora os argumentos são separados por NUL e escapados antes de serem enviados ao painel correto. |
| Média | Popups tmux | Todos compartilhavam `/tmp/tmux-fzf-result`. Agora cada popup cria um arquivo temporário próprio e o remove ao sair. |
| Média | Popups tmux | O wrapper selecionava uma janela arbitrária para aplicar estilos. Agora usa a janela e o painel que abriram o popup. Arquivos selecionados são resolvidos a partir do diretório do popup. |
| Média | Tema tmux | Recarregar apenas `theme.conf` substituía a barra processada pelos plugins, incluindo o comando periódico do Continuum. O hook do flavours agora recarrega `tmux.conf`, que reaplica os plugins. |
| Média | VS Code | O gerador emitia `terminal.ansi0Color` e outras chaves inexistentes. Agora usa `terminal.ansiBlack`, `terminal.ansiRed` etc., e o tema gerado foi atualizado. |
| Média | VS Code | O gerador apagava personalizações de cores do usuário. Agora preserva essas preferências ao selecionar o tema. |
| Média | Prompt Zsh | O parser tratava `git status --porcelain=v2` como formato v1. Agora lê os campos XY e `branch.ab`, mostrando alterações e divergência corretamente. Também escapa `%` em nomes de branches e diretórios. |
| Média | Worktrees | A criação e a tabela assumiam `master`, apesar de novos repositórios usarem `main`. Agora respeitam a configuração do projeto e a branch padrão do repositório bare. |
| Média | Worktrees | `wt:init` continuava após falhas de criação ou clone. Agora interrompe a operação. A limpeza também contabiliza falhas de remoção corretamente. |
| Média | Worktrees | A tabela confundia o cabeçalho de `docker compose ps` com containers ativos. Agora verifica os IDs de containers em execução. |
| Média | Navegação tmux | O seletor cortava índices de painéis em um dígito e filtrava por correspondência parcial. Agora usa IDs estáveis de painéis. O navegador de sessões também usa IDs, permitindo nomes com espaços. |
| Média | Sessionizer | A execução fora do tmux falhava com `TMUX` ausente por causa de `set -u`. Agora trata a variável ausente e inclui `~/Tech` e `~/Projects` na busca. |
| Média | Instalação | Havia referências ao AeroSpace, sem configuração correspondente. Foram substituídas pelo início de yabai/skhd; o tap configurado agora corresponde ao Brewfile. O instalador entra no diretório do checkout e prepara o PATH dos runtimes. |
| Média | Git LFS | O Git exigia `git-lfs`, mas o Brewfile não o instalava. A dependência foi adicionada ao Brewfile; será instalada no próximo `brew bundle`. |
| Média | Detecção MDM | Procurar apenas `enrolled` também aceitava respostas negativas. Agora são interpretados os campos de enrollment e seus valores `Yes`/`No`. |
| Média | Shell FZF | `fe`/`fo` alteravam `IFS` e variáveis globais. Agora usam arrays locais e preservam espaços nos arquivos escolhidos. |
| Média | Docker no shell | `dc-dev` deixava traps no shell do usuário. Agora a execução e os traps ficam em um subshell. `docker-attach` valida o ID do container. |
| Baixa | Cache Zsh | Uma geração incompleta podia deixar um cache truncado. Agora a geração usa um arquivo temporário e só publica conteúdo bem-sucedido e não vazio. |
| Baixa | git-multi | Opções inválidas retornavam sucesso, valores ausentes causavam erro de variável, e a inferência de URL dependia de `.git`. Esses casos foram corrigidos; a variável `USER` deixou de ser reutilizada. |
| Baixa | Nova sessão tmux | O template do prompt misturava comandos tmux com `&&` de shell. Agora cria e abre a sessão com um único comando tmux. |
| Baixa | Lazygit | O texto de opções usava preto, igual ao fundo da paleta do Kitty. Agora usa azul. |
| Baixa | Código sem uso | Removidos o arquivo vazio `zsh/user/completions.sh`, variáveis de Oh My Zsh sem consumidor, variáveis locais não usadas e o tema Dracula da lista de instalação do VS Code. |

## Melhorias sugeridas

1. **Automatizar os checks em CI.** Há testes locais, mas não há workflow
   versionado para executá-los em alterações futuras. Um runner macOS pode
   instalar Matugen/flavours e rodar a suíte e as verificações de sintaxe.
2. **Tornar as instalações reproduzíveis.** O Brewfile usa builds `HEAD` de
   yabai e diff-so-fancy; `gopls` e `dlv` são instalados com `@latest`.
   Fixar revisões/versões reduziria mudanças inesperadas entre instalações.
3. **Revisar as preferências de atualização e Git.** `brew autoupdate` é
   configurado com upgrade e cleanup automáticos. `core.fileMode=false`
   oculta alterações no bit executável dos scripts. Essas escolhas merecem
   uma decisão explícita antes de serem alteradas.
4. **Adicionar o Codex ao Brewfile se ele deve fazer parte de uma instalação
   nova.** O pacote não está na lista atual, embora seja uma ferramenta usada
   neste ambiente.
5. **Revisar a regra dos navegadores.** Brave está no Brewfile, mas a regra
   do primeiro desktop contempla Safari e Chrome. Incluir Brave depende da
   preferência de organização das janelas.
6. **Evitar colisões no Sessionizer.** O nome da sessão deriva apenas do nome
   da pasta. Dois projetos com o mesmo nome em diretórios diferentes podem
   abrir a mesma sessão. Uma convenção com prefixo ou hash do caminho resolve
   isso, mas altera os nomes usados no dia a dia.
7. **Ampliar cobertura de rename com submodules.** `wt:rename` manipula os
   arquivos de administração do Git diretamente. Casos com submodules e
   caminhos especiais ainda precisam de fixtures antes de uma refatoração.

## Validação

- 43 testes passaram: os 32 existentes e 11 novos testes de regressão.
- Sintaxe validada em 55 arquivos shell.
- 19 arquivos JSON/Python foram analisados; os 9 arquivos Lua do Neovim
  foram compilados sem executar suas configurações.
- Os 29 destinos de links do Dotbot existem e correspondem exatamente à
  lista de remoção do `uninstall`.
- ShellCheck passou nos scripts de instalação, desinstalação, tmux, yabai,
  git-multi, detecção de monitoramento, seletor de barra e instalação de
  extensões, na severidade warning.
- Fastfetch carregou sua configuração com sucesso.
- A suíte de temas executou o Matugen real e renderizou todos os templates
  flavours com as imagens de teste.
- `git diff --check` passou.

Uma instalação completa em um macOS limpo, reload dos serviços e interações
gráficas não foram executados nesta revisão. Os testes de worktrees usam
repositórios temporários; os testes de tmux substituem comandos externos por
fakes. Novas dependências do Brewfile não foram instaladas na máquina.

## Referências consultadas

- [Formato porcelain v2 do Git](https://git-scm.com/docs/git-status#_porcelain_format_version_2).
- [Proteções da remoção de worktrees](https://git-scm.com/docs/git-worktree#Documentation/git-worktree.txt-remove).
- [Cores do terminal do VS Code](https://code.visualstudio.com/api/references/theme-color#terminal-colors).
- Integração local do Continuum em `tmux/plugins/tmux-continuum/continuum.tmux`.
