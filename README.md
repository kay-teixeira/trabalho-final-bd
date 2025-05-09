# Banco de Dados Para Gerenciamento de Aeroporto

Este projeto foi desenvolvido como trabalho final da disciplina de Banco de Dados. Ele consiste em um modelo de banco de dados para um sistema de gerenciamento de aeroporto, implementado utilizando **PostgreSQL**.

## Descrição

O sistema modela as principais entidades e funcionalidades de um aeroporto, incluindo:

- **Passageiros:** Informações sobre os passageiros que utilizam os serviços do aeroporto.
- **Companhias Aéreas:** Dados das companhias aéreas que operam no aeroporto.
- **Portões de Embarque:** Identificação e localização dos portões de embarque.
- **Voos:** Detalhes dos voos, como origem, destino, horários e status.
- **Fila de Decolagem:** Gerenciamento da fila de voos aguardando decolagem, com ordenação automática.
- **Check-in:** Informações sobre o processo de check-in dos passageiros.
- **Embarques:** Registro dos embarques dos passageiros nos voos.

Além da modelagem das tabelas, o projeto inclui a implementação de recursos avançados do banco de dados, como:

- **Triggers:** Para automatizar tarefas, como a ordenação da fila de decolagem e a notificação sobre excesso de bagagem.
- **Funções:** Para realizar cálculos e lógicas de negócio específicas, como a ordenação da fila.
- **Views:** Para facilitar a consulta e visualização de dados, como a fila de decolagem completa e os voos atrasados.
- **Stored Procedures:** Para executar procedimentos armazenados no banco de dados, como o cálculo do valor de bagagem extra.
- **Tabelas Temporárias:** Para armazenar resultados intermediários de consultas complexas.
- **Sequências:** Para geração automática de chaves primárias.

## Tecnologias Utilizadas

- **PostgreSQL:** Sistema de gerenciamento de banco de dados relacional (SGBDR) utilizado para implementar o modelo.
- **SQL:** Linguagem de consulta estruturada utilizada para definir e manipular o banco de dados.
- **pl/pgSQL:** Linguagem procedural do PostgreSQL utilizada para escrever funções e triggers.

## Estrutura do Banco de Dados

O diagrama abaixo representa o modelo entidade-relacionamento (MER) do banco de dados:

**Tabelas:**

- `passageiros`
- `companhias`
- `portoes`
- `voos`
- `fila_decolagem`
- `checkin`
- `embarques`

**Relacionamentos:**

- `voos` possui um relacionamento com `companhias` (1:N)
- `voos` possui um relacionamento com `portoes` (1:N)
- `fila_decolagem` possui um relacionamento com `voos` (1:1)
- `checkin` possui um relacionamento com `voos` (1:N)
- `checkin` possui um relacionamento com `passageiros` (1:N)
- `embarques` possui um relacionamento com `voos` (1:N)
- `embarques` possui um relacionamento com `passageiros` (1:N)

## Como Executar

1.  **Instalar o PostgreSQL:** Certifique-se de que o PostgreSQL esteja instalado em sua máquina.
2.  **Configurar o Banco de Dados:**
    - Crie um banco de dados no PostgreSQL (por exemplo, `aeroporto_db`).
    - Você pode precisar ajustar as credenciais de usuário/senha no script SQL (`airport_querys.sql`) para corresponder à sua configuração do PostgreSQL.
3.  **Executar o Script SQL:** Execute o script `airport_querys.sql` no banco de dados criado.

## Funcionalidades

- **Ordenação Automática da Fila de Decolagem:** A fila de decolagem (`fila_decolagem`) é automaticamente ordenada com base na data e hora de saída dos voos, utilizando um trigger (`trg_ordenar_fila_voo`) e uma função (`fn_ordenar_fila_voo`).
- **Controle de Bagagem:** O sistema notifica sobre passageiros com excesso de bagagem, utilizando um trigger (`trg_limite_bagagens`) e uma função (`fn_limite_bagagem`).
- **Views para Consulta:** As views `vw_fila_decolagem_completa` e `voos_atrasados` simplificam a consulta de dados relacionados à fila de decolagem e voos atrasados, respectivamente.
- **Cálculo de Valor de Bagagem Extra:** A stored procedure `pd_valor_extra_bg` calcula o valor a ser pago por bagagem extra, e a função `fn_chama_storage` a chama e retorna os passageiros com bagagem extra.

## Autor

Desenvolvido por Kaylane Raquel, Gabriel Borges e Kauã Henrique como parte do projeto final da disciplina de Banco de Dados - Universidade Federal de Uberlândia (UFU).
