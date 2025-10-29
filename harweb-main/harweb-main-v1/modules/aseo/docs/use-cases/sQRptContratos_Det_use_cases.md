# Casos de Uso - sQRptContratos_Det

**Categoría:** Form

## Caso de Uso 1: Consulta de todos los contratos vigentes, clasificados por número de contrato

**Descripción:** El usuario desea obtener el listado completo de contratos vigentes, ordenados por número de contrato.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos vigentes en la base de datos.

**Pasos a seguir:**
1. Ingresar a la página 'Padron de Contratos'.
2. Seleccionar 'Vigentes' en el filtro de Vigencia.
3. Seleccionar 'Numero de Contrato' en Clasificación.
4. Dejar Recaudadora en 0 (todas).
5. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con todos los contratos vigentes, ordenados por número de contrato. El resumen muestra el total de contratos y el número de vigentes/cancelados.

**Datos de prueba:**
vigencia: 'V', ofna: 0, opcion: 2, num_emp: null

---

## Caso de Uso 2: Consulta de contratos cancelados de una recaudadora específica

**Descripción:** El usuario requiere ver los contratos cancelados asociados a una recaudadora específica.

**Precondiciones:**
Existen contratos cancelados para la recaudadora con ID 5.

**Pasos a seguir:**
1. Ingresar a la página 'Padron de Contratos'.
2. Seleccionar 'Cancelados' en Vigencia.
3. Ingresar '5' en el campo Recaudadora.
4. Seleccionar cualquier clasificación.
5. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se listan solo los contratos cancelados de la recaudadora 5. El resumen muestra el total y el número de cancelados.

**Datos de prueba:**
vigencia: 'C', ofna: 5, opcion: 1, num_emp: null

---

## Caso de Uso 3: Consulta de contratos por domicilio, todos los estados de vigencia

**Descripción:** El usuario desea ver todos los contratos, clasificados por domicilio, sin importar su vigencia.

**Precondiciones:**
Existen contratos con diferentes domicilios y estados de vigencia.

**Pasos a seguir:**
1. Ingresar a la página 'Padron de Contratos'.
2. Seleccionar 'Todos' en Vigencia.
3. Seleccionar 'Domicilio' en Clasificación.
4. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestra la tabla de contratos agrupados por domicilio, con todos los estados de vigencia. El resumen muestra totales correctos.

**Datos de prueba:**
vigencia: 'T', ofna: 0, opcion: 8, num_emp: null

---

