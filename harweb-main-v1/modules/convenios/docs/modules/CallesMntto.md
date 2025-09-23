# Documentación Técnica: Migración Formulario CallesMntto (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` (eRequest/eResponse)
- **Frontend:** Vue.js 3 (SPA), componente de página independiente para CallesMntto
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Patrón de Comunicación:**
  - Todas las operaciones (catálogos, CRUD, consultas) se realizan vía POST a `/api/execute` con un JSON `{ action, params }`
  - El backend interpreta `action` y llama al stored procedure correspondiente
  - El frontend es desacoplado, sólo conoce el API unificado

## Endpoints
- **POST /api/execute**
  - **Body:** `{ action: string, params: object }`
  - **Ejemplo:** `{ "action": "insertCalle", "params": { ... } }`
  - **Respuesta:** `{ success: bool, data: any, message: string }`

## Stored Procedures
- Todos los catálogos y operaciones CRUD se implementan como funciones PostgreSQL (`sp_*`)
- Los procedimientos devuelven tablas (para catálogos y consultas) o `{success, message}` para operaciones

## Seguridad
- El controlador utiliza el usuario autenticado (`$request->user()`) para registrar el `id_usuario` en inserciones/actualizaciones
- Validación de parámetros en backend (Laravel Validator)
- El frontend valida campos requeridos y tipos básicos

## Flujo de Operación
1. **Carga de Catálogos:**
   - El frontend llama a `action: getCatalogs` para obtener colonias, tipos, servicios y cuentas
2. **Consulta de Calles:**
   - El frontend llama a `action: getCalle` con colonia y calle
3. **Alta de Calle:**
   - El usuario llena el formulario y envía `action: insertCalle` con los datos
   - El backend llama a `sp_insert_calle` y retorna éxito o error
4. **Edición de Calle:**
   - El usuario selecciona una calle existente, edita y envía `action: updateCalle`
   - El backend llama a `sp_update_calle`

## Estructura de la Tabla `ta_17_calles`
- colonia (smallint, PK)
- calle (smallint, PK)
- tipo (smallint)
- servicio (smallint)
- desc_calle (varchar)
- axo_obra (smallint)
- cuenta_ingreso (integer)
- vigencia_obra (varchar)
- id_usuario (integer)
- fecha_actual (timestamp)
- plazo (smallint)
- clave_plazo (varchar)
- cuenta_rezago (integer)

## Validaciones
- Todos los campos requeridos deben estar presentes
- Los valores numéricos deben estar en rango
- La combinación colonia+calle debe ser única para inserción

## Manejo de Errores
- Los stored procedures devuelven `success=false` y un mensaje descriptivo en caso de error
- El frontend muestra el mensaje en un alert

## Navegación
- Cada formulario es una página independiente (no tabs)
- Breadcrumbs para navegación contextual

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- Los stored procedures pueden evolucionar sin afectar el frontend
