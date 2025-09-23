# Documentación Técnica: Migración de Formulario sFrm_trans_exclu a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la transferencia de datos desde archivos planos (exportados de HP3000) a la base de datos PostgreSQL, específicamente a la tabla `ta_18_exclusivo`. Además, permite actualizar fechas de vencimiento en la tabla `ta_15_publicos`.

La solución está compuesta por:
- **Backend Laravel**: Un controlador API unificado (`/api/execute`) que recibe acciones y parámetros en formato eRequest/eResponse.
- **Frontend Vue.js**: Un componente de página que permite cargar archivos, visualizar registros parseados, importar datos y actualizar fechas.
- **Stored Procedures PostgreSQL**: Encapsulan la lógica de inserción y actualización para mayor seguridad y mantenibilidad.

## 2. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato de entrada**:
  ```json
  {
    "eRequest": {
      "action": "nombre_accion",
      "payload": { ... }
    }
  }
  ```
- **Formato de salida**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": ...
    }
  }
  ```

### Acciones soportadas
- `import_exclusivo_file`: Recibe el contenido de un archivo plano, lo parsea y devuelve los registros.
- `insert_exclusivo_row`: Inserta un registro en `ta_18_exclusivo` usando SP.
- `update_publicos_fecha_venci`: Actualiza la fecha de vencimiento en `ta_15_publicos` usando SP.

## 3. Proceso de Importación
1. El usuario selecciona un archivo plano (`.txt` o `.dat`).
2. El frontend lee el archivo y lo envía al backend para parseo (`import_exclusivo_file`).
3. El backend parsea cada línea según el layout fijo y devuelve los registros.
4. El usuario revisa la vista previa y ejecuta la importación masiva (`insert_exclusivo_row` por cada registro).
5. El usuario puede actualizar fechas de vencimiento en `ta_15_publicos` mediante un formulario modal.

## 4. Layout del Archivo Plano
Cada línea representa un registro con los siguientes campos y posiciones:

| Campo         | Posición (inicio, longitud) |
|---------------|----------------------------|
| CVE_SECTOR    | 1, 1                       |
| CVE_ZONA      | 2, 1                       |
| CVE_METROS    | 3, 3                       |
| CVE_TIPO      | 6, 1                       |
| CVE_NUMERO    | 7, 4                       |
| NOMBRE        | 11, 30                     |
| TELEFONO      | 41, 7                      |
| CALLE         | 48, 30                     |
| NUM           | 78, 4                      |
| DOMFIS        | 82, 30                     |
| FECHA_ALTA    | 112, 6 (ddmmyy)            |
| FECHA_INIC    | 118, 6 (ddmmyy)            |
| FECHA_VENCI   | 124, 6 (ddmmyy)            |
| NUMOFT        | 130, 8                     |
| NUMOFM        | 138, 4                     |
| NUMCTAT       | 142, 4                     |
| ZOPPARQ       | 146, 2                     |
| MANZ          | 148, 2                     |
| ESTATUS       | 150, 1                     |
| CLAVE         | 151, 1                     |

## 5. Stored Procedures
- **sp_insert_ta_18_exclusivo**: Inserta un registro en la tabla de exclusivos.
- **sp_update_ta_15_publicos_fecha_venci**: Actualiza la fecha de vencimiento en la tabla de públicos.

## 6. Validaciones
- Todos los campos requeridos son validados en backend.
- Fechas en formato ddmmyy se convierten a yyyy-mm-dd.
- El proceso de importación es transaccional por registro.

## 7. Seguridad
- Solo se expone el endpoint `/api/execute`.
- Los procedimientos almacenados encapsulan la lógica de negocio.
- Validación de datos en backend.

## 8. Frontend
- Página Vue.js independiente, sin tabs.
- Permite cargar archivo, ver vista previa, importar y actualizar fechas.
- Mensajes de éxito/error claros.

## 9. Navegación
- Breadcrumb para navegación contextual.

## 10. Pruebas
- Casos de uso y escenarios de prueba incluidos para QA.
