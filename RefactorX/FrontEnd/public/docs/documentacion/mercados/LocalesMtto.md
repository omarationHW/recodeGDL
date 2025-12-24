# LocalesMtto

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario LocalesMtto (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 (Composition API), componente de página independiente, navegación por rutas
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Seguridad:** Validación de datos en backend y frontend, manejo de errores centralizado

## Flujo de Trabajo
1. **Carga de Catálogos:**
   - Al cargar la página, el frontend solicita `/api/execute` con `action: get_catalogs`.
   - El backend ejecuta los SPs de catálogo y retorna los datos para recaudadoras, secciones, zonas y cuotas.

2. **Búsqueda de Local:**
   - El usuario llena los campos clave y presiona "Buscar".
   - Se envía `action: buscar_local` con los parámetros.
   - El backend ejecuta el SP `buscar_local` y retorna si existe el local.

3. **Alta de Local:**
   - Si el local no existe, se habilita el formulario de alta.
   - Al enviar, se valida en frontend y backend.
   - Se ejecuta el SP `alta_local`, que:
     - Inserta en `ta_11_locales`.
     - Inserta en `ta_11_movimientos`.
     - Genera adeudos en `ta_11_adeudo_local` desde la fecha de alta hasta la fecha actual.

4. **Respuesta:**
   - El backend responde con éxito o error detallado.
   - El frontend muestra mensajes y limpia el formulario si corresponde.

## API: Endpoint Único
- **Ruta:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "success": true|false,
    "data": { ... },
    "message": "..."
  }
  ```

## Validaciones
- Todos los campos requeridos se validan en frontend y backend.
- Fechas válidas, números positivos, campos obligatorios.
- No se permite alta si el local ya existe.
- No se permite alta con fecha anterior a 2003.

## Stored Procedures
- Toda la lógica de inserción, generación de adeudos y consultas está en SPs.
- Los SPs devuelven errores con `RAISE EXCEPTION` si ocurre algún problema.

## Seguridad
- El endpoint requiere autenticación (no implementado aquí, pero debe usarse JWT o sesión Laravel).
- El `id_usuario` debe provenir del usuario autenticado.

## Frontend
- Página Vue.js independiente, sin tabs.
- Navegación breadcrumb.
- Formulario reactivo, mensajes de error y éxito.
- Catálogos cargados al inicio.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los SPs pueden ser reutilizados por otros módulos.

# Notas de Migración
- Los nombres de tablas y campos se mantienen fieles al modelo original.
- Se asume que los triggers de auditoría y restricciones de integridad existen en la BD.
- El SP `alta_local` es atómico: si falla algo, hace rollback.

# Pruebas y Debug
- Todos los errores de SPs se devuelven como mensaje en el JSON.
- El frontend muestra los mensajes de error y éxito.


## Casos de Uso

# Casos de Uso - LocalesMtto

**Categoría:** Form

## Caso de Uso 1: Alta de Local Nuevo

**Descripción:** Un usuario desea dar de alta un nuevo local en un mercado específico.

**Precondiciones:**
El usuario tiene permisos y conoce los datos del local. El local no existe.

**Pasos a seguir:**
1. El usuario ingresa a la página de Altas de Locales.
2. Selecciona la recaudadora, mercado, categoría, sección, local, letra y bloque.
3. Presiona 'Buscar'.
4. El sistema indica que el local no existe.
5. El usuario llena los datos: nombre, giro, sector, domicilio, superficie, zona, descripción, clave cuota, fecha alta, número memo.
6. Presiona 'Alta Local'.
7. El sistema valida y da de alta el local, movimientos y adeudos.

**Resultado esperado:**
El local se da de alta correctamente y aparece en la base de datos.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado": 10,
  "categoria": 1,
  "seccion": "SS",
  "local": 123,
  "letra_local": "A",
  "bloque": "B",
  "nombre": "JUAN PEREZ",
  "giro": 5,
  "sector": "J",
  "domicilio": "CALLE 123",
  "zona": 1,
  "descripcion_local": "PUESTO DE FRUTAS",
  "superficie": 12.5,
  "fecha_alta": "2024-06-01",
  "clave_cuota": 1001,
  "numero_memo": 456,
  "vigencia": "A",
  "id_usuario": 1,
  "axo": 2024
}

---

## Caso de Uso 2: Intento de Alta de Local Existente

**Descripción:** El usuario intenta dar de alta un local que ya existe.

**Precondiciones:**
El local ya existe en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa los datos de un local existente y presiona 'Buscar'.
2. El sistema indica que el local ya existe.
3. El usuario no puede continuar con el alta.

**Resultado esperado:**
El sistema bloquea el alta y muestra mensaje de error.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado": 10,
  "categoria": 1,
  "seccion": "SS",
  "local": 123,
  "letra_local": "A",
  "bloque": "B"
}

---

## Caso de Uso 3: Validación de Campos Obligatorios

**Descripción:** El usuario omite campos obligatorios y trata de dar de alta un local.

**Precondiciones:**
El usuario está en el formulario de alta.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'nombre' y presiona 'Alta Local'.
2. El sistema valida y muestra mensaje de error.

**Resultado esperado:**
El sistema no permite el alta y muestra el mensaje 'The nombre field is required.'

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado": 10,
  "categoria": 1,
  "seccion": "SS",
  "local": 124,
  "letra_local": "B",
  "bloque": "C",
  "nombre": "",
  "giro": 5,
  "sector": "J",
  "domicilio": "CALLE 123",
  "zona": 1,
  "descripcion_local": "PUESTO DE FRUTAS",
  "superficie": 12.5,
  "fecha_alta": "2024-06-01",
  "clave_cuota": 1001,
  "numero_memo": 456,
  "vigencia": "A",
  "id_usuario": 1,
  "axo": 2024
}

---



## Casos de Prueba

# Casos de Prueba para LocalesMtto

## 1. Alta de Local Nuevo
- **Entrada:** Datos completos y válidos de un local inexistente
- **Acción:** Buscar y luego Alta Local
- **Esperado:** Respuesta success true, local creado, adeudos generados

## 2. Alta de Local Existente
- **Entrada:** Datos de un local ya existente
- **Acción:** Buscar
- **Esperado:** Respuesta success true, data.length > 0, frontend bloquea alta

## 3. Validación de Campos Obligatorios
- **Entrada:** Falta campo 'nombre'
- **Acción:** Alta Local
- **Esperado:** Respuesta success false, message 'The nombre field is required.'

## 4. Validación de Giro y Superficie
- **Entrada:** giro = 0 o superficie = 0
- **Acción:** Alta Local
- **Esperado:** Respuesta success false, mensaje de error correspondiente

## 5. Fecha de Alta menor a 2003
- **Entrada:** fecha_alta = '2002-12-31'
- **Acción:** Alta Local
- **Esperado:** Respuesta success false, mensaje de error

## 6. Generación de Adeudos
- **Entrada:** Alta local con fecha_alta = '2024-01-01'
- **Acción:** Alta Local
- **Esperado:** Se generan adeudos desde 2024-01 hasta fecha actual

## 7. Catálogos
- **Entrada:** Cargar página
- **Acción:** loadCatalogs()
- **Esperado:** Se reciben todos los catálogos correctamente



