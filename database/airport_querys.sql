CREATE ROLE kaua WITH LOGIN SUPERUSER PASSWORD '12345';
CREATE ROLE kay WITH LOGIN SUPERUSER PASSWORD '12345';


CREATE TABLE passageiros(
	id 					INTEGER CONSTRAINT nn_id_pass NOT NULL,
	nome_passageiro 	VARCHAR(50) CONSTRAINT nn_nome_pass NOT NULL,
	nacionalidade		VARCHAR(30) CONSTRAINT nn_nacionalidade NOT NULL,
	idade 				INTEGER,
	cpf 				VARCHAR (20) UNIQUE NOT NULL,	
	CONSTRAINT 			pk_id_passageiro PRIMARY KEY(id)
);

DROP TABLE passageiros;


CREATE TABLE companhias(
	id 					INTEGER CONSTRAINT nn_id_comp NOT NULL,
	nome_companhia		VARCHAR(50) NOT NULL,
	codigo_iata			VARCHAR(10) UNIQUE,
	CONSTRAINT 			pk_id_companhia PRIMARY KEY(id)
);

DROP TABLE companhias;

CREATE TABLE portoes(
	id					INTEGER CONSTRAINT nn_id_port NOT NULL,
	nome_portao			VARCHAR(20) UNIQUE,
	CONSTRAINT 			pk_id_portoes PRIMARY KEY(id)
);

DROP TABLE portoes;


CREATE TABLE voos (
	id 					INTEGER PRIMARY KEY CONSTRAINT nn_id_voo NOT NULL,
	origem				VARCHAR(20) NOT NULL,
	destino				VARCHAR(20) NOT NULL,
	data_saida 			DATE,
	hora_saida 			TIME,
	data_chegada 		DATE,
	hora_chegada 		TIME,
	status_voo			VARCHAR(20),
	id_companhia 		INTEGER NOT NULL,
	id_portao			INTEGER NOT NULL,
	FOREIGN KEY 		(id_companhia) REFERENCES companhias(id),
	FOREIGN KEY 		(id_portao) REFERENCES portoes(id)
);

DROP TABLE voos;


CREATE TABLE fila_decolagem(
	id					INTEGER PRIMARY KEY CONSTRAINT nn_id_fila NOT NULL,
	id_voo 				INTEGER CONSTRAINT nn_id_voo UNIQUE NOT NULL,
	posicao				INTEGER NOT NULL,
	status 				VARCHAR(20) DEFAULT 'Aguardando',
	horario_entrada 	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY 		(id_voo) REFERENCES voos(id)
);

DROP TABLE fila_decolagem;

CREATE TABLE checkin(
	id 					INTEGER PRIMARY KEY CONSTRAINT nn_id_checkin NOT NULL,
	id_voo				INTEGER CONSTRAINT nn_id_voo_check UNIQUE NOT NULL,
	id_passageiro		INTEGER CONSTRAINT nn_id_pass_check UNIQUE NOT NULL, 
	status_checkin		VARCHAR(20) DEFAULT 'Pendente',
	bagagens 			INT DEFAULT 0,
	FOREIGN KEY 		(id_voo) REFERENCES voos(id),
	FOREIGN KEY 		(id_passageiro) REFERENCES passageiros(id)
);

DROP TABLE checkin;

CREATE TABLE embarques(
	id 					INTEGER PRIMARY KEY CONSTRAINT nn_id_embarque NOT NULL,
	id_voo				INTEGER CONSTRAINT nn_id_voo_emb UNIQUE NOT NULL,
	id_passageiro		INTEGER CONSTRAINT nn_id_pass_emb UNIQUE NOT NULL, 
	data_embarque		DATE,
	status_embarque		VARCHAR(20), 
	FOREIGN KEY 		(id_voo) REFERENCES voos(id),
	FOREIGN KEY 		(id_passageiro) REFERENCES passageiros(id)
);

DROP TABLE embarques;

-- Função para ordenar fila de voo

