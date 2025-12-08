# Documentación Técnica: tipobloqueofrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario tipobloqueofrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de bloqueo de licencias, permitiendo seleccionar un tipo de bloqueo y registrar el motivo. La migración se realizó desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Frontend:** Vue.js SPA, componente de página independiente para el formulario de bloqueo.
- **Backend:** Laravel API, controlador unificado para todas las operaciones vía `/api/execute` usando el patrón `eRequest`/`eResponse`.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "eRequest": "nombre_operacion",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

### Operaciones Soportadas
- `get_tipo_bloqueo_catalog`: Devuelve el catálogo de tipos de bloqueo activos.
- `bloquear_licencia`: Registra un bloqueo de licencia con tipo y motivo.

## 4. Stored Procedures
- **get_tipo_bloqueo_catalog:** Devuelve los tipos de bloqueo activos (`sel_cons = 'S'`).
- **bloquear_licencia:** Valida y registra el bloqueo en la tabla `bloqueos_licencia`.

## 5. Estructura de Tablas (Ejemplo)
- **c_tipobloqueo:** Catálogo de tipos de bloqueo (`id`, `descripcion`, `sel_cons`)
- **licencias:** Licencias a bloquear (`id`, ...)
- **bloqueos_licencia:** Historial de bloqueos (`id`, `licencia_id`, `tipo_bloqueo_id`, `motivo`, `usuario_id`, `fecha`)

## 6. Frontend (Vue.js)
- Página independiente con ruta propia.
- Formulario con select para tipo de bloqueo y campo de texto para motivo.
- Botones Aceptar/Cancelar.
- Mensajes de éxito/error.
- Navegación breadcrumb.

## 7. Seguridad
- Validación de parámetros en backend y frontend.
- El usuario debe estar autenticado (en ejemplo, `usuario_id` es simulado).
- Validación de existencia de licencia y tipo de bloqueo en el SP.

## 8. Extensibilidad
- Se pueden agregar más operaciones al endpoint `/api/execute` siguiendo el patrón `eRequest`.
- El frontend puede ser reutilizado para otros formularios similares.

## 9. Consideraciones
- El ID de licencia debe ser pasado como prop o parámetro de ruta al componente Vue.
- El usuario autenticado debe ser gestionado por el sistema de autenticación real.

## 10. Errores y Mensajes
- Todos los errores y mensajes se devuelven en el campo `message` de la respuesta.

## Casos de Prueba

## Casos de Prueba para Formulario tipobloqueofrm

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Bloqueo exitoso con datos válidos | tipo_bloqueo_id=2, motivo='FALTA DE PAGO', usuario_id=1, licencia_id=1001 | Bloqueo registrado correctamente. |
| 2 | Tipo de bloqueo inválido | tipo_bloqueo_id=999, motivo='PRUEBA', usuario_id=1, licencia_id=1001 | Tipo de bloqueo inválido. |
| 3 | Licencia inexistente | tipo_bloqueo_id=2, motivo='PRUEBA', usuario_id=1, licencia_id=9999 | Licencia no encontrada. |
| 4 | Motivo vacío | tipo_bloqueo_id=2, motivo='', usuario_id=1, licencia_id=1001 | Error de validación: motivo requerido. |
| 5 | Cancelar formulario | - | No se realiza ningún cambio, regresa a la página anterior. |
| 6 | Cargar catálogo de tipos de bloqueo | - | Lista de tipos de bloqueo activos mostrada en el select. |

## Casos de Uso

# Casos de Uso - tipobloqueofrm

**Categoría:** Form

## Caso de Uso 1: Bloquear una licencia con motivo válido

**Descripción:** El usuario selecciona un tipo de bloqueo válido y proporciona un motivo para bloquear una licencia existente.

**Precondiciones:**
El usuario está autenticado y la licencia existe en la base de datos.

**Pasos a seguir:**
1. Acceder a la página de bloqueo de licencia.
2. Seleccionar un tipo de bloqueo del catálogo.
3. Ingresar un motivo válido (ejemplo: 'DOCUMENTACIÓN INCOMPLETA').
4. Hacer clic en 'Aceptar'.

**Resultado esperado:**
El sistema registra el bloqueo y muestra el mensaje 'Bloqueo registrado correctamente.'

**Datos de prueba:**
{ "tipo_bloqueo_id": 2, "motivo": "DOCUMENTACIÓN INCOMPLETA", "usuario_id": 1, "licencia_id": 1001 }

---

## Caso de Uso 2: Intentar bloquear una licencia con tipo de bloqueo inválido

**Descripción:** El usuario intenta bloquear una licencia seleccionando un tipo de bloqueo que no está activo o no existe.

**Precondiciones:**
El usuario está autenticado y la licencia existe.

**Pasos a seguir:**
1. Acceder a la página de bloqueo de licencia.
2. Seleccionar un tipo de bloqueo inválido (por ejemplo, ID no existente).
3. Ingresar un motivo.
4. Hacer clic en 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Tipo de bloqueo inválido.' y no registra el bloqueo.

**Datos de prueba:**
{ "tipo_bloqueo_id": 999, "motivo": "PRUEBA", "usuario_id": 1, "licencia_id": 1001 }

---

## Caso de Uso 3: Cancelar el proceso de bloqueo

**Descripción:** El usuario decide no continuar con el bloqueo y cancela el formulario.

**Precondiciones:**
El usuario está en la página de bloqueo de licencia.

**Pasos a seguir:**
1. Acceder a la página de bloqueo de licencia.
2. Hacer clic en 'Cancelar'.

**Resultado esperado:**
El sistema regresa a la página anterior sin realizar ningún cambio.

**Datos de prueba:**
No aplica

---


