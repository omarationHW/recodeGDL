# Documentación Técnica: Migración de sfrm_trans_pub (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la transferencia de datos de estacionamientos públicos desde archivos de texto plano (formato fijo) generados por sistemas HP3000 hacia una base de datos PostgreSQL, utilizando una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y procedimientos almacenados en PostgreSQL.

## 2. Arquitectura
- **Frontend**: Componente Vue.js independiente, página completa, permite cargar archivo, visualizar datos parseados, insertar registros y actualizar fechas.
- **Backend**: Un único endpoint API `/api/execute` que recibe un `eRequest` y un `payload`, y ejecuta la lógica correspondiente.
- **Base de Datos**: Toda la lógica de inserción y actualización se realiza mediante procedimientos almacenados (stored procedures) en PostgreSQL.

## 3. Flujo de Trabajo
1. **Carga de Archivo**: El usuario selecciona y carga un archivo de texto plano.
2. **Parseo**: El archivo se parsea en el frontend (y puede validarse en backend), extrayendo los campos de cada línea según posiciones fijas.
3. **Visualización**: Se muestra una tabla previa con los datos parseados.
4. **Inserción**: El usuario puede enviar todos los registros parseados para ser insertados en la base de datos mediante el stored procedure `sp_ta_15_publicos_insert`.
5. **Actualización de Fechas**: El usuario puede actualizar el campo `pol_fec_ven` de los registros existentes mediante el stored procedure `sp_ta_15_publicos_update_pol_fec_ven`.

## 4. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "eRequest": "sfrm_trans_pub.insert_records", // o 'sfrm_trans_pub.update_pol_fec_ven', etc.
    "payload": { ... } // datos específicos según la operación
  }
  ```
- **Respuesta**:
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "...",
      "data": ...
    }
  }
  ```

## 5. Stored Procedures
- **sp_ta_15_publicos_insert**: Inserta un registro completo en la tabla `ta_15_publicos`.
- **sp_ta_15_publicos_update_pol_fec_ven**: Actualiza el campo `pol_fec_ven` para un registro específico.

## 6. Validaciones y Manejo de Errores
- El parseo de fechas convierte '00/00/00' en NULL.
- Los campos numéricos vacíos se insertan como NULL.
- Los errores en la inserción/actualización se manejan devolviendo `success: false` y el mensaje de error.

## 7. Seguridad
- El endpoint `/api/execute` puede protegerse con autenticación Laravel (middleware `auth:api` si es necesario).
- El campo `control` puede asociarse al usuario autenticado.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin crear nuevos endpoints.
- Los procedimientos almacenados pueden evolucionar sin cambiar la API.

## 9. Consideraciones de Rendimiento
- Para grandes volúmenes, se recomienda procesar los archivos en lotes.
- El frontend muestra solo una vista previa (primeras 20 filas) para evitar sobrecarga.

## 10. Migración de Datos
- El formato de archivo debe respetar las posiciones fijas especificadas en el código Delphi.
- Los campos se extraen por substrings, no por delimitadores.

---
