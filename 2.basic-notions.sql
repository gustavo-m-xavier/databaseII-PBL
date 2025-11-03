-- Criando o cargo
CREATE ROLE funcionarios_loja;

-- Criando os usuários
CREATE USER vendedor;
CREATE USER gerente;
CREATE USER marketing;

-- Atribuindo os usuários ao cargo
GRANT funcionarios_loja TO vendedor;
GRANT funcionarios_loja TO gerente;
GRANT funcionarios_loja TO marketing;

-- Revogar permissões diretas
REVOKE ALL ON loja.chocolates FROM vendedor;
REVOKE ALL ON loja.chocolates FROM gerente;
REVOKE ALL ON loja.chocolates FROM marketing;

-- Conceder permissões ao cargo
GRANT SELECT, UPDATE ON loja.chocolates TO funcionarios_loja;

-- Ver privilégios por tabela
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'loja' AND table_name = 'chocolates';

-- Ver membros do cargo
SELECT * FROM pg_roles WHERE rolname = 'funcionarios_loja';



-- Funcionamento de uma auditoria simples

-- Criando a tabela de auditoria
CREATE TABLE loja.log_precos (
    id SERIAL PRIMARY KEY,
    usuario TEXT,
    codigo_chocolate INT,
    valor_antigo NUMERIC(10,2),
    valor_novo NUMERIC(10,2),
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Criando a função de auditoria
CREATE OR REPLACE FUNCTION loja.auditar_precos_gerente()
RETURNS TRIGGER AS $$
BEGIN
    IF CURRENT_USER = 'gerente' AND NEW.valor IS DISTINCT FROM OLD.valor THEN
        INSERT INTO loja.log_precos (usuario, codigo_chocolate, valor_antigo, valor_novo)
        VALUES (CURRENT_USER, OLD.codigo, OLD.valor, NEW.valor);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criando o trigger de auditoria
CREATE TRIGGER trigger_auditar_precos
AFTER UPDATE OF valor ON loja.chocolates
FOR EACH ROW
EXECUTE FUNCTION loja.auditar_precos_gerente();

-- Exemplo de atualização para testar a auditoria
-- Atualização feita pelo gerente
SET ROLE gerente;
UPDATE loja.chocolates SET valor = 25.00 WHERE codigo = 1;

-- Verificando os logs de auditoria
SELECT * FROM loja.log_precos;


