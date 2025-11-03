-- View de chocolates por marca
CREATE OR REPLACE VIEW loja.vw_chocolates_por_marca AS
SELECT
    m.nome AS marca,
    c.nome AS chocolate,
    c.valor
FROM loja.chocolates c
JOIN loja.marca m ON c.codigo_marca = m.codigo;

-- View de histórico de preços
CREATE OR REPLACE VIEW loja.vw_historico_precos AS
SELECT
    c.nome AS chocolate,
    h.valor,
    h.data_inicio,
    h.data_fim
FROM loja.historico_precos h
JOIN loja.chocolates c ON h.codigo_chocolate = c.codigo;
