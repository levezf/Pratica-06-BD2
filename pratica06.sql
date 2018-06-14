
/  
--Triggers
--1) (1,5) Crie uma trigger para a tabela Artista tal que, quando um artista mudar de banda, as
--informações do artista e da sua banda antiga sejam armazenadas na tabela de histórico do
--artista em banda.

CREATE OR REPLACE TRIGGER TR_AtualizaRegistroDeArtista
    BEFORE 
        UPDATE OF id_banda ON Artista_em_Banda 
        FOR EACH ROW
BEGIN
    
    INSERT INTO Historico_Artista_em_Banda(id_Artista, id_Banda, inicio, funcao, fim)
        VALUES (:old.id_Artista, :old.id_banda, :old.inicio, :old.funcao, SYSDATE);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO');

END TR_AtualizaRegistroDeArtista;
/
SELECT * FROM Historico_Artista_em_Banda;
SELECT * FROM Artista_em_Banda;
UPDATE Artista_em_Banda SET id_banda = 4;
/
--2) (1,5) Crie uma coluna chamada ‘quantidadeGravacoes’ na tabela Música. Faça um bloco
--PL/SQL que preencha esse campo com a quantidade de bandas ou artistas que já gravaram
--determinada música. Após isso, crie um trigger que controle esse número. Ou seja, se mais
--um artista gravar determinada música, o número deve ser incrementado. Se uma gravação
--for removida, o número deverá ser decrementado. Trate também casos de update.
ALTER TABLE Musica ADD QuantidadeGravacoes INT;
SELECT * FROM Musica;
/
DECLARE 
    
    v_id_musica Musica.id%TYPE;
    v_quantidade_musica INT;
    CURSOR c_ListaComposicao IS 
        SELECT id_musica ,COUNT(id_artista) FROM Composicao 
        GROUP BY id_musica;
BEGIN
    OPEN c_listaComposicao;
    LOOP
        FETCH c_listaComposicao INTO v_id_musica,v_quantidade_musica;
        UPDATE Musica SET QuantidadeGravacoes = v_quantidade_musica WHERE v_id_musica = id;
        EXIT WHEN c_listaComposicao%NOTFOUND;
    END LOOP;
    CLOSE c_listaComposicao;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO');
END;

/

CREATE OR REPLACE PROCEDURE P_AtualizaQuantidadeGravacoes(
    v_tipo_de_operacao IN VARCHAR, 
    id_musica IN Composicao.id_musica%TYPE
)
IS
BEGIN
    
    IF v_tipo_de_operacao LIKE 'INSERT' THEN
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes+1 WHERE id = id_musica; 
    ELSE 
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes-1 WHERE id = id_musica; 
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO');
END P_AtualizaQuantidadeGravacoes;
/

CREATE OR REPLACE TRIGGER TR_AtualizaQunatidadeDeMusica
    BEFORE
    INSERT OR DELETE ON Composicao
    FOR EACH ROW 
BEGIN
    
    IF INSERTING THEN 
        P_AtualizaQuantidadeGravacoes('INSERT', :new.id_musica);
    ELSE
        P_AtualizaQuantidadeGravacoes('DELETE',:old.id_musica);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO');
END TR_AtualizaQunatidadeDeMusica;
/
SELECT * FROM Composicao;
INSERT INTO Composicao(id_artista, id_musica, data) VALUES (6,2, '01-02-1903');
DELETE FROM Composicao WHERE id_artista = 6 AND id_musica = 2;
SELECT * FROM Musica;
/
--3) (1,5) Crie uma tabela de log para armazenar todas as operações de CREATE, ALTER e DROP
--de objetos do banco de dados. A tabela deve conter: usuário que criou, data e hora de
--criação, tipo do objeto criado (tabela, visão, função, etc) e nome do objeto criado (nome da
--tabela, etc). Feito isso, crie um trigger que faça inserções na tabela de log sempre que as
--operações acima forem realizadas (Dica: pesquise funções de atributo de evento de sistema.
--Ex: DICTIONARY_OBJ_TYPE)
DROP TABLE AuditoriaDB;
CREATE TABLE AuditoriaDB(
    usuario VARCHAR(64),
    data_alteracao DATE,
    hora_alteracao TIMESTAMP,
    tipo_objeto VARCHAR(64),
    nome_objeto VARCHAR(64)
);
/
Drop TRIGGER TR_ATUALIZATABELAAUDITORIA;
/
CREATE OR REPLACE TRIGGER TR_AtualizaTabelaAuditoria
    BEFORE
    CREATE OR ALTER OR DROP ON SCHEMA
