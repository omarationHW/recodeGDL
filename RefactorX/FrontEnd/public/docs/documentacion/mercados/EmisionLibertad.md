# EmisionLibertad

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - EmisionLibertad

**Categoría:** Form

## Caso de Uso 1: Generar Emisión para un Mercado con Caja de Cobro

**Descripción:** El usuario desea generar la emisión de recibos para el mercado 5 de la recaudadora 1 para el mes de junio de 2024.

**Precondiciones:**
El usuario está autenticado y tiene permisos para emitir recibos. Existen locales activos en el mercado 5.

**Pasos a seguir:**
- Acceder a la página de Emisión Libertad.
- Seleccionar año 2024 y periodo 6 (junio).
- Seleccionar recaudadora 1.
- Seleccionar mercado 5.
- Hacer clic en 'Generar Emisión'.

**Resultado esperado:**
Se muestra una tabla con el detalle de la emisión para todos los locales del mercado 5, incluyendo renta, adeudos, recargos, multas, gastos y folios de requerimientos.

**Datos de prueba:**
{ "oficina": 1, "mercados": [5], "axo": 2024, "periodo": 6, "usuario_id": 1 }

---

## Caso de Uso 2: Exportar Archivo TXT de Emisión

**Descripción:** El usuario desea exportar el archivo TXT de la emisión generada para los mercados 5 y 6 de la recaudadora 1.

**Precondiciones:**
La emisión ya fue generada y está disponible en pantalla.

**Pasos a seguir:**
- Hacer clic en 'Exportar TXT'.

**Resultado esperado:**
Se descarga un archivo TXT con el layout especificado, listo para ser entregado a caja.

**Datos de prueba:**
{ "oficina": 1, "mercados": [5,6], "axo": 2024, "periodo": 6, "usuario_id": 1 }

---

## Caso de Uso 3: Visualizar Detalle de Emisión para Varios Mercados

**Descripción:** El usuario desea ver el detalle de emisión para los mercados 5 y 6 de la recaudadora 1.

**Precondiciones:**
El usuario está autenticado y tiene acceso a los mercados seleccionados.

**Pasos a seguir:**
- Seleccionar año 2024 y periodo 6.
- Seleccionar recaudadora 1.
- Seleccionar mercados 5 y 6.
- Hacer clic en 'Generar Emisión'.

**Resultado esperado:**
Se muestra la tabla con el detalle de todos los locales de los mercados seleccionados.

**Datos de prueba:**
{ "oficina": 1, "mercados": [5,6], "axo": 2024, "periodo": 6, "usuario_id": 1 }

---



## Casos de Prueba

## Casos de Prueba para Emisión Libertad

### Caso 1: Generar emisión para un mercado válido
- **Entrada:** oficina=1, mercados=[5], axo=2024, periodo=6, usuario_id=1
- **Acción:** POST /api/execute { action: 'generarEmisionLibertad', params: {...} }
- **Resultado esperado:** status 200, success=true, data contiene array de locales con campos requeridos.

### Caso 2: Exportar archivo TXT de emisión
- **Entrada:** oficina=1, mercados=[5,6], axo=2024, periodo=6, usuario_id=1
- **Acción:** POST /api/execute { action: 'exportarEmisionLibertad', params: {...} }
- **Resultado esperado:** status 200, success=true, data.file_url contiene URL válida para descarga.

### Caso 3: Error por parámetros faltantes
- **Entrada:** oficina=1, mercados=[], axo=2024, periodo=6, usuario_id=1
- **Acción:** POST /api/execute { action: 'generarEmisionLibertad', params: {...} }
- **Resultado esperado:** status 200, success=false, message indica error de parámetros.

### Caso 4: Error por recaudadora inexistente
- **Entrada:** oficina=999, mercados=[5], axo=2024, periodo=6, usuario_id=1
- **Acción:** POST /api/execute { action: 'generarEmisionLibertad', params: {...} }
- **Resultado esperado:** status 200, success=false, message indica recaudadora no encontrada.

### Caso 5: Visualización de detalle
- **Entrada:** oficina=1, mercados=[5,6], axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getEmisionLibertadDetalle', params: {...} }
- **Resultado esperado:** status 200, success=true, data contiene detalle de emisión.