CREATE OR REPLACE FUNCTION fn_ordenar_fila_voo()
RETURNS TRIGGER AS $$
BEGIN
    WITH fila_ordenada AS (
        SELECT 
            fila_decolagem.id,
            ROW_NUMBER() OVER (
                ORDER BY voos.data_saida, voos.hora_saida
            ) AS nova_posicao
        FROM fila_decolagem
        JOIN voos ON fila_decolagem.id_voo = voos.id
    )
    UPDATE fila_decolagem
    SET posicao = fila_ordenada.nova_posicao
    FROM fila_ordenada
    WHERE fila_decolagem.id = fila_ordenada.id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- Trigger para a função fn_ordenar_fila_voo

CREATE TRIGGER trg_ordenar_fila_voo
AFTER INSERT OR UPDATE OR DELETE
ON fila_decolagem
FOR EACH STATEMENT
EXECUTE FUNCTION fn_ordenar_fila_voo();

SELECT * FROM fila_decolagem
SELECT * FROM voos;


-- Atualizando sequencias dos ids

CREATE SEQUENCE seq_passageiros_id START 1;

ALTER TABLE passageiros
ALTER COLUMN id SET DEFAULT nextval('seq_passageiros_id');


CREATE SEQUENCE seq_companhias_id START 1;

ALTER TABLE companhias
ALTER COLUMN id SET DEFAULT nextval('seq_companhias_id');


CREATE SEQUENCE seq_portoes_id START 1;

ALTER TABLE portoes
ALTER COLUMN id SET DEFAULT nextval('seq_portoes_id');


CREATE SEQUENCE seq_voos_id START 1;

ALTER TABLE voos
ALTER COLUMN id SET DEFAULT nextval('seq_voos_id');


CREATE SEQUENCE seq_fila_decolagem_id START 1;

ALTER TABLE fila_decolagem
ALTER COLUMN id SET DEFAULT nextval('seq_fila_decolagem_id');


CREATE SEQUENCE seq_checkin_id START 1;

ALTER TABLE checkin
ALTER COLUMN id SET DEFAULT nextval('seq_checkin_id');


CREATE SEQUENCE seq_embarques_id START 1;

ALTER TABLE embarques
ALTER COLUMN id SET DEFAULT nextval('seq_embarques_id');


-------------- Dados de teste -------------
INSERT INTO companhias (nome_companhia, codigo_iata) VALUES
('Gol Linhas Aéreas', 'GLO'), ('Latam Airlines', 'LTM'),
('Azul Linhas Aéreas', 'AZU'), ('Avianca Brasil', 'AVB'),
('Delta Airlines', 'DAL');
SELECT * FROM companhias;
DELETE FROM companhias;
ALTER SEQUENCE seq_companhias_id RESTART WITH 1;

INSERT INTO portoes (nome_portao) VALUES
('Portão 1'), ('Portão 2'), ('Portão 3'), 
('Portão 4'), ('Portão 5'), ('Portão 6');
SELECT * FROM portoes;

INSERT INTO passageiros (nome_passageiro, nacionalidade, idade, cpf) VALUES
('João Silva', 'Brasileiro', 35, '111.222.333-44'), ('Maria Santos', 'Brasileira', 28, '222.333.444-55'),
('Carlos Oliveira', 'Português', 42, '333.444.555-66'), ('Ana Pereira', 'Brasileira', 24, '444.555.666-77'),
('Pedro Costa', 'Espanhol', 50, '555.666.777-88'), ('Laura Mendes', 'Brasileira', 19, '666.777.888-99'),
('Ricardo Almeida', 'Brasileiro', 33, '777.888.999-00'), ('Fernanda Lima', 'Brasileira', 45, '888.999.000-11'),
('Eduardo Souza', 'Brasileiro', 29, '999.000.111-22'), ('Camila Rocha', 'Brasileira', 31, '000.111.222-33');
SELECT * FROM passageiros;

