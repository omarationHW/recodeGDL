# Casos de Uso - RptAdeudosPrediosSaldoAnt

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de adeudos de predios saldo anterior

**Descripción:** El usuario desea obtener un listado de predios con su saldo anterior, pagos realizados y saldo actual en un rango de fechas y estado.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página 'Reporte de Adeudos Predios - Saldo Anterior'.
2. Selecciona un subtipo de predio del catálogo.
3. Selecciona la fecha desde y hasta.
4. Selecciona el estado (VIGENTES, BAJA, PAGADOS).
5. Presiona 'Consultar'.
6. El sistema muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una tabla con los predios filtrados, mostrando manzana, lote, letra, nombre, domicilio, saldo anterior, pagos, saldo actual y recargos.

**Datos de prueba:**
subtipo: 1
fechadsd: 2024-01-01
fechahst: 2024-06-30
est: 'A'

---

## Caso de Uso 2: Obtención de subtipos de predios para el catálogo

**Descripción:** El frontend necesita mostrar el catálogo de subtipos de predios para el filtro.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Al cargar la página, el frontend solicita los subtipos disponibles vía API.
2. El backend retorna la lista de subtipos.

**Resultado esperado:**
El select de subtipos se llena correctamente.

**Datos de prueba:**
tipo: 14

---

## Caso de Uso 3: Consulta de saldo anterior de un predio específico

**Descripción:** El usuario desea conocer el saldo anterior de un predio antes de una fecha dada.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario selecciona un predio y una fecha.
2. El frontend solicita el saldo anterior vía API.
3. El backend retorna el saldo anterior.

**Resultado esperado:**
Se muestra el saldo anterior correctamente.

**Datos de prueba:**
subtipo: 1
id_conv_predio: 1234
fechadsd: 2024-01-01

---

