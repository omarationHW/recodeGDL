# Casos de Uso - ipor

**Categoría:** Form

## Caso de Uso 1: Asignación Masiva de Requerimientos a Ejecutores

**Descripción:** El usuario desea asignar un rango de requerimientos de predial a un ejecutor específico para una fecha determinada.

**Precondiciones:**
El usuario está autenticado y tiene permisos de asignación. Existen requerimientos sin asignar en el rango seleccionado.

**Pasos a seguir:**
1. El usuario filtra los controles de emisión por recaudadora y fecha.
2. Selecciona el control deseado y visualiza los requerimientos asociados.
3. Ingresa el ejecutor, la fecha y el rango de folios a asignar.
4. Hace clic en 'Asignar'.
5. El sistema ejecuta el stored procedure de asignación y retorna el número de requerimientos asignados.

**Resultado esperado:**
Los requerimientos seleccionados quedan asignados al ejecutor y la información se actualiza en la base de datos.

**Datos de prueba:**
{ "tipo": "predial", "ejecutor_id": 123, "fecha": "2024-06-10", "recaud": 1, "folioini": 1000, "foliofin": 1100 }

---

## Caso de Uso 2: Impresión de Requerimientos por Ejecutor

**Descripción:** El usuario desea imprimir todos los requerimientos asignados a un ejecutor en una fecha específica.

**Precondiciones:**
El usuario está autenticado. Existen requerimientos asignados al ejecutor y fecha seleccionados.

**Pasos a seguir:**
1. El usuario filtra los controles y selecciona el ejecutor y la fecha.
2. Selecciona el tipo de impresión (notificación o requerimiento).
3. Hace clic en 'Imprimir'.
4. El sistema retorna los datos para impresión.

**Resultado esperado:**
Se genera un reporte con los requerimientos asignados al ejecutor y fecha seleccionados.

**Datos de prueba:**
{ "fecha": "2024-06-10", "recaud": 1, "tipo_impresion": "notificacion", "ejecutor_id": 123 }

---

## Caso de Uso 3: Visualización de Grid de Multas para Asignación

**Descripción:** El usuario desea visualizar el grid de multas agrupadas por zona/subzona para asignación masiva.

**Precondiciones:**
El usuario está autenticado. Existen multas vigentes en el rango de folios seleccionado.

**Pasos a seguir:**
1. El usuario selecciona el tipo 'multas', recaudadora y rango de folios.
2. Hace clic en 'Ver Grid'.
3. El sistema retorna el grid agrupado por zona/subzona.

**Resultado esperado:**
El usuario visualiza el grid de multas agrupadas y puede proceder a la asignación.

**Datos de prueba:**
{ "tipo": "N", "recaud": 1, "folioini": 2000, "foliofin": 2100 }

---

