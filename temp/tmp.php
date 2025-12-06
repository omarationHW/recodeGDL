<?php
\ = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');
\ = \->query("SELECT * FROM publico.ta_11_locales LIMIT 0");
for(\=0; \<\->columnCount(); \++) {
  \ = \->getColumnMeta(\);
  echo \['name'] . ' => ' . \['native_type'] . PHP_EOL;
}
