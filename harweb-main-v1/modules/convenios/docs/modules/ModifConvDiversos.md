# Documentación Técnica: ModifConvDiversos (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **Patrón API**: eRequest/eResponse (entrada: `{action, params}`; salida: `{status, data, message}`)

## 2. Endpoints y Flujo
- **/api/execute**: Recibe un eRequest con `action` y `params`. El controlador ejecuta el stored procedure correspondiente y retorna eResponse.
- **Autenticación**: JWT (Laravel Sanctum o Passport recomendado).
- **Permisos**: El backend valida permisos según usuario y acción (por ejemplo, bloquear/desbloquear requiere permisos especiales).

## 3. Stored Procedures
- Toda la lógica de negocio y validación de integridad se implementa en stored procedures PostgreSQL.
- Los SPs reciben parámetros y retornan tablas o VOID según el caso.
- Ejemplo: `sp_modificar_datos_generales_convenio_diversos` actualiza los campos generales del convenio.

## 4. Frontend (Vue.js)
- Cada formulario es una página Vue independiente (NO tabs).
- El componente consume `/api/execute` vía Axios.
- El usuario selecciona tipo/subtipo, busca el convenio, y puede modificar datos o ejecutar acciones (bloquear, dar de baja, etc).
- Mensajes de error y éxito se muestran en la interfaz.

## 5. Validaciones
- **Frontend**: Validaciones básicas de campos requeridos, formatos, etc.
- **Backend**: Validaciones de negocio y permisos en los SPs y el controlador.

## 6. Seguridad
- Todas las acciones requieren autenticación.
- El backend valida que el usuario tenga permisos para cada acción.
- Los SPs sólo permiten cambios si el convenio está vigente y no bloqueado, según reglas de negocio.

## 7. Ejemplo de eRequest/eResponse
### eRequest
```json
{
  "action": "modificarDatosGenerales",
  "params": {
    "id_conv_resto": 123,
    "id_rec": 1,
    ...
  }
}
```
### eResponse
```json
{
  "status": "success",
  "data": null,
  "message": "Datos generales modificados correctamente"
}
```

## 8. Manejo de Errores
- Los SPs retornan excepciones SQL si hay errores de integridad o permisos.
- El controlador Laravel captura excepciones y retorna un mensaje de error en eResponse.

## 9. Pruebas y Auditoría
- Todas las acciones relevantes quedan registradas con usuario y timestamp.
- Se recomienda implementar triggers de auditoría en las tablas críticas.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los formularios Vue pueden crecer de manera modular.

---
