# Crebito

![Static Badge](https://img.shields.io/badge/rinha_de_backend-2024_q1-yellow)  [![CI](https://github.com/anderkonzen/crebito/actions/workflows/ci.yaml/badge.svg)](https://github.com/anderkonzen/crebito/actions/workflows/ci.yaml)  [![Coverage Status](https://coveralls.io/repos/github/anderkonzen/crebito/badge.svg?branch=main)](https://coveralls.io/github/anderkonzen/crebito?branch=main)

Este repositório contém uma solução para o problema proposto na [Segunda Edição da Rinha de Backend (2024q1)](https://github.com/zanfranceschi/rinha-de-backend-2024-q1).

A solução foi escrita em [Elixir 1.16](https://elixir-lang.org/)/[Erlang 26.2](https://www.erlang.org/), utilizando o framework [Phoenix](https://www.phoenixframework.org/), usando como imagem Docker base a `debian:bookworm-20240130-slim`.

## Problema

De maneira geral, o problema proposto na segunda edição é a construção de uma API que aceita dois tipos de requisições: uma para criar uma transação de crédito ou débito (`transacoes`), e outra para consultar o extrato/saldo (`extrato`).

Além disto, foram colocadas algumas limitações como:
* o uso de um banco relacional (RDBMS, exemplos: MySQL, PostgreSQL) ou não-relacional (NoSQL, exemplos: MongoDB), com exceção daqueles que usam mecanismos _in-memory_ como o Redis;
* uso de _load balancer_, como por exemplo [NGINX](https://www.nginx.com/) ou [HAProxy](https://www.haproxy.org/);
* uso de duas instâncias da aplicação;
* restrições de CPU e memória (1.5 unidades de CPU e 550MB de memória).

## Solução

O problema proposto procura basicamente explorar dois aspectos:
* concorrência
* performance

No quesito concorrência, espera-se que o saldo fique consistente quando uma grande quantidade de chamadas concorrentes é realizada na API de transação.
Nos testes da Rinha, por exemplo, um dos cenários é a simulação de 25 chamadas simultâneas de débito para a API de transação, cada uma com o valor de 1, onde espera-se que o saldo final seja -25.

> [!IMPORTANT]
> Como estamos mirando uma API que irá receber muitas chamadas concorrentes, é importante evitar o padrão "ler, modificar, escrever" [^1] para evitar situação de condições de corrida. Neste caso pode-se usar apenas um SQL de update com incremento ou mesmo um `SELECT ... FOR UPDATE`.

Já em termos de performance, entra em cena tanto a stack utilizada (aqui por exemplo é Elixir/Erlang/Phoenix) e a configuração da arquitetura proposta para que as chamadas sejam processados o mais rápido possível.

## Iterações

Abaixo uma listagem e mais detalhes das iterações que eu fiz com o projeto, e como ele foi evoluindo.

<details>

<summary>Release 0.1.0 (não submetida)</summary>
<br />

Na primeira implementação, utilizei a configuração de arquitetura proposta sem alterar os parâmetros de CPU ou memória. Também utilizei a configuração proposta do NGINX.

Aqui me preocupei mais em fazer o setup do projeto com o intuito de apenas passar nos [testes da Rinha](https://github.com/zanfranceschi/rinha-de-backend-2024-q1?tab=readme-ov-file#ferramenta-de-teste). Como fazia um tempo que eu não criava um projeto Phoenix do zero, gastei um tempo fazendo a configuração do projeto em si, e também do [CI](https://github.com/anderkonzen/crebito/actions/workflows/ci.yaml) (com checks de análise estática, auditoria de dependências e testes) e publicação da imagem no DockerHub.

![CleanShot 2024-02-17 at 7  30 36](https://github.com/anderkonzen/crebito/assets/1413997/9b8ac677-571d-4ca1-af68-9f0dfa8389ec)

Na primeira rodada de testes percebi que a parte de concorrência não tinha ficado legal (eu tinha tentando usar apenas changesets e Multi), e acabei optando por fazer um update com incremento, e também garantir que o saldo não ficasse além do limite com uma constraint check na tabela. Na imagem abaixo podemos ver que todos os testes passaram, e o tempo p75 ficou em 5ms.

![CleanShot 2024-02-17 at 5  17 08](https://github.com/anderkonzen/crebito/assets/1413997/b9847daf-2579-4d2e-8457-92042090e4b6)

</details>

## Execução local

Para rodar o projeto local, é necessário apenas uma instância do PostgreSQL e Elixir 1.16/Erlang 26. Para uma configuração padrão, pode-se executar os seguintes passos:

* Rode `mix setup` para instalar e configurar as dependências
* Inicie a aplicação com `mix phx.server` ou dentro do IEx com `iex -S mix phx.server`

A partir deste ponto a API estará rodando em http://localhost:4000. Execute `curl localhost:4000/clientes/1/extrato` para verificar que a API está acessível.

## Execução "modo rinha"

Para executar o projeto tal qual nos testes, primeiro é necessário construir a imagem Docker e depois rodar o compose. Existe um [`Makefile`](https://github.com/anderkonzen/crebito/blob/main/Makefile) no projeto que simplifica estes passos:

```shell
$> make build
$> make up
```

## Melhorias e ideias futuras

- [ ] Organizar melhor os módulos seguindo algo no estilo DDD
- [ ] Adicionar telemetria, e monitorar com prometheus e grafana
- [ ] Adicionar algum mecanismo de cache, talvez ETS distribuído, ou mesmo Redis, como parte da brincadeira
- [ ] Testar a solução com outros bancos de dados

[^1]: https://elixirforum.com/t/ecto-postgres-database-simultaneous-update/31848/2
