# Documentación Técnica: PasoPagos (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
El módulo PasoPagos permite la carga masiva de pagos provenientes de archivos planos generados por sistemas AS/400, para contratos de Desarrollo Social y Convenios Generales. El proceso consiste en:
- Cargar y parsear archivos de texto plano.
- Visualizar los registros antes de grabar.
- Guardar los pagos en tablas temporales (o definitivas) en PostgreSQL.
- Validar y mostrar el estatus de la carga.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL con stored procedures para procesos clave.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "openContrato|saveContrato|openConvenio|saveConvenio|statusDS",
      "payload": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 4. Flujo de Trabajo
1. **Carga de Archivo:**
   - El usuario selecciona un archivo plano (txt) y lo sube.
   - El frontend lo convierte a base64 y lo envía a `/api/execute` con acción `openContrato` o `openConvenio`.
   - El backend parsea el archivo y devuelve los registros para revisión.
2. **Grabado de Pagos:**
   - El usuario revisa y confirma la carga.
   - El frontend envía los registros a `/api/execute` con acción `saveContrato` o `saveConvenio`.
   - El backend limpia la tabla temporal y graba los registros.
3. **Consulta de Estatus:**
   - El usuario puede consultar el estatus de la carga (pagos grabados, modificados, inconsistentes).

## 5. Stored Procedures
- `spd_17_b_p400cont`: Limpia la tabla temporal de pagos de contratos.
- `spd_17_a_p400_cont`: Devuelve el conteo de pagos grabados por usuario.

## 6. Seguridad
- Validación de archivos y datos en backend.
- Uso de transacciones para evitar cargas parciales.
- El endpoint requiere autenticación (a implementar según política del sistema).

## 7. Consideraciones
- El mapeo de usuarios desde string a id es configurable en el backend.
- El parseo de archivos debe ajustarse si el layout cambia.
- El frontend es una página independiente, sin tabs ni componentes tabulares.

## 8. Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden evolucionar para incluir lógica de validación o auditoría.