INSERT INTO voos (origem, destino, data_saida, hora_saida, data_chegada, hora_chegada, status_voo, id_companhia, id_portao) VALUES
('São Paulo', 'Rio de Janeiro', '2023-12-01', '08:00:00', '2023-12-01', '09:15:00', 'Programado', 1, 1),
('Rio de Janeiro', 'São Paulo', '2023-12-01', '10:30:00', '2023-12-01', '11:45:00', 'Programado', 2, 2),
('Brasília', 'Recife', '2023-12-01', '12:15:00', '2023-12-01', '15:30:00', 'Programado', 3, 3),
('São Paulo', 'Miami', '2023-12-01', '14:00:00', '2023-12-01', '22:30:00', 'Programado', 4, 4),
('Recife', 'São Paulo', '2023-12-01', '16:45:00', '2023-12-01', '19:00:00', 'Atrasado', 1, 5),
('São Paulo', 'Nova York', '2023-12-01', '18:30:00', '2023-12-02', '04:15:00', 'Programado', 5, 6),
('Rio de Janeiro', 'Buenos Aires', '2023-12-01', '20:15:00', '2023-12-02', '00:45:00', 'Programado', 2, 1),
('São Paulo', 'Lisboa', '2023-12-01', '22:00:00', '2023-12-02', '10:30:00', 'Programado', 3, 2);
SELECT * FROM voos;

INSERT INTO fila_decolagem (id_voo, posicao, status, horario_entrada) VALUES
(1, 1, 'Aguardando', '2023-12-01 06:00:00'), (2, 2, 'Aguardando', '2023-12-01 06:15:00'),
(3, 3, 'Aguardando', '2023-12-01 06:30:00'), (4, 4, 'Aguardando', '2023-12-01 06:45:00'),
(5, 5, 'Atrasado', '2023-12-01 07:00:00'), (6, 6, 'Aguardando', '2023-12-01 07:15:00'),
(7, 7, 'Aguardando', '2023-12-01 07:30:00'), (8, 8, 'Aguardando', '2023-12-01 07:45:00');
SELECT * FROM fila_decolagem;

INSERT INTO checkin (id_voo, id_passageiro, status_checkin, bagagens) VALUES
(1, 1, 'Concluído', 1), (1, 2, 'Concluído', 2), (1, 3, 'Concluído', 1),
(2, 4, 'Concluído', 0), (2, 5, 'Concluído', 3), (3, 6, 'Concluído', 1),
(3, 7, 'Concluído', 2), (4, 8, 'Concluído', 1), (4, 9, 'Concluído', 2),
(5, 10, 'Pendente', 0), (6, 1, 'Concluído', 1), (7, 2, 'Concluído', 2),
(8, 3, 'Concluído', 1);
SELECT * FROM checkin;
ALTER TABLE checkin DROP CONSTRAINT nn_id_voo_check; -- antes apenas um passageiro conseguia fazer checkin no voo
ALTER TABLE checkin DROP CONSTRAINT nn_id_pass_check; -- antes o passageiro so conseguia fazer checkin em um voo

INSERT INTO embarques (id_voo, id_passageiro, data_embarque, status_embarque) VALUES
(1, 1, '2023-12-01', 'Embarcado'), (1, 2, '2023-12-01', 'Embarcado'),
(1, 3, '2023-12-01', 'Embarcado'), (2, 4, '2023-12-01', 'Embarcado'),
(2, 5, '2023-12-01', 'Embarcado'), (3, 6, '2023-12-01', 'Embarcado'),
(3, 7, '2023-12-01', 'Embarcado'), (4, 8, '2023-12-01', 'Embarcado'),
(4, 9, '2023-12-01', 'Embarcado'), (6, 1, '2023-12-01', 'Embarcado'),
(7, 2, '2023-12-01', 'Embarcado'), (8, 3, '2023-12-01', 'Embarcado');
SELECT * FROM embarques;

ALTER TABLE embarques DROP CONSTRAINT nn_id_voo_emb, DROP CONSTRAINT nn_id_pass_emb; -- tava permitindo apaenas um registro por voo e passageiro
ALTER TABLE embarques ADD CONSTRAINT uk_embarque_voo_pass UNIQUE (id_voo, id_passageiro); -- multiplos passageiros por voo e multiplos voos por passageiro evitando duplicatas.
ALTER TABLE checkin ADD CONSTRAINT uk_checkin_voo_pass UNIQUE (id_voo, id_passageiro); -- Para não ter check in repetido

