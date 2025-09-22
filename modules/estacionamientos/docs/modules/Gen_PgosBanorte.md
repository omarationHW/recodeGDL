# Documentación Técnica: Migración Formulario Gen_PgosBanorte (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la generación de remesas de pagos Banorte, consultando periodos, ejecutando procesos de generación y exportando archivos de texto con los registros correspondientes. La migración se realizó desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend) y PostgreSQL (DB).

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3+, componente de página independiente
- **Base de Datos:** PostgreSQL, stored procedure `sp14_remesa`
- **Almacenamiento de archivos:** Laravel Storage (local), endpoint de descarga `/api/remesas/download/{filename}`

## 3. Flujo de Operación
1. **Consulta de Periodo:**
   - El frontend solicita el último periodo de pagos Banorte (`get_periodo`).
   - El backend consulta la tabla `ta14_bitacora` y retorna las fechas.
2. **Ejecución de Remesa:**
   - El usuario selecciona el nuevo periodo y ejecuta la remesa (`ejecutar_remesa`).
   - El backend llama el SP `sp14_remesa`, actualiza registros y retorna el identificador de remesa y cantidad de registros.
3. **Generación de Archivo:**
   - El usuario genera el archivo de texto (`generar_archivo`).
   - El backend consulta los registros de la remesa y genera un archivo `.txt` en storage.
   - El frontend muestra el enlace de descarga.

## 4. API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "get_periodo|ejecutar_remesa|generar_archivo|descargar_archivo",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 5. Stored Procedure: sp14_remesa
- **Propósito:** Generar una nueva remesa y actualizar registros de pagos Banorte.
- **Parámetros:**
  - `p_opc`: Opción (2 = carga de banorte)
  - `p_axo`: Año
  - `p_fec_ini`: Fecha inicio
  - `p_fec_fin`: Fecha fin
  - `p_fec_a_fin`: Fecha actual fin
- **Retorno:** status, obs, remesa
- **Lógica:** Actualiza registros en `ta14_datos_mpio` con el nuevo identificador de remesa.

## 6. Frontend (Vue.js)
- Página independiente `/gen-pgos-banorte`
- Permite seleccionar fechas, ejecutar remesa y descargar archivo
- Muestra mensajes de éxito/error y estado de la operación

## 7. Seguridad
- Acceso autenticado (middleware Laravel)
- Validación de parámetros en backend
- Descarga de archivos sólo existentes

## 8. Almacenamiento de Archivos
- Los archivos de remesa se almacenan en `storage/app/remesas/`
- Se provee endpoint de descarga seguro

## 9. Consideraciones
- El SP debe ser adaptado según la lógica de negocio real (aquí se simula la actualización de remesa)
- El frontend asume que el backend retorna los datos en el formato especificado

## 10. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras operaciones de formularios similares
