CREATE OR REPLACE FUNCTION loja.atualizar_historico_precos()
RETURNS TRIGGER AS $$
BEGIN
    -- Só registra se o valor realmente mudou
    IF NEW.valor IS DISTINCT FROM OLD.valor THEN
        -- Atualiza o registro anterior no histórico, encerrando sua vigência
        UPDATE loja.historico_precos
        SET data_fim = CURRENT_TIMESTAMP
        WHERE codigo_chocolate = OLD.codigo
          AND data_fim IS NULL;

        -- Insere novo registro com o novo valor
        INSERT INTO loja.historico_precos (codigo_chocolate, valor)
        VALUES (NEW.codigo, NEW.valor);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação do trigger que chama a função após atualização na tabela chocolates
CREATE TRIGGER trg_atualizar_historico_precos
AFTER UPDATE ON loja.chocolates
FOR EACH ROW
EXECUTE FUNCTION loja.atualizar_historico_precos();
