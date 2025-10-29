# Documentación Técnica: Migración Formulario ListaDiferencias Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario "ListaDiferencias" como una página web independiente, usando Laravel (backend/API), Vue.js (frontend), y PostgreSQL (base de datos). Toda la lógica de consulta y filtrado se realiza mediante stored procedures en PostgreSQL. La comunicación entre frontend y backend se realiza a través de un endpoint API unificado `/api/execute` usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Frontend:** Vue.js SPA (Single Page Application), página independiente `/lista-diferencias`.
- **Backend:** Laravel, controlador único `ExecuteController` con endpoint `/api/execute`.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedure `sp_lista_diferencias`.
- **API:** Unificada, recibe un objeto `eRequest` y responde con `eResponse`.

## 3. Flujo de Datos
1. El usuario accede a la página de Listado de Diferencias.
2. El usuario selecciona fechas y vigencia, y pulsa "Buscar".
3. El frontend envía un POST a `/api/execute` con `eRequest.action = getListaDiferencias` y los parámetros.
4. El backend ejecuta el stored procedure `sp_lista_diferencias` con los parámetros recibidos.
5. El resultado se devuelve en `eResponse.data`.
6. El frontend muestra la tabla de resultados y totales.
7. Para exportar a Excel, se usa la acción `exportListaDiferenciasExcel` (simulada en este ejemplo).

## 4. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "getListaDiferencias",
      "params": {
        "fecha1": "2024-06-01",
        "fecha2": "2024-06-30",
        "vigencia": "V"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "error": null
    }
  }
  ```

## 5. Stored Procedure
- **Nombre:** `sp_lista_diferencias`
- **Parámetros:**
  - `fecha1` (DATE): Fecha inicial
  - `fecha2` (DATE): Fecha final
  - `vigencia` (VARCHAR, opcional): Filtro de vigencia ('V', 'P', 'C', o NULL para todas)
- **Retorna:** Tabla con todos los campos requeridos para el listado.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse con autenticación (ej: JWT, sesión Laravel, etc.) según la política de la aplicación.
- Validar y sanear todos los parámetros recibidos.

## 7. Consideraciones de Exportación
- La exportación a Excel debe implementarse en backend (Laravel) o frontend (Vue.js) según la política de la organización. En este ejemplo, se simula la exportación devolviendo los datos en crudo.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones y stored procedures sin modificar el endpoint.
- El frontend puede adaptarse fácilmente a nuevos filtros o columnas.

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba.

# Fin de Documentación
