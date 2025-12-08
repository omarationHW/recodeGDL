# Documentación Técnica: cargadatosfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario cargadatosfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), PostgreSQL 13+
- **Frontend:** Vue.js 3 (Composition API), Axios para llamadas API
- **API:** Unificada, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Base de datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures

## Flujo de Datos
1. **Frontend** solicita datos (por ejemplo, consulta de clave catastral) vía POST `/api/execute` con `{ action: 'getCargadatos', params: { cvecatnva: '...' } }`.
2. **Laravel Controller** recibe la petición, despacha según `action` y llama el stored procedure correspondiente vía DB::select.
3. **Stored Procedure** ejecuta la lógica y retorna los datos en formato JSON o tabla.
4. **Frontend** muestra los datos en la página, permitiendo navegación entre secciones (ubicación, avalúos, construcciones, etc).

## API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getCargadatos",
    "params": { "cvecatnva": "D65J1345001" }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "message": "",
    "data": { ... }
  }
  ```

## Stored Procedures
- Toda la lógica de consulta y actualización se realiza en funciones/stored procedures de PostgreSQL.
- Los procedimientos devuelven datos en formato tabla o JSON.
- Ejemplo: `get_cargadatos`, `get_avaluos`, `get_construcciones`, `get_area_carto`, `save_cargadatos`.

## Frontend (Vue.js)
- Cada formulario es una página independiente (no tabs).
- El usuario ingresa la clave catastral y consulta los datos.
- Se muestran las secciones: Ubicación, Avalúos, Construcciones, Área Cartográfica, Observaciones, Usos de Suelo.
- Navegación entre páginas mediante rutas (ejemplo: `/cargadatos`).
- Manejo de errores y loading.

## Backend (Laravel)
- Controlador único (`CargaDatosController`) con método `execute`.
- Despacha la acción recibida y llama el stored procedure adecuado.
- Validación de parámetros y manejo de errores.
- Retorno de respuesta estándar eResponse.

## Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de parámetros en backend.
- Sanitización de entradas.

## Extensibilidad
- Para agregar nuevas acciones, basta con añadir el case en el controlador y el stored procedure correspondiente.
- El frontend puede consumir cualquier acción nueva sin cambios estructurales.

## Consideraciones de Migración
- Los tabs de Delphi se convierten en páginas independientes.
- Los DataSource y Query de Delphi se reemplazan por llamadas a stored procedures.
- Los eventos de cierre/apertura de queries se simulan en backend (no necesarios en Laravel).
- Los campos y lógica de negocio se mantienen equivalentes.

## Ejemplo de Navegación
- `/cargadatos` → Página de consulta de datos catastrales
- `/avaluos/:cvecatnva` → Página de avalúos de una cuenta
- `/construcciones/:cveavaluo` → Página de construcciones de un avalúo

## Pruebas y Validación
- Se recomienda usar Postman para probar el endpoint `/api/execute`.
- El frontend debe manejar todos los estados (loading, error, success).


## Casos de Prueba

# Casos de Prueba para Formulario cargadatosfrm

## Caso 1: Consulta exitosa de datos catastrales
- **Entrada:** cvecatnva = 'D65J1345001'
- **Acción:** POST /api/execute { action: 'getCargadatos', params: { cvecatnva: 'D65J1345001' } }
- **Resultado esperado:** success=true, data contiene ubicación, propietario, domicilio, etc.

## Caso 2: Consulta de avalúos y construcciones
- **Entrada:** cvecatnva = 'D65J1345001', subpredio = 0
- **Acción:** POST /api/execute { action: 'getAvaluos', params: { cvecatnva: 'D65J1345001', subpredio: 0 } }
- **Resultado esperado:** success=true, data es lista de avalúos
- **Acción secundaria:** POST /api/execute { action: 'getConstrucciones', params: { cveavaluo: <id> } }
- **Resultado esperado:** success=true, data es lista de construcciones

## Caso 3: Error por clave catastral inexistente
- **Entrada:** cvecatnva = 'XXXXXX'
- **Acción:** POST /api/execute { action: 'getCargadatos', params: { cvecatnva: 'XXXXXX' } }
- **Resultado esperado:** success=false, message='No se encontró la clave catastral'

## Caso 4: Actualización exitosa de datos
- **Entrada:** cvecatnva = 'D65J1345001', nombre_completo = 'Juan Pérez', rfc = 'PEPJ800101XXX'
- **Acción:** POST /api/execute { action: 'saveCargadatos', params: { cvecatnva: 'D65J1345001', nombre_completo: 'Juan Pérez', rfc: 'PEPJ800101XXX' } }
- **Resultado esperado:** success=true, data.updated=true

## Caso 5: Error por falta de parámetro obligatorio
- **Entrada:** cvecatnva = ''
- **Acción:** POST /api/execute { action: 'getCargadatos', params: { cvecatnva: '' } }
- **Resultado esperado:** success=false, message='Falta parámetro cvecatnva'

## Casos de Uso

# Casos de Uso - cargadatosfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de datos catastrales por clave

**Descripción:** El usuario ingresa una clave catastral y obtiene toda la información de ubicación, propietario, avalúos, construcciones y área cartográfica.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce una clave catastral válida.

**Pasos a seguir:**
1. El usuario accede a la página /cargadatos.
2. Ingresa la clave catastral en el formulario.
3. Presiona 'Buscar'.
4. El sistema consulta el backend vía /api/execute con action 'getCargadatos'.
5. El backend retorna los datos principales.
6. El frontend muestra la información y consulta los avalúos, construcciones y área cartográfica.

**Resultado esperado:**
Se muestra toda la información relacionada a la clave catastral, incluyendo avalúos y construcciones.

**Datos de prueba:**
{ "cvecatnva": "D65J1345001" }

---

## Caso de Uso 2: Consulta de avalúos y construcciones

**Descripción:** El usuario, tras consultar una clave catastral, navega a la sección de avalúos y visualiza los detalles y construcciones asociadas.

**Precondiciones:**
El usuario ya realizó una consulta de clave catastral válida.

**Pasos a seguir:**
1. El usuario visualiza la sección de avalúos.
2. El sistema consulta /api/execute con action 'getAvaluos'.
3. El usuario selecciona un avalúo y el sistema consulta /api/execute con action 'getConstrucciones'.

**Resultado esperado:**
Se muestran los avalúos y las construcciones asociadas al avalúo seleccionado.

**Datos de prueba:**
{ "cvecatnva": "D65J1345001", "subpredio": 0 }

---

## Caso de Uso 3: Actualización de datos principales de la cuenta

**Descripción:** El usuario actualiza los datos del propietario y domicilio de una cuenta catastral.

**Precondiciones:**
El usuario tiene permisos de edición y una clave catastral válida.

**Pasos a seguir:**
1. El usuario accede a la página de edición de datos.
2. Modifica los campos requeridos.
3. Presiona 'Guardar'.
4. El frontend envía los datos a /api/execute con action 'saveCargadatos'.
5. El backend actualiza los datos y retorna confirmación.

**Resultado esperado:**
Los datos de la cuenta se actualizan correctamente en la base de datos.

**Datos de prueba:**
{ "cvecatnva": "D65J1345001", "nombre_completo": "Juan Pérez", "rfc": "PEPJ800101XXX", ... }

---

