# Documentación Técnica: Descuentos por Pronto Pago (Dscto_p_pago)

## Descripción General
Este módulo permite la administración de los descuentos por pronto pago aplicables a contratos, permitiendo:
- Alta de periodos de descuento (% y fechas)
- Consulta de todos los periodos
- Cancelación lógica de periodos (baja lógica)

## Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (tabla `ta_16_dscto_pp` y stored procedures)
- **API Pattern:** eRequest/eResponse

## API
### Endpoint
`POST /api/execute`

#### Request
```json
{
  "eRequest": {
    "action": "list|create|delete",
    "data": { ... }
  }
}
```

#### Actions
- `list`: Devuelve todos los descuentos activos y cancelados
- `create`: Crea un nuevo descuento (requiere: fecha_inicio, fecha_fin, porc_dscto, usuario_mov)
- `delete`: Cancela un descuento (requiere: id, usuario_mov)

#### Response
```json
{
  "eResponse": {
    "success": true|false,
    "message": "...",
    "data": [ ... ]
  }
}
```

## Stored Procedures
- `sp_dscto_pp_create(fecha_inicio, fecha_fin, porc_dscto, usuario_mov)`
- `sp_dscto_pp_delete(id, usuario_mov)`

## Validaciones
- No se permite crear descuentos con fechas o porcentaje inválidos
- Solo se puede cancelar descuentos con status 'V'

## Seguridad
- El usuario debe estar autenticado y autorizado para crear/cancelar descuentos (no implementado en este ejemplo, pero debe integrarse con Auth en producción)

## Frontend
- Página Vue.js independiente
- Formulario para alta
- Tabla para consulta y baja lógica
- Mensajes de éxito/error

## Integración
- El componente Vue.js consume el endpoint `/api/execute` usando el patrón eRequest/eResponse
- El backend ejecuta los stored procedures según la acción

## Tabla de Base de Datos
```sql
CREATE TABLE ta_16_dscto_pp (
    id SERIAL PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    porc_dscto NUMERIC NOT NULL,
    status CHAR(1) NOT NULL DEFAULT 'V',
    fecha_at DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_in DATE NOT NULL DEFAULT CURRENT_DATE,
    usuario_mov VARCHAR(50) NOT NULL
);
```
