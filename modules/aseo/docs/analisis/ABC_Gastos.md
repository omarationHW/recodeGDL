# Documentación Técnica: Catálogo de Gastos (ABC_Gastos)

## Descripción General
Este módulo permite la administración del catálogo de gastos (tabla `ta_16_gastos`) que contiene los parámetros globales de gastos para requerimiento, embargo y secuestro, así como el salario diario de la zona metropolitana de Guadalajara. Solo debe existir un registro vigente.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL con stored procedures para inserción y borrado.
- **API:** Todas las operaciones (listar, crear, actualizar, eliminar) se realizan mediante el endpoint `/api/execute`.

## Endpoints y Acciones
- **gastos.list**: Obtiene el registro actual de gastos.
- **gastos.create**: Crea un nuevo registro (elimina el anterior si existe).
- **gastos.update**: Actualiza el registro (elimina el anterior y crea uno nuevo).
- **gastos.delete**: Elimina todos los registros de gastos.

## Validaciones
- Todos los campos son obligatorios y deben ser numéricos mayores a cero.
- Solo puede existir un registro en la tabla.

## Stored Procedures
- `sp_gastos_insert`: Inserta un registro.
- `sp_gastos_delete_all`: Elimina todos los registros.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Validar que solo usuarios autorizados puedan modificar el catálogo.

## Integración Vue.js
- El componente Vue.js es una página completa, no usa tabs ni subcomponentes.
- Permite ver, crear, actualizar y eliminar el registro de gastos.
- Muestra mensajes de éxito/error y el registro actual.

## Flujo de Datos
1. El frontend solicita el registro actual (`gastos.list`).
2. El usuario puede crear/actualizar/eliminar el registro.
3. Cada acción se envía como un objeto `{ action: 'gastos.create', payload: { ... } }` al endpoint `/api/execute`.
4. El backend ejecuta el stored procedure correspondiente y responde con eResponse.

## Ejemplo de Request
```json
{
  "action": "gastos.create",
  "payload": {
    "sdzmg": 250.00,
    "porc1_req": 10.0,
    "porc2_embargo": 20.0,
    "porc3_secuestro": 30.0
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": null,
  "message": "Gastos creados correctamente"
}
```

## Notas
- El catálogo de gastos es global y afecta a todo el sistema.
- No se permite tener más de un registro.
- El borrado elimina todos los registros.
