# Documentación Técnica: Emisión Libertad (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite la emisión de recibos para mercados que cuentan con caja de cobro (tipo_emision = 'D'). Permite seleccionar recaudadora, mercados, año y periodo, y genera tanto la vista previa como el archivo TXT de emisión, siguiendo la lógica original Delphi.

## 2. Arquitectura
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Comunicación:** eRequest/eResponse (JSON)

## 3. Flujo de Trabajo
1. El usuario accede a la página de Emisión Libertad.
2. Selecciona año, periodo, recaudadora y uno o más mercados.
3. Al hacer clic en "Generar Emisión":
   - Se llama a `/api/execute` con acción `generarEmisionLibertad`.
   - El backend ejecuta el SP `generar_emision_libertad`, que calcula todos los datos requeridos.
   - El frontend muestra el detalle en una tabla.
4. Al hacer clic en "Exportar TXT":
   - Se llama a `/api/execute` con acción `exportarEmisionLibertad`.
   - El backend ejecuta el SP `exportar_emision_libertad`, que genera el archivo y devuelve la URL de descarga.

## 4. API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "generarEmisionLibertad",
    "params": {
      "oficina": 1,
      "mercados": [5,6],
      "axo": 2024,
      "periodo": 6,
      "usuario_id": 1
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ...detalle... ],
    "message": ""
  }
  ```

## 5. Stored Procedures
- Toda la lógica de negocio y cálculo reside en SPs de PostgreSQL.
- Los SPs reciben parámetros y devuelven tablas (TABLE RETURNS) para fácil consumo desde Laravel.
- El SP de exportación genera el archivo TXT en el servidor y retorna la URL relativa.

## 6. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite seleccionar recaudadora, mercados, año y periodo.
- Muestra tabla de resultados y botón para exportar.
- Usa Axios para consumir el endpoint `/api/execute`.

## 7. Seguridad
- El endpoint requiere autenticación (no incluida aquí, pero debe integrarse con middleware Laravel Auth).
- Validación de parámetros en backend y frontend.

## 8. Ubicación de archivos exportados
- Los archivos TXT se guardan en `/var/www/html/exports/` y se exponen vía `/exports/` en el servidor web.

## 9. Consideraciones
- El SP de exportación debe tener permisos para escribir archivos en el servidor.
- El formato del archivo TXT sigue el layout original Delphi.
- El frontend asume que el usuario está autenticado y su ID está disponible.

# 10. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los SPs pueden ser versionados y auditados en la base de datos.

# 11. Errores y manejo de excepciones
- Todos los errores se devuelven en el campo `message` del JSON de respuesta.
- El frontend muestra los errores en pantalla.
