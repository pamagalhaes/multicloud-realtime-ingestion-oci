-- Definição da tabela de destino (Tópico VIP)
-- Estes dados serão lidos pelo Sink Connector para envio à OCI
CREATE TABLE oci_vip_orders (
  orderid INT,
  itemid STRING,
  orderunits DOUBLE
) WITH (
  'connector' = 'confluent'
);