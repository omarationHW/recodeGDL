# Documentación Técnica: Migración Formulario Bja_Multiple (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA (Single Page Application), cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures/functions.

## 2. Flujo de Trabajo
1. **Carga de datos**: El usuario ingresa el nombre del archivo y llena una tabla tipo hoja de cálculo con los datos de folios a dar de baja.
2. **Grabar**: Al presionar "Grabar", se envía el archivo y los registros al backend, que ejecuta el SP de inserción por cada registro.
3. **Llenado y Aplicado**: Al presionar "Llenado y Aplicado", se ejecuta el SP de proceso que realiza la validación y aplicación de los registros.
4. **Vista**: Permite consultar e imprimir (mostrar) los registros con error de validación (estatus=9) para el archivo dado.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ eRequest: { action: ..., ...params } }`
- **Response**: `{ eResponse: { success, message, data } }`

### Acciones soportadas
- `insert_baja_multiple`: Inserta registros de baja múltiple.
- `aplicar_baja_multiple`: Ejecuta el proceso de llenado/aplicación.
- `get_incidencias_baja_multiple`: Consulta incidencias (errores de validación).

## 4. Stored Procedures
- **sp_insert_folios_baja_esta**: Inserta un registro en la tabla de bajas.
- **sp14_ejecuta_sp**: Realiza la aplicación/validación de los registros (actualiza estatus, etc).
- **sp_get_incidencias_baja_multiple**: Devuelve los registros con error de validación para un archivo.

## 5. Frontend (Vue.js)
- Página independiente, tabla editable tipo hoja de cálculo.
- Botones: Grabar, Llenado y Aplicado, Vista, Salir.
- Mensajes informativos y tabla de incidencias.
- Navegación: Cada formulario es una página, no hay tabs.

## 6. Backend (Laravel)
- Controlador único para `/api/execute`.
- Manejo de transacciones para inserción masiva.
- Llamadas a stored procedures PostgreSQL.

## 7. Seguridad
- Validación de datos en frontend y backend.
- Manejo de errores y rollback en transacciones.

## 8. Consideraciones
- El SP de llenado/aplicación debe ser ajustado según reglas de negocio reales.
- El frontend puede ser extendido para importar desde Excel/CSV si se requiere.

## 9. Estructura de la Tabla (Ejemplo)
```sql
CREATE TABLE ta14_folios_baja_esta (
    archivo VARCHAR(20),
    referencia INTEGER,
    folio_archivo INTEGER,
    fecha_archivo VARCHAR(10),
    placa VARCHAR(7),
    anomalia VARCHAR(30),
    tarifa VARCHAR(10),
    estatus INTEGER,
    fecha_captura DATE,
    usuario VARCHAR(50),
    observaciones TEXT
);
```

## 10. Extensibilidad
- Se pueden agregar más acciones al endpoint unificado siguiendo el patrón eRequest/eResponse.
- Los SP pueden ser versionados y ampliados según necesidades futuras.
