# Casos de Uso - ActualizaFechaEmpresas

**Categoría:** Form

## Caso de Uso 1: Carga y actualización masiva de fechas de práctica para empresas

**Descripción:** El usuario carga un archivo de texto con folios de empresas y actualiza en lote la fecha de práctica de todos los folios.

**Precondiciones:**
El usuario tiene permisos de acceso y el archivo de texto está correctamente formateado.

**Pasos a seguir:**
1. El usuario accede a la página de Actualiza Fecha de Empresas.
2. Selecciona el ejecutor y la fecha de corte.
3. Selecciona el archivo de texto y lo carga.
4. Visualiza la tabla de folios parseados.
5. Presiona 'Actualizar Todos'.
6. El sistema procesa y actualiza los folios en la base de datos.

**Resultado esperado:**
Todos los folios existentes se actualizan correctamente. Se muestra un resumen de folios aplicados, pendientes y errores.

**Datos de prueba:**
Archivo de texto con 10 folios válidos y 2 con cuentas inexistentes.

---

## Caso de Uso 2: Actualización individual de fecha de práctica para un folio

**Descripción:** El usuario actualiza la fecha de práctica de un solo folio desde la tabla.

**Precondiciones:**
El folio existe en la base de datos.

**Pasos a seguir:**
1. El usuario carga el archivo de texto.
2. Visualiza la tabla de folios.
3. Presiona 'Actualizar' en la fila deseada.
4. El sistema actualiza solo ese folio.

**Resultado esperado:**
El folio seleccionado se actualiza y su estado cambia a 'ACTUALIZADO'.

**Datos de prueba:**
Archivo de texto con al menos un folio válido.

---

## Caso de Uso 3: Manejo de errores al actualizar folios inexistentes

**Descripción:** El sistema debe manejar correctamente los folios que no existen en la base de datos.

**Precondiciones:**
El archivo contiene folios con cuentas inexistentes.

**Pasos a seguir:**
1. El usuario carga el archivo de texto.
2. Presiona 'Actualizar Todos'.
3. El sistema procesa y reporta los folios inexistentes como errores.

**Resultado esperado:**
Los folios inexistentes aparecen en la lista de errores y no se actualizan.

**Datos de prueba:**
Archivo de texto con 5 folios válidos y 3 inválidos.

---