BEGIN
    INSERT INTO AuditoriaDB
    SELECT USER, SYSDATE, CURRENT_DATE, SYS.DICTIONARY_OBJ_TYPE, SYS.DICTIONARY_OBJ_NAME
        FROM DUAL;
    
END TR_AtualizaTabelaAuditoria;
/
DROP TABLE Historico_em_gravadora;
SELECT * FROM AuditoriaDB; 

/   
--4) (1,0) Pesquise o que é o Problema da Tabela Mutante e responda as questões abaixo:
--a. Quando ocorre?
--Ocorre quando um Trigger refere-se à própria tabela que está sendo alterada.

--b. Dê um exemplo simples(usando o banco de dados música), onde há a criação de uma
--trigger com esse problema. Explique o motivo do erro ocorrer.
DROP TABLE AuditoriaDB;
DROP TABLE Historico_em_gravadora;
--O erro ocorre, pois ao reliazar o segundo 'Drop'é ativado o Trigger 'TR_AtualizaTabelaAuditoria'
--o qual referencia a tabela 'AuditoriaDB' que foi deletada no primeiro 'DROP'. Assim causando o erro de 
--tabela mutante.

--c. Quais são as possíveis soluções desse problema? Apenas cite, não é necessário fazer
--as soluções.
--Há 3 soluções possiveis, são elas:
--1)Uso combinado de Triggers e Packages
--2)Uso de trasação autônoma
--3)Uso combinado de Triggers e Views


--5) (1,0) Faça uma consulta que retorne informações relevantes (nome, tipo, dono, evento que
--aciona a trigger, objeto que a trigger age, etc) a respeito de cada trigger do seu banco de
--dados. (Dica: Há uma visão com esses dados. Pesquise!)





--Transações
--6) (1,0) Escolha 4 blocos PL/SQL que você já fez nas práticas anteriores e faça alterações que
--controlem as transações que façam sentido para o domínio da aplicação e do problema.
--Minimamente faça uso de:

--a. COMMIT
CREATE OR REPLACE PROCEDURE P_AtualizaQuantidadeGravacoes(
    v_tipo_de_operacao IN VARCHAR, 
    id_musica IN Composicao.id_musica%TYPE
)
IS
BEGIN
    IF v_tipo_de_operacao LIKE 'INSERT' THEN
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes+1 WHERE id = id_musica; 
    ELSE 
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes-1 WHERE id = id_musica; 
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO');
END P_AtualizaQuantidadeGravacoes;

COMMIT;

--b. ROLLBACK
CREATE OR REPLACE PROCEDURE P_AtualizaQuantidadeGravacoes(
    v_tipo_de_operacao IN VARCHAR, 
    id_musica IN Composicao.id_musica%TYPE
)
IS
BEGIN
    
    IF v_tipo_de_operacao LIKE 'INSERT' THEN
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes+1 WHERE id = id_musica; 
    ELSE 
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes-1 WHERE id = id_musica; 
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO, DESFAZENDO ALTERAÇÕES...');
            ROLLBACK;
END P_AtualizaQuantidadeGravacoes;
COMMIT;

--c. ROLLBACK TO savepoint;
CREATE OR REPLACE PROCEDURE P_AtualizaQuantidadeGravacoes(
    v_tipo_de_operacao IN VARCHAR, 
    id_musica IN Composicao.id_musica%TYPE
)
IS
BEGIN
    
    SAVEPOINT do_updates;
    
    IF v_tipo_de_operacao LIKE 'INSERT' THEN
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes+1 WHERE id = id_musica; 
    ELSE 
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes-1 WHERE id = id_musica; 
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO, DESFAZENDO ALTERAÇÕES...');
            ROLLBACK TO do_updates;
END P_AtualizaQuantidadeGravacoes;
COMMIT;

--d. Transações autônomas
CREATE OR REPLACE PROCEDURE P_AtualizaQuantidadeGravacoes(
    v_tipo_de_operacao IN VARCHAR, 
    id_musica IN Composicao.id_musica%TYPE
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    
    IF v_tipo_de_operacao LIKE 'INSERT' THEN
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes+1 WHERE id = id_musica; 
    ELSE 
        UPDATE Musica SET QuantidadeGravacoes = QuantidadeGravacoes-1 WHERE id = id_musica; 
    END IF;
    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO, DESFAZENDO ALTERAÇÕES...');
            ROLLBACK;      
END P_AtualizaQuantidadeGravacoes;




--Outros
--7) (2,5) Faça uma análise dos banco de dados DISCOGRAFIA (utilizado nas práticas) e do
--FUTEBOL (utilizado nas aulas). Para cada BD, informe os problemas de cada um e o que pode
--ser melhorado. Seja criterioso!
