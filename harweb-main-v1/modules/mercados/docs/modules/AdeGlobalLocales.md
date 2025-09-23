# Documentación Técnica: Adeudo Global con Accesorios

## Descripción General
Este módulo permite consultar y exportar el listado de locales con adeudo global y accesorios (multas y gastos) y también los locales sin adeudo pero con accesorios, filtrando por oficina, mercado, año y mes. Incluye integración con Vue.js como página independiente, backend Laravel con API unificada y lógica SQL encapsulada en stored procedures PostgreSQL.

## Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## Flujo de Datos
1. El usuario selecciona oficina, mercado, año y mes en la página Vue.
2. Vue llama a `/api/execute` con acción y parámetros.
3. Laravel Controller enruta la acción y llama al stored procedure correspondiente.
4. El resultado se retorna a Vue y se muestra en tablas.
5. Exportación a Excel se realiza en frontend o backend según implementación.

## Endpoints API
- **POST /api/execute**
  - **action:** Nombre de la acción (ej: `getAdeGlobalLocales`)
  - **params:** Parámetros requeridos por la acción

### Ejemplo de Request
```json
{
  "action": "getAdeGlobalLocales",
  "params": {
    "office_id": 1,
    "market_id": 14,
    "year": 2024,
    "month": 6
  }
}
```

### Ejemplo de Response
```json
{
  "success": true,
  "data": [
    { "id_local": 123, "oficina": 1, ... }
  ],
  "message": ""
}
```

## Stored Procedures
- **sp_get_ade_global_locales:** Devuelve locales con adeudo y accesorios.
- **sp_get_locales_sin_adeudo_con_accesorios:** Devuelve locales sin adeudo pero con accesorios.

## Seguridad
- Validar que los parámetros sean correctos y el usuario tenga permisos.
- Sanitizar entradas en el backend.

## Consideraciones
- El frontend debe manejar errores y mostrar mensajes claros.
- El backend debe registrar errores en logs.
- La exportación a Excel puede implementarse en backend (generando archivo y retornando URL) o frontend (usando librerías JS).

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ser extendidos para nuevos reportes.