INSERT INTO checkin (id_voo, id_passageiro, status_checkin, bagagens) VALUES
(8, 9, 'Concluído', 3)


-- View para visualizar a fila de decolagem

CREATE OR REPLACE VIEW vw_fila_decolagem_completa AS
SELECT 
    f.id AS id_fila,
    v.id AS id_voo,
    v.destino,
    v.data_saida,
    v.hora_saida,
    f.posicao
FROM fila_decolagem f
JOIN voos v ON f.id_voo = v.id
ORDER BY f.posicao;
SELECT * FROM vw_fila_decolagem_completa;


------------- APRESENTAÇÃO 08/05/2025 --------------

-- 1) View com tabela temporária, com uma consulta usando JOIN

-- Tabela temporária para a consulta de voos atrasados

CREATE TEMPORARY TABLE temp_voos_atrasados AS
SELECT v.id, v.origem, v.destino, v.data_saida, v.hora_saida, 
v.id_companhia,v.id_portao
FROM voos v
WHERE v.status_voo = 'Atrasado';

DROP TABLE temp_voos_atrasados

CREATE VIEW voos_atrasados AS
SELECT 
    t.id,
    t.origem,
    t.destino,
    c.nome_companhia,
    p.nome_portao
FROM temp_voos_atrasados t
JOIN companhias c ON t.id_companhia = c.id
JOIN portoes p ON t.id_portao = p.id;

SELECT * FROM voos_atrasados;

-- 2) Trigger atualiza um determinado campo em uma tabela, depois de um UPDATE

-- Função para delimitar o número de bagagens

CREATE OR REPLACE FUNCTION fn_limite_bagagem()
RETURNS TRIGGER AS
$$
	BEGIN
	IF(tg_op = 'INSERT' OR tg_op = 'UPDATE') THEN
		IF(NEW.bagagens>1) THEN
			RAISE NOTICE 'Passageiro com mais de uma bagagem';
		END IF;
	END IF;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_limite_bagagens
BEFORE INSERT ON checkin
FOR EACH ROW
EXECUTE FUNCTION fn_limite_bagagem();

-- Função para ordenar a fila de decolagem

CREATE OR REPLACE FUNCTION fn_ordenar_fila_voo()
RETURNS TRIGGER AS $$
BEGIN
    WITH fila_ordenada AS (
        SELECT 
            fila_decolagem.id,
            ROW_NUMBER() OVER (
                ORDER BY voos.data_saida, voos.hora_saida
            ) AS nova_posicao
        FROM fila_decolagem
        JOIN voos ON fila_decolagem.id_voo = voos.id
    )
    UPDATE fila_decolagem
    SET posicao = fila_ordenada.nova_posicao
    FROM fila_ordenada
    WHERE fila_decolagem.id = fila_ordenada.id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_ordenar_fila_voo
AFTER INSERT OR UPDATE OR DELETE
ON fila_decolagem
FOR EACH STATEMENT
EXECUTE FUNCTION fn_ordenar_fila_voo();



-- 3) SP que insere registro em tabela, retorna id inserido

-- SP retorna o valor a ser pago por bagagem extra

CREATE OR REPLACE PROCEDURE pd_valor_extra_bg()
AS
$$
	BEGIN
		UPDATE checkin
		SET bagagem_extra_valor = CASE
			WHEN(bagagens>1) THEN (bagagens-1) * 100 
			ELSE 0
			END;
	END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_chama_storage()
RETURNS TABLE(id_passageiros INTEGER) AS
$$
	BEGIN
	CALL pd_valor_extra_bg();
	RETURN QUERY SELECT id_passageiro FROM checkin WHERE bagagens>1;
	END;
$$
LANGUAGE plpgsql;

SELECT fn_chama_storage();


ALTER TABLE checkin ADD bagagem_extra_valor NUMERIC(6,2) DEFAULT 0
SELECT * FROM checkin

-----------------------------------------------------------------------------------------
