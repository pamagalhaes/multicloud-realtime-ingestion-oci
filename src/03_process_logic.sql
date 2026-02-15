-- Lógica de Filtragem (ETL em Tempo Real)
-- Regra de Negócio: Apenas pedidos com mais de 5 unidades são relevantes
INSERT INTO oci_vip_orders
SELECT 
    orderid, 
    itemid, 
    orderunits
FROM source_orders
WHERE orderunits > 5;