# Documentación Técnica: Migración de Formulario autdescto (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 (SPA), componente de página independiente para autdescto.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse (action, params).

## 2. Endpoints y Flujo
- **POST /api/execute**
  - Entrada: `{ action: string, params: object }`
  - Salida: `{ status: string, data: any, message: string }`
  - Acciones soportadas:
    - `list`: Listar descuentos de una cuenta
    - `create`: Crear descuento
    - `update`: Actualizar descuento
    - `cancel`: Cancelar descuento
    - `reactivate`: Reactivar descuento
    - `catalogs`: Catálogos de tipos de descuento e instituciones

## 3. Seguridad
- Autenticación JWT/Sanctum (Laravel)
- Validación de permisos por usuario (en el controller)
- Validación de datos en backend y frontend

## 4. Stored Procedures
- Toda la lógica de negocio (validaciones, folios, duplicidad, etc.) está en SPs de PostgreSQL.
- Los SPs devuelven mensajes claros y status.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario de alta/edición de descuento.
- Tabla de descuentos con acciones (editar, cancelar, reactivar).
- Uso de breadcrumbs para navegación.
- Validación de campos obligatorios y reglas de negocio.
- Mensajes de éxito/error claros.

## 6. Backend (Laravel)
- Controlador único `AutDesctoController`.
- Métodos para cada acción, todos usan SPs.
- Validación de entrada con Laravel Validator.
- Manejo de errores y mensajes amigables.

## 7. Base de Datos
- Tabla principal: `descpred` (ver estructura migrada de Delphi)
- Catálogos: `c_descpred`, `c_instituciones`
- Folios: calculados por SP según recaudadora

## 8. Pruebas y Casos de Uso
- Casos de uso y pruebas incluidas para alta, edición, cancelación, reactivación y validaciones.

## 9. Consideraciones
- El endpoint `/api/execute` es genérico y puede ser extendido para otros formularios.
- El frontend puede ser adaptado fácilmente a otros módulos siguiendo el mismo patrón.
- Los SPs pueden ser versionados y auditados en la base de datos.

## 10. Ejemplo de eRequest/eResponse
```json
{
  "action": "create",
  "params": {
    "cvecuenta": 12345,
    "cvedescuento": 1,
    "bimini": 1,
    "bimfin": 6,
    "solicitante": "Juan Perez",
    "observaciones": "Descuento por adulto mayor",
    "institucion": 2,
    "identificacion": "INE 123456",
    "fecnac": "1950-01-01"
  }
}
```

## 11. Mensajes de Error
- Todos los errores de validación y negocio se devuelven en el campo `message` del eResponse.

## 12. Extensibilidad
- El patrón permite agregar más acciones y módulos sin romper la API ni el frontend.
