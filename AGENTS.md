# AGENTS.md

Guia operacional para o Codex neste repositorio.

## Objetivo

Este projeto existe para demonstrar maturidade tecnica aplicada a Kubernetes, com foco em empregabilidade para vagas de Engenharia de Dados, DevOps Jr, Cloud Jr e Platform Engineering Jr.

## Regras de Trabalho

1. Sempre priorizar clareza, didatica e profissionalismo.
2. Nunca inventar evidencias, outputs de terminal, imagens ou resultados de execucao.
3. Todo manifesto Kubernetes deve ser comentado apenas quando o comentario realmente ajudar no aprendizado.
4. Todo YAML deve ser valido e compativel com Kubernetes atual.
5. Usar nomes consistentes de namespaces, labels, apps e scripts.
6. Manter documentacao em portugues do Brasil.
7. Criar comandos testaveis com `kubectl`.
8. Criar scripts seguros, idempotentes e compativeis com WSL2.
9. Antes de finalizar alteracoes, revisar:
   - estrutura do projeto
   - links internos do README
   - consistencia dos nomes
   - validade basica dos manifests
10. O foco do projeto e demonstrar maturidade tecnica para vagas de Engenharia de Dados, DevOps Jr, Cloud Jr ou Platform Engineering Jr.

## Padrao de documentacao

Cada modulo deve conter:

- objetivo
- conceito explicado de forma simples
- manifests envolvidos
- comandos de execucao
- comandos de validacao
- resultado esperado
- evidencia sugerida
- limpeza do ambiente
