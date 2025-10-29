# Documentación Técnica: Migración PasoConvDiversos Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la migración y actualización masiva de convenios diversos desde archivos planos (txt/csv) a la base de datos PostgreSQL, replicando la lógica del formulario PasoConvDiversos de Delphi. El proceso incluye:
- Carga y parseo de archivos planos (delimitados por pipe o similar)
- Visualización previa de los datos
- Procesamiento masivo: inserción/actualización en las tablas `ta_17_con_reg_pred` y `ta_17_conv_d_resto`
- Uso de stored procedures para lógica de negocio
- API unificada con patrón eRequest/eResponse
- Frontend Vue.js como página independiente

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js de página completa, sin tabs.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **Comunicación:** JSON, patrón eRequest/eResponse.

## 3. Flujo de Trabajo
1. **Carga de Archivo:** El usuario selecciona un archivo plano y lo carga en el frontend.
2. **Parseo:** El frontend parsea el archivo y muestra una tabla previa.
3. **Procesamiento:** Al confirmar, el frontend envía todas las filas al backend vía `/api/execute` con acción `process_rows`.
4. **Backend:**
   - Por cada fila:
     - Busca en `ta_17_con_reg_pred` (padron). Si no existe, inserta (SP).
     - Busca en `ta_17_conv_d_resto`. Si no existe, inserta (SP); si existe, actualiza (SP).
   - Todo el proceso es transaccional.
5. **Respuesta:** El backend retorna éxito o errores detallados.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "process_rows",
    "payload": {
      "rows": [ ... ],
      "user_id": 1
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "message": "Convenios procesados correctamente",
    "data": null
  }
  ```

## 5. Stored Procedures
Toda la lógica de inserción/actualización está en SPs PostgreSQL:
- `sp_insert_con_reg_pred`: Inserta en padron y retorna id
- `sp_insert_conv_d_resto`: Inserta en detalle
- `sp_update_conv_d_resto`: Actualiza detalle

## 6. Frontend (Vue.js)
- Página independiente
- Carga de archivo y parseo local
- Vista previa de datos
- Botón para procesar (llama API)
- Mensajes de éxito/error

## 7. Seguridad
- El endpoint requiere autenticación (no detallada aquí)
- El user_id se pasa en el payload y se valida en backend
- Todas las operaciones son transaccionales

## 8. Validaciones
- El backend valida existencia de padron antes de insertar
- Si ya existe detalle, actualiza; si no, inserta
- Errores se reportan por fila

## 9. Extensibilidad
- El endpoint puede extenderse para otras acciones (`import_file`, `get_padron`, etc.)
- Los SPs pueden ampliarse para lógica adicional

## 10. Pruebas y Casos de Uso
Ver secciones de casos de uso y pruebas abajo.
