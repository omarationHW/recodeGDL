# Documentación Técnica: Migración Formulario Adeudos_UpdExed (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario **Adeudos_UpdExed** permite buscar y modificar la cantidad de excedencias (exedencias) para un contrato, periodo y tipo de operación específicos. El proceso implica:
- Búsqueda de la excedencia vigente para un contrato, periodo y tipo de operación.
- Actualización de la cantidad y el importe asociado.

La migración implementa:
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: Stored Procedures en PostgreSQL para lógica de negocio.

## 2. API (Laravel Controller)
- **Ruta**: `/api/execute` (POST)
- **Entrada**: `{ "eRequest": { "action": "search|update|reset|catalogs", ...params } }`
- **Salida**: `{ "eResponse": { "success": bool, "message": string, "data": ... } }`

### Acciones soportadas:
- `catalogs`: Devuelve catálogos de tipos de aseo, tipos de operación y meses.
- `search`: Busca la excedencia vigente para los parámetros dados.
- `update`: Actualiza la cantidad y el importe de la excedencia encontrada.
- `reset`: Reinicia el formulario (sin efecto en backend).

## 3. Stored Procedures PostgreSQL
- **sp_adeudos_updexed_search**: Busca la excedencia vigente.
- **sp_adeudos_updexed_update**: Actualiza la cantidad e importe.
- **sp_adeudos_updexed_catalogs**: (No es un SP, pero se usan queries directas para catálogos).

## 4. Vue.js Frontend
- Página independiente, sin tabs.
- Formulario de búsqueda y, si existe, formulario de actualización.
- Validaciones de campos.
- Mensajes de error y éxito.

## 5. Seguridad
- El usuario debe ser autenticado (en ejemplo, el id_usuario se pasa como parámetro; en producción debe obtenerse del token/session).
- Todas las operaciones de actualización usan transacciones.

## 6. Validaciones
- Todos los campos requeridos deben estar presentes y ser válidos.
- No se permite actualizar si no existe la excedencia vigente.

## 7. Flujo de Uso
1. El usuario ingresa los datos de búsqueda y ejecuta la búsqueda.
2. Si existe la excedencia, se muestra el formulario de actualización.
3. El usuario ingresa la nueva cantidad y opcionalmente el oficio, y ejecuta la actualización.
4. El sistema responde con éxito o error.

## 8. Errores Comunes
- Contrato no existe: mensaje de error.
- Excedencia no vigente: mensaje de error.
- Error de base de datos: mensaje de error detallado.

## 9. Pruebas
- Pruebas unitarias y de integración deben cubrir todos los caminos (búsqueda exitosa, fallida, actualización exitosa, fallida, etc).

## 10. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otros formularios siguiendo el mismo patrón.

---
