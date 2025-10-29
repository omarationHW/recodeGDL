# Casos de Prueba: RptCuentaPublica

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Consulta exitosa con datos existentes | axo=2024, oficina=1 | Respuesta con success=true y data con al menos un registro |
| 2 | Consulta con oficina sin datos | axo=2024, oficina=9999 | Respuesta con success=true y data vacía ([]) |
| 3 | Parámetro axo faltante | axo=null, oficina=1 | Respuesta con success=false y error indicando parámetro requerido |
| 4 | Parámetro oficina faltante | axo=2024, oficina=null | Respuesta con success=false y error indicando parámetro requerido |
| 5 | Parámetros inválidos (texto en vez de número) | axo='abcd', oficina='xyz' | Respuesta con success=false y error de validación |
| 6 | SQL error en SP (simulado) | axo=2024, oficina=1 (con SP alterado para lanzar error) | Respuesta con success=false y mensaje de error SQL |
| 7 | Consulta con año futuro sin datos | axo=2099, oficina=1 | Respuesta con success=true y data vacía ([]) |
