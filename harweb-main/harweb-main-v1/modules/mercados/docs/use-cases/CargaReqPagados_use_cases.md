# Casos de Uso - CargaReqPagados

**Categoría:** Form

## Caso de Uso 1: Carga Masiva de Pagos de Requerimientos

**Descripción:** El usuario carga un archivo TXT con los pagos realizados en el Mercado Libertad y actualiza los requerimientos como pagados.

**Precondiciones:**
El usuario tiene acceso al sistema y cuenta con el archivo TXT generado por el área de recaudación.

**Pasos a seguir:**
1. El usuario accede a la página 'Carga de Pagos Realizados en Mdo. Libertad'.
2. Selecciona el archivo TXT desde su equipo.
3. Visualiza la tabla con los registros parseados.
4. Da clic en 'Actualizar Pagos'.
5. El sistema procesa los registros y muestra los totales de folios grabados, multa y gastos.

**Resultado esperado:**
Los requerimientos correspondientes quedan marcados como pagados en la base de datos. Se muestran los totales correctamente.

**Datos de prueba:**
Archivo TXT con 3 líneas, cada una con folios de requerimientos distintos.

---

## Caso de Uso 2: Carga con Errores en el Archivo

**Descripción:** El usuario intenta cargar un archivo TXT con líneas mal formateadas o con folios inexistentes.

**Precondiciones:**
El usuario tiene acceso y un archivo con errores de formato o folios no existentes.

**Pasos a seguir:**
1. El usuario selecciona el archivo con errores.
2. El sistema parsea y muestra los registros.
3. Al procesar, el backend detecta errores y los reporta en la respuesta.

**Resultado esperado:**
El sistema muestra mensajes de error indicando las líneas o folios problemáticos. No se actualizan registros erróneos.

**Datos de prueba:**
Archivo TXT con una línea con folio inexistente y otra con campos vacíos.

---

## Caso de Uso 3: Consulta de Totales de Última Carga

**Descripción:** El usuario consulta los totales de la última carga de pagos realizada.

**Precondiciones:**
Se ha realizado al menos una carga de pagos.

**Pasos a seguir:**
1. El usuario accede a la página y realiza una carga.
2. Da clic en 'Actualizar Pagos'.
3. El sistema muestra los totales de la carga.

**Resultado esperado:**
Se muestran correctamente los totales de folios grabados, importe de multas y gastos.

**Datos de prueba:**
Archivo TXT con 5 registros válidos.

---

