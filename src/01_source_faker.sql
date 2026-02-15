-- Criação da tabela de origem simulando um e-commerce
-- Utiliza o conector Faker para gerar dados realistas de vendas
CREATE TABLE source_orders (
  orderid INT,
  itemid STRING,
  orderunits DOUBLE,
  address ROW<city STRING, state STRING, zipcode STRING>
) WITH (
  'connector' = 'faker',
  'rows-per-second' = '1',
  'fields.orderid.expression' = '#{number.numberBetween ''1000'',''9999''}',
  'fields.itemid.expression' = '#{bothify ''Item_?#?''}',
  'fields.orderunits.expression' = '#{number.randomDouble ''2'',''1'',''10''}',
  'fields.address.city.expression' = '#{Address.city}',
  'fields.address.state.expression' = '#{Address.state}',
  'fields.address.zipcode.expression' = '#{Address.zipCode}'
);