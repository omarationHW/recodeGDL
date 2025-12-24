# PasoEne

## AnÃ¡lisis TÃ©cnico

# PasoEne – Migración de Formulario Delphi a Laravel + Vue.js + PostgreSQL

## Descripción General
El formulario PasoEne permite la carga masiva de pagos de energía eléctrica a partir de archivos de texto plano, su previsualización y la inserción en la base de datos. El proceso se ha migrado a una arquitectura moderna usando Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos con stored procedures).

## Arquitectura
- **Frontend:** Vue.js SPA, página independiente `/pasoene`.
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Base de Datos:** PostgreSQL, lógica de inserción encapsulada en stored procedure `sp_pasoene_insert_pagoenergia`.

## Flujo de Trabajo
1. **Carga de Archivo:** El usuario selecciona un archivo `.txt` con pagos de energía.
2. **Parseo y Previsualización:** El archivo se envía al backend, que lo parsea y devuelve los registros para previsualización.
3. **Ejecución de Actualización:** El usuario confirma y los registros se insertan en la base de datos usando el stored procedure.
4. **Reporte de Resultados:** Se muestra el número de registros insertados y los errores encontrados.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "parse_txt" | "bulk_insert" | "preview",
    "data": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "status": "ok" | "error",
    "data": { ... },
    "errors": [ ... ]
  }
  ```

## Stored Procedure
- Toda la lógica de inserción se realiza en `sp_pasoene_insert_pagoenergia`, que valida y transforma los datos antes de insertarlos.

## Seguridad y Validaciones
- El backend valida el formato de fechas y tipos de datos.
- Los errores de inserción se reportan por línea.
- El endpoint está protegido por autenticación Laravel (middleware estándar).

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas con PasoEne.
- El frontend puede ser adaptado para otros formularios similares.

## Integración
- El frontend y backend se comunican exclusivamente por JSON.
- El frontend no accede directamente a la base de datos.

## Requisitos de Infraestructura
- Laravel 10+, PHP 8.1+
- Vue.js 3+
- PostgreSQL 13+

## Consideraciones de Migración
- El parseo de archivos respeta el layout fijo del archivo original Delphi.
- Los errores de formato se reportan inmediatamente.
- El proceso es idempotente: si un registro ya existe, el SP puede ser adaptado para ignorar o actualizar según reglas de negocio.


## Casos de Uso

# Casos de Uso - PasoEne

**Categoría:** Form

## Caso de Uso 1: Carga Masiva de Pagos de Energía desde Archivo TXT

**Descripción:** El usuario carga un archivo de pagos de energía eléctrica generado por el sistema legacy y lo inserta en la base de datos.

**Precondiciones:**
El usuario tiene acceso al sistema y un archivo TXT válido con pagos de energía.

**Pasos a seguir:**
1. El usuario accede a la página PasoEne.
2. Selecciona el archivo TXT de pagos.
3. El sistema parsea y muestra la previsualización de los registros.
4. El usuario revisa y confirma la carga.
5. El sistema ejecuta la inserción masiva y muestra el resultado.

**Resultado esperado:**
Todos los registros válidos se insertan en la tabla ta_11_pago_energia. Se reportan los errores de formato o inserción.

**Datos de prueba:**
Archivo TXT con 10 registros de pagos de energía, incluyendo uno con fecha malformada.

---

## Caso de Uso 2: Validación de Formato de Archivo

**Descripción:** El usuario intenta cargar un archivo TXT con líneas malformadas.

**Precondiciones:**
El usuario tiene acceso y un archivo TXT con líneas incompletas o datos corruptos.

**Pasos a seguir:**
1. El usuario accede a PasoEne.
2. Selecciona el archivo TXT con errores.
3. El sistema parsea y muestra los errores detectados.

**Resultado esperado:**
El sistema no permite la carga masiva y muestra los errores de formato.

**Datos de prueba:**
Archivo TXT con 5 líneas, 2 de ellas con menos de 100 caracteres.

---

## Caso de Uso 3: Carga Parcial con Errores de Inserción

**Descripción:** El usuario carga un archivo donde algunos registros ya existen o violan restricciones.

**Precondiciones:**
El usuario tiene acceso y un archivo TXT con registros duplicados o con claves foráneas inválidas.

**Pasos a seguir:**
1. El usuario accede a PasoEne.
2. Selecciona el archivo TXT.
3. El sistema parsea y muestra la previsualización.
4. El usuario ejecuta la carga masiva.
5. El sistema inserta los registros válidos y reporta los errores de los inválidos.

**Resultado esperado:**
Solo los registros válidos se insertan. Se reportan los errores de duplicidad o integridad.

**Datos de prueba:**
Archivo TXT con 8 registros, 3 de ellos con id_energia inexistente.

---



## Casos de Prueba

# Casos de Prueba PasoEne

## 1. Carga Correcta de Archivo TXT
- **Entrada:** Archivo TXT con 5 líneas válidas.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** 5 registros insertados, sin errores.

## 2. Archivo con Fechas Malformadas
- **Entrada:** Archivo TXT con 3 líneas, una con fecha '32/13/2022'.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** 2 registros insertados, 1 error reportado por formato de fecha.

## 3. Archivo con Registros Duplicados
- **Entrada:** Archivo TXT con 4 líneas, dos con el mismo id_energia, axo, periodo.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** 2 registros insertados, 2 errores de duplicidad reportados.

## 4. Archivo con Claves Foráneas Inválidas
- **Entrada:** Archivo TXT con 3 líneas, una con id_energia inexistente.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** 2 registros insertados, 1 error de integridad referencial.

## 5. Archivo Vacío
- **Entrada:** Archivo TXT vacío.
- **Acción:** Cargar y ejecutar actualización.
- **Esperado:** Mensaje de error 'No hay registros para procesar'.

## 6. Interrupción de Red
- **Entrada:** Archivo TXT válido.
- **Acción:** Simular desconexión de red durante la carga.
- **Esperado:** Mensaje de error de red, sin registros insertados.



