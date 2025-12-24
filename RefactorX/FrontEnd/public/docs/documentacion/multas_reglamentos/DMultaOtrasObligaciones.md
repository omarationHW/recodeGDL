# Documentación: DMultaOtrasObligaciones

## Análisis Técnico

# Documentación Técnica: Descuentos de Multas para Otras Obligaciones

## Descripción General
Este módulo permite la consulta, alta y cancelación de descuentos de multas para Otras Obligaciones (t34_descmul) en el sistema. Incluye:
- Catálogo de obligaciones
- Consulta de permisos y funcionarios autorizados
- Consulta de encabezado y detalle de control
- Alta y cancelación de descuentos
- API unificada con patrón eRequest/eResponse
- Frontend Vue.js como página independiente

## Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js SPA (Single Page Application)
- **Base de Datos:** PostgreSQL (con stored procedures para lógica de negocio)

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `getObligacionesCatalog`
  - `getPermisoUsuario`
  - `getFuncionarios`
  - `buscarEncabezado`
  - `buscarDescuentos`
  - `altaDescuento`
  - `cancelarDescuento`

## Stored Procedures
- **cob34_gdatosg_02:** Obtiene encabezado de control
- **admin_adeudos_detalle_25odoo:** Obtiene detalle de adeudos
- **sp_alta_descuento_otras_obligaciones:** Alta de descuento
- **sp_cancelar_descuento_otras_obligaciones:** Cancelación de descuento

## Seguridad
- El endpoint requiere autenticación (JWT o sesión Laravel)
- El usuario se obtiene de `$request->user()`
- Validaciones de parámetros en cada acción

## Frontend (Vue.js)
- Página independiente (no tabs)
- Selección de obligación y control
- Consulta de encabezado y descuentos
- Alta y cancelación de descuentos
- Validación de campos y mensajes de error

## Flujo de Trabajo
1. El usuario selecciona una obligación y captura el control
2. Consulta el encabezado (valida existencia y estatus)
3. Si existe y está vigente, muestra descuentos actuales
4. Permite alta de nuevo descuento si no hay vigente
5. Permite cancelar descuento vigente

## Notas de Implementación
- Los stored procedures deben estar creados en la base de datos PostgreSQL
- El controlador Laravel debe estar registrado en `routes/api.php` con el endpoint `/api/execute`
- El frontend debe consumir el endpoint usando fetch/Axios

# Ejemplo de Request/Response
## Alta de Descuento
**Request:**
```json
{
  "action": "altaDescuento",
  "params": {
    "id_datos": 123,
    "axoi": 2024,
    "mesi": 1,
    "axof": 2024,
    "mesf": 6,
    "porc": 20,
    "autoriza": 5
  }
}
```
**Response:**
```json
{
  "result": [ { "success": true, "message": "Descuento registrado correctamente" } ]
}
```

# Errores Comunes
- Si no existe el control, retorna error
- Si ya existe descuento vigente para el periodo, retorna error
- Si el usuario no tiene permiso, retorna error

# Pruebas y Validación
- Probar con diferentes usuarios y permisos
- Probar alta/cancelación de descuentos
- Validar mensajes de error y éxito

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

