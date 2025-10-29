# Casos de Prueba: Listado de Adeudos Anteriores

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| TC01 | Consulta exitosa de adeudos | axo=1994, oficina=2, periodo=7 | Respuesta JSON con success=true y arreglo de datos con campos id_local, datoslocal, nombre, axo, meses, renta, adeudo, etc. |
| TC02 | Consulta de meses de adeudo de un local | id_local=123, axo=1994 | Respuesta JSON con success=true y arreglo de meses y montos adeudados |
| TC03 | Parámetro año vacío | axo="", oficina=2, periodo=7 | Respuesta JSON con success=false y mensaje de error "The axo field is required." |
| TC04 | Parámetro oficina no numérico | axo=1994, oficina="abc", periodo=7 | Respuesta JSON con success=false y mensaje de error |
| TC05 | Año fuera de rango | axo=1800, oficina=2, periodo=7 | Respuesta JSON con success=true y data vacía |
| TC06 | Consulta sin resultados | axo=1992, oficina=99, periodo=1 | Respuesta JSON con success=true y data vacía |
| TC07 | SQL Injection attempt | axo="1994; DROP TABLE ta_11_adeudo_local;--", oficina=2, periodo=7 | Respuesta JSON con success=false y mensaje de error |
