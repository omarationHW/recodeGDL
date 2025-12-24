# CargaPagosTexto

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Carga de Pagos Texto (Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo permite importar pagos realizados en el Mercado Libertad a partir de un archivo de texto plano con formato fijo. El proceso incluye:
- Previsualización del archivo y parsing de registros.
- Importación masiva de pagos a la tabla `ta_11_pagos_local`.
- Eliminación automática de adeudos pagados (`ta_11_adeudo_local`).
- Resumen de la importación (pagos grabados, ya existentes, adeudos borrados, importe total).

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js de página completa, sin tabs, con carga de archivo, previsualización y resumen.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedure `sp_importar_pago_texto`.

## Flujo de Trabajo
1. **Carga de Archivo:** El usuario selecciona un archivo `.txt` y lo sube (base64).
2. **Previsualización:** El backend parsea el archivo y devuelve los registros para revisión.
3. **Importación:** El usuario confirma e importa los pagos. Cada registro se procesa vía stored procedure.
4. **Resumen:** Se muestra el resultado de la importación (grabados, ya grabados, adeudos borrados, importe total).

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Métodos:** POST
- **Body:**
  ```json
  {
    "action": "preview_pagos_texto|importar_pagos_texto|resumen_importacion_pagos_texto",
    "payload": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": { ... }
  }
  ```

## Formato del Archivo de Texto
Cada línea representa un pago, con posiciones fijas:
- Id Local: 1-6
- Año: 7-10
- Periodo: 11-12
- Fecha Pago: 13-20 (DDMMYYYY)
- Oficina: 21-23
- Caja: 24
- Operación: 25-29
- Importe: 30-38
- Folio: 39-44
- Fecha Actualización: 45-63
- Id Usuario: 64-66
- Rec: 67-69
- Merc: 70-72

## Validaciones
- El archivo debe ser texto plano, codificado en base64.
- Cada línea debe tener al menos 72 caracteres.
- El importe debe ser numérico.
- No se permite importar pagos duplicados (mismo id_local, año, periodo).

## Seguridad
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).
- El id de usuario del sistema se toma de `auth()->id()`.

## Errores y Manejo de Transacciones
- Toda la importación se realiza en una transacción.
- Si ocurre un error, se hace rollback y se informa al usuario.

## Extensibilidad
- El endpoint puede extenderse para otros formularios de carga masiva.
- El stored procedure puede adaptarse para lógica adicional (validaciones, logs, etc).

## Frontend
- Página Vue.js independiente.
- Permite cargar archivo, previsualizar, importar y ver resumen.
- Mensajes de error y éxito claros.

## Backend
- Controlador Laravel con métodos para cada acción.
- Uso de stored procedure para lógica de importación.

## Base de Datos
- Stored procedure en PostgreSQL para encapsular la lógica de inserción y borrado.

# Esquema de Tablas Relacionadas
- `ta_11_pagos_local`: Pagos realizados.
- `ta_11_adeudo_local`: Adeudos pendientes.

# Seguridad y Auditoría
- El id de usuario que realiza la importación queda registrado en los pagos.
- Se recomienda auditar los logs de importación para trazabilidad.

# Pruebas y Validación
- Casos de uso y pruebas incluidas para asegurar la robustez del proceso.


## Casos de Uso

# Casos de Uso - CargaPagosTexto

**Categoría:** Form

## Caso de Uso 1: Carga Masiva de Pagos desde Archivo de Texto

**Descripción:** El usuario importa un archivo de texto con pagos realizados en el Mercado Libertad. El sistema previsualiza los registros, permite la confirmación y realiza la importación masiva.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para importar pagos. El archivo de texto cumple con el formato requerido.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos Texto.
2. Selecciona el archivo de texto y lo carga.
3. El sistema previsualiza los pagos detectados.
4. El usuario revisa y confirma la importación.
5. El sistema importa los pagos y elimina los adeudos correspondientes.
6. Se muestra un resumen de la importación.

**Resultado esperado:**
Los pagos se importan correctamente, los adeudos pagados se eliminan, y se muestra un resumen con totales.

**Datos de prueba:**
Archivo de texto con 3 líneas de pagos válidos, sin duplicados.

---

## Caso de Uso 2: Intento de Importar Pagos Duplicados

**Descripción:** El usuario intenta importar un archivo que contiene pagos ya registrados previamente.

**Precondiciones:**
Existen pagos en la base de datos con los mismos id_local, año y periodo.

**Pasos a seguir:**
1. El usuario carga el archivo de texto con pagos duplicados.
2. El sistema previsualiza los registros.
3. El usuario confirma la importación.
4. El sistema detecta los duplicados y no los vuelve a grabar.

**Resultado esperado:**
Los pagos duplicados no se importan nuevamente. El resumen indica cuántos ya estaban grabados.

**Datos de prueba:**
Archivo de texto con 2 pagos ya existentes y 1 nuevo.

---

## Caso de Uso 3: Importación con Error de Formato

**Descripción:** El usuario intenta importar un archivo de texto con líneas incompletas o mal formateadas.

**Precondiciones:**
El archivo contiene líneas con menos de 72 caracteres o campos no numéricos.

**Pasos a seguir:**
1. El usuario carga el archivo de texto erróneo.
2. El sistema intenta previsualizar y detecta el error de formato.
3. Se muestra un mensaje de error y no se permite la importación.

**Resultado esperado:**
El sistema rechaza el archivo y muestra un mensaje de error claro.

**Datos de prueba:**
Archivo de texto con una línea de solo 20 caracteres y otra con letras en el campo importe.

---



## Casos de Prueba

# Casos de Prueba: Carga de Pagos Texto

## Caso 1: Importación Exitosa
- **Precondición:** Archivo de texto válido con 3 pagos, ninguno duplicado.
- **Pasos:**
  1. Cargar archivo.
  2. Previsualizar pagos.
  3. Confirmar importación.
- **Esperado:** 3 pagos grabados, 0 ya grabados, 3 adeudos borrados, importe total correcto.

## Caso 2: Pagos Duplicados
- **Precondición:** Archivo de texto con 2 pagos ya existentes y 1 nuevo.
- **Pasos:**
  1. Cargar archivo.
  2. Previsualizar pagos.
  3. Confirmar importación.
- **Esperado:** 1 pago grabado, 2 ya grabados, 1 adeudo borrado, importe total suma solo el nuevo pago.

## Caso 3: Error de Formato en Archivo
- **Precondición:** Archivo de texto con líneas incompletas o campos no numéricos.
- **Pasos:**
  1. Cargar archivo.
  2. Intentar previsualizar.
- **Esperado:** El sistema muestra error de formato y no permite continuar.

## Caso 4: Archivo Vacío
- **Precondición:** Archivo de texto vacío.
- **Pasos:**
  1. Cargar archivo.
  2. Intentar previsualizar.
- **Esperado:** El sistema indica que no hay pagos para importar.

## Caso 5: Importación Parcial (algunos pagos con error)
- **Precondición:** Archivo de texto con 2 pagos válidos y 1 línea malformada.
- **Pasos:**
  1. Cargar archivo.
  2. Previsualizar (debe mostrar solo los válidos).
  3. Confirmar importación.
- **Esperado:** Solo los pagos válidos se importan, el resumen indica cuántos fueron procesados.



