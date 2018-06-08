--Triggers
--1) (1,5) Crie uma trigger para a tabela Artista tal que, quando um artista mudar de banda, as
--informações do artista e da sua banda antiga sejam armazenadas na tabela de histórico do
--artista em banda.


--2) (1,5) Crie uma coluna chamada ‘quantidadeGravacoes’ na tabela Música. Faça um bloco
--PL/SQL que preencha esse campo com a quantidade de bandas ou artistas que já gravaram
--determinada música. Após isso, crie um trigger que controle esse número. Ou seja, se mais
--um artista gravar determinada música, o número deve ser incrementado. Se uma gravação
--for removida, o número deverá ser decrementado. Trate também casos de update.


--3) (1,5) Crie uma tabela de log para armazenar todas as operações de CREATE, ALTER e DROP
--de objetos do banco de dados. A tabela deve conter: usuário que criou, data e hora de
--criação, tipo do objeto criado (tabela, visão, função, etc) e nome do objeto criado (nome da
--tabela, etc). Feito isso, crie um trigger que faça inserções na tabela de log sempre que as
--operações acima forem realizadas (Dica: pesquise funções de atributo de evento de sistema.
--Ex: DICTIONARY_OBJ_TYPE)


--4) (1,0) Pesquise o que é o Problema da Tabela Mutante e responda as questões abaixo:
--a. Quando ocorre?
--b. Dê um exemplo simples(usando o banco de dados música), onde há a criação de uma
--trigger com esse problema. Explique o motivo do erro ocorrer.
--c. Quais são as possíveis soluções desse problema? Apenas cite, não é necessário fazer
--as soluções.


--5) (1,0) Faça uma consulta que retorne informações relevantes (nome, tipo, dono, evento que
--aciona a trigger, objeto que a trigger age, etc) a respeito de cada trigger do seu banco de
--dados. (Dica: Há uma visão com esses dados. Pesquise!)
--ransações



--6) (1,0) Escolha 4 blocos PL/SQL que você já fez nas práticas anteriores e faça alterações que
--controlem as transações que façam sentido para o domínio da aplicação e do problema.
--Minimamente faça uso de:
--a. COMMIT
--b. ROLLBACK
--c. ROLLBACK TO savepoint;
--d. Transações autônomas



--Outros
--7) (2,5) Faça uma análise dos banco de dados DISCOGRAFIA (utilizado nas práticas) e do
--FUTEBOL (utilizado nas aulas). Para cada BD, informe os problemas de cada um e o que pode
--ser melhorado. Seja criterioso!
