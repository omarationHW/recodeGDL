# Documentación: CatastroDM

## Análisis Técnico

# Documentación Técnica - Migración CatastroDM Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Patrón API:** eRequest/eResponse, entrada y salida JSON.

## Flujo de Trabajo
1. **El usuario accede a la página de descuentos predial.**
2. **Busca una cuenta por clave catastral.**
3. **El sistema consulta la cuenta y muestra los adeudos y descuentos vigentes.**
4. **El usuario puede agregar un nuevo descuento, que se inserta vía stored procedure.**
5. **El usuario puede cancelar un descuento vigente.**

## Endpoints y Acciones
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: 'nombre_accion', params: { ... } } }`
  - Salida: `{ eResponse: { success, data, message } }`

### Acciones soportadas
- `getCuentaByClave`: Busca cuenta por clave catastral
- `getAdeudosByCuenta`: Lista adeudos de la cuenta
- `insertDescuentoPredial`: Inserta descuento
- `getDescuentosPredial`: Lista descuentos
- `cancelarDescuentoPredial`: Cancela descuento
- `getUsuarios`: Lista usuarios activos
- `getCatalogoDescuentos`: Catálogo de tipos de descuento

## Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de parámetros en backend y frontend.
- Control de permisos para acciones de alta/cancelación.

## Integración Vue.js
- Cada formulario es una página Vue independiente.
- Navegación por rutas, sin tabs.
- Uso de fetch/AJAX para consumir `/api/execute`.
- Manejo de errores y mensajes de usuario.

## Migración de Stored Procedures
- Toda la lógica SQL de Delphi se encapsula en funciones y procedimientos PostgreSQL.
- Los procedimientos se llaman desde Laravel vía DB::select o DB::statement.

## Consideraciones
- El endpoint `/api/execute` es el único punto de entrada para todas las operaciones.
- El frontend debe manejar la estructura eRequest/eResponse.
- Los formularios deben ser independientes y no usar tabs.

# Ejemplo de Llamada API
```json
POST /api/execute
{
  "eRequest": {
    "action": "getCuentaByClave",
    "params": { "clave": "D65J1234567" }
  }
}
```

# Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": { "cvecuenta": 12345, ... },
    "message": ""
  }
}
```

# Notas
- Todos los formularios Delphi deben migrarse como páginas Vue independientes.
- Los stored procedures deben cubrir toda la lógica de negocio y validación de datos.
- El endpoint `/api/execute` debe ser el único punto de acceso para el frontend.

## Casos de Uso

# Casos de Uso - CatastroDM

**Categoría:** Form

## Caso de Uso 1: Alta de Descuento Predial

**Descripción:** El usuario ingresa la clave catastral, consulta la cuenta y registra un nuevo descuento predial.

**Precondiciones:**
El usuario tiene permisos de alta. La cuenta existe y tiene adeudos.

**Pasos a seguir:**
1. El usuario accede a la página de descuentos predial.
2. Ingresa la clave catastral y presiona 'Buscar'.
3. El sistema muestra los datos de la cuenta y los adeudos.
4. El usuario llena el formulario de descuento (tipo, bimestre, solicitante, observaciones).
5. Presiona 'Agregar'.
6. El sistema inserta el descuento y lo muestra en la lista.

**Resultado esperado:**
El descuento aparece en la lista de descuentos vigentes para la cuenta.

**Datos de prueba:**
{ "clave": "D65J1234567", "cvedescuento": 1, "bimini": 1, "bimfin": 6, "solicitante": "Juan Perez", "observaciones": "Descuento por pronto pago" }

---

## Caso de Uso 2: Cancelación de Descuento Predial

**Descripción:** El usuario cancela un descuento vigente.

**Precondiciones:**
El usuario tiene permisos de cancelación. Existe al menos un descuento vigente.

**Pasos a seguir:**
1. El usuario busca la cuenta por clave catastral.
2. Visualiza la lista de descuentos vigentes.
3. Presiona 'Cancelar' en el descuento deseado.
4. El sistema actualiza el status a 'C'.

**Resultado esperado:**
El descuento aparece como cancelado y no puede ser usado para nuevos pagos.

**Datos de prueba:**
{ "id": 123, "usuario": "admin" }

---

## Caso de Uso 3: Consulta de Adeudos y Descuentos

**Descripción:** El usuario consulta los adeudos y descuentos de una cuenta.

**Precondiciones:**
La cuenta existe.

**Pasos a seguir:**
1. El usuario ingresa la clave catastral.
2. El sistema muestra los adeudos y descuentos vigentes.

**Resultado esperado:**
Se visualizan los adeudos y descuentos actuales.

**Datos de prueba:**
{ "clave": "D65J1234567" }

---

## Casos de Prueba

# Casos de Prueba CatastroDM

## Caso 1: Alta de Descuento Predial
- **Entrada:** Clave catastral válida, datos de descuento completos
- **Acción:** Alta de descuento
- **Esperado:** Descuento insertado y visible en la lista

## Caso 2: Cancelación de Descuento Predial
- **Entrada:** ID de descuento vigente, usuario autorizado
- **Acción:** Cancelar descuento
- **Esperado:** Descuento marcado como cancelado

## Caso 3: Consulta de Adeudos y Descuentos
- **Entrada:** Clave catastral válida
- **Acción:** Consultar cuenta
- **Esperado:** Se muestran adeudos y descuentos

## Caso 4: Validación de Parámetros
- **Entrada:** Clave catastral vacía
- **Acción:** Buscar cuenta
- **Esperado:** Error de validación

## Caso 5: Permisos de Usuario
- **Entrada:** Usuario sin permisos de alta
- **Acción:** Intentar alta de descuento
- **Esperado:** Error de permisos

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

