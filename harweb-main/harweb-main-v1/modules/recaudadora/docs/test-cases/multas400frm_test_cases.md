# Casos de Prueba para multas400frm

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|--------------------|
| TC01 | Consulta multa federal por acta existente | dependencia: 'DIRECCION1', anioActa: 2023, numActa: 12345 | Se muestra el registro correcto |
| TC02 | Consulta multa federal por acta inexistente | dependencia: 'NOEXISTE', anioActa: 2022, numActa: 99999 | No se muestran resultados |
| TC03 | Búsqueda municipal por nombre parcial | nombre: '%PEREZ%' | Se listan todas las coincidencias |
| TC04 | Búsqueda federal por domicilio exacto | ubicacion: 'AV. INDEPENDENCIA 100' | Se muestran los registros coincidentes |
| TC05 | Búsqueda municipal por domicilio inexistente | ubicacion: 'CALLE INVENTADA 999' | Mensaje de 'No se encontraron resultados' |
| TC06 | Error de parámetros (falta de campo requerido) | dependencia: '', anioActa: '', numActa: '' | Mensaje de error en la consulta |
| TC07 | Consulta con caracteres especiales | nombre: 'O\'CONNOR' | Se muestran los registros coincidentes o mensaje de error si hay fallo de escape |
