# Documentación Técnica: Migración de Formulario Descuentos de Multas Municipales (consdesctosmfrm)

## Descripción General
Este módulo permite la consulta, alta, modificación y cancelación de descuentos otorgados por Secretaría General sobre multas municipales. La migración se realizó desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y lógica de negocio en stored procedures).

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación y formulario completo.
- **Base de Datos**: PostgreSQL, lógica de negocio encapsulada en stored procedures.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ eRequest: { action: 'list|get|create|update|delete', params: { ... } } }`
- **Response**: `{ eResponse: { status, message, data } }`

## Acciones Soportadas
- `list`: Lista todos los descuentos para una multa (`id_multa` requerido)
- `get`: Obtiene un descuento específico (`folio_descto` requerido)
- `create`: Crea un nuevo descuento (campos requeridos: `id_multa`, `tipo_descto`, `valor`, `autoriza`, `user_cap`)
- `update`: Actualiza un descuento existente (campos requeridos: `folio_descto`, `tipo_descto`, `valor`, `autoriza`, `user_cap`)
- `delete`: Cancela (elimina lógicamente) un descuento (`folio_descto`, `user_cap` requeridos)

## Seguridad
- Validación de parámetros en backend.
- Solo usuarios autenticados y autorizados pueden crear, modificar o cancelar descuentos.
- Todas las operaciones quedan auditadas por usuario y fecha.

## Integración con Frontend
- El componente Vue.js consume el endpoint `/api/execute` para todas las operaciones.
- El formulario de alta/edición es modal y reutilizable.
- El listado se actualiza automáticamente tras cada operación.

## Lógica de Base de Datos
- Toda la lógica de negocio (alta, edición, cancelación, consulta) se realiza mediante stored procedures en PostgreSQL.
- No se permite borrado físico, solo cancelación lógica (`vigencia = 'C'`).

## Consideraciones de Migración
- Los tabs del formulario Delphi se migran a páginas independientes en Vue.js.
- El grid de descuentos se convierte en una tabla HTML con acciones CRUD.
- Los combos de autorización se resuelven por ID (pueden integrarse catálogos adicionales).

## Ejemplo de Request/Response
```json
POST /api/execute
{
  "eRequest": {
    "action": "create",
    "params": {
      "id_multa": 123,
      "tipo_descto": "P",
      "valor": 20,
      "autoriza": 5,
      "observacion": "Descuento por convenio",
      "user_cap": "jdoe"
    }
  }
}

Respuesta:
{
  "eResponse": {
    "status": "success",
    "message": "Descuento creado",
    "data": { ... }
  }
}
```

## Validaciones
- No se permite crear descuentos si la multa ya está pagada o cancelada.
- El porcentaje/monto no puede exceder el tope autorizado por el usuario que autoriza.
- Solo se permite un descuento vigente por multa.

## Errores Comunes
- `id_multa es requerido`
- `folio_descto es requerido`
- `No se encontró el descuento solicitado`
- `No tiene permisos para esta operación`

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser versionados y auditados.

# Diagrama de Flujo
1. Usuario ingresa ID de multa y consulta descuentos
2. Usuario puede agregar, editar o cancelar descuentos
3. Cada acción llama a `/api/execute` con la acción correspondiente
4. El backend ejecuta el stored procedure y retorna el resultado
5. El frontend actualiza la vista según la respuesta
