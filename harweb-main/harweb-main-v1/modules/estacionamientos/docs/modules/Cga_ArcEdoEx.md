# Documentación Técnica: Migración Formulario Cga_ArcEdoEx (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la carga de archivos de pagos de SECFIN a municipios, procesando archivos de texto plano y almacenando los registros en la base de datos, aplicando la remesa y registrando la operación en bitácora. La migración moderniza el proceso usando Laravel (API), Vue.js (frontend) y PostgreSQL (backend).

## 2. Arquitectura
- **Frontend**: Vue.js SPA, página independiente para el formulario.
- **Backend**: Laravel API con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 3. Flujo de Trabajo
1. El usuario selecciona y carga un archivo `.txt`.
2. El frontend parsea el archivo y muestra una vista previa.
3. Al presionar "GRABAR", cada registro se inserta en la tabla `ta14_datos_edo` mediante el SP `sp_insert_ta14_datos_edo`.
4. Al presionar "APLICAR", se ejecuta el SP `sp_afec_esta01` para marcar la remesa como aplicada y luego se inserta un registro en `ta14_bitacora` con `sp_insert_ta14_bitacora`.
5. El usuario recibe mensajes de éxito o error en cada paso.

## 4. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ eRequest: { action: string, params: object } }`
- **Response**: `{ eResponse: { success: boolean, data: any, message: string } }`
- **Acciones soportadas**:
  - `getLastRemesa`: Último número de remesa aplicada.
  - `getRemesas`: Fechas de la última remesa.
  - `getRemesaDate`: Fecha de remesa para un nombre dado.
  - `countRemesaRecords`: Número de registros de una remesa.
  - `insertRemesaRecord`: Inserta un registro de pago.
  - `applyRemesa`: Aplica la remesa (afecta registros).
  - `insertBitacora`: Inserta registro en bitácora.

## 5. Stored Procedures
- **sp_insert_ta14_datos_edo**: Inserta un registro de pago.
- **sp_afec_esta01**: Aplica la remesa (actualiza registros).
- **sp_insert_ta14_bitacora**: Inserta registro en bitácora.

## 6. Seguridad
- Validación de parámetros en backend.
- Manejo de errores y transacciones en SPs.
- El endpoint debe estar protegido por autenticación (ej. JWT) en producción.

## 7. Consideraciones
- El frontend asume que el archivo `.txt` tiene campos separados por `|` y en el orden esperado.
- Los valores fijos (`mpio=113`, `tipoact='PN'`) se mantienen según la lógica original.
- El proceso es atómico por registro; si un registro falla, se reporta individualmente.

## 8. Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los SPs pueden evolucionar para lógica adicional (validaciones, auditoría, etc).

## 9. Dependencias
- Laravel 9+
- Vue.js 2/3
- PostgreSQL 12+
- Axios (frontend)

## 10. Estructura de Tablas (referencial)
- **ta14_datos_edo**: Registros de pagos.
- **ta14_bitacora**: Bitácora de cargas/aplicaciones de remesas.

## 11. Manejo de Errores
- Los SPs retornan `success=false` y mensaje de error en caso de excepción.
- El frontend muestra los errores en pantalla.

## 12. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
