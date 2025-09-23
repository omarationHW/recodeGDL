# Documentación Técnica: Mantenimiento de Gastos (Mannto_Gastos)

## Descripción General
Este módulo permite la administración de los parámetros de gastos (Salario Diario ZMG, % Requerimiento, % Embargo, % Secuestro) que se utilizan en el cálculo de apremios y recargos en el sistema. Solo puede existir un registro vigente en la tabla `ta_16_gastos`.

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures

## API
### Endpoint
- **POST** `/api/execute`

#### Request
```json
{
  "action": "gastos.create|gastos.update|gastos.delete|gastos.list",
  "payload": {
    "sdzmg": 123.45,
    "porc1_req": 10.0,
    "porc2_embargo": 15.0,
    "porc3_secuestro": 20.0
  }
}
```

#### Response
```json
{
  "success": true,
  "message": "Gastos creados correctamente.",
  "data": [ ... ]
}
```

### Acciones
- `gastos.list`: Lista el registro actual de gastos
- `gastos.create`: Elimina todos los registros y crea uno nuevo
- `gastos.update`: Igual que create (por la lógica del sistema)
- `gastos.delete`: Elimina todos los registros

## Validaciones
- Ningún campo puede ser cero o vacío
- Solo puede existir un registro

## Stored Procedures
- `sp_gastos_insert`: Inserta un registro
- `sp_gastos_delete_all`: Borra todos los registros

## Seguridad
- Validar que el usuario tenga permisos de administración
- Validar que los valores sean numéricos y mayores a cero

## Frontend
- Página Vue.js independiente
- Formulario con validación en cliente y servidor
- Tabla de consulta de gastos actual
- Acciones: Crear, Editar, Eliminar
- Navegación breadcrumb

## Integración
- El componente Vue llama a `/api/execute` con la acción correspondiente
- El backend ejecuta el stored procedure adecuado
- El frontend refresca la tabla tras cada operación

## Errores
- Mensajes claros en caso de error de validación o de base de datos

## Pruebas
- Casos de uso y pruebas unitarias incluidas abajo
