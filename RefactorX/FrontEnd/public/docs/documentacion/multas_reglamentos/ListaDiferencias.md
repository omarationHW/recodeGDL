# Documentación: ListaDiferencias

## Análisis Técnico

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

## Casos de Uso

# Casos de Uso - ListaDiferencias

**Categoría:** Form

## Caso de Uso 1: Consulta de diferencias por rango de fechas y todas las vigencias

**Descripción:** El usuario desea obtener el listado completo de diferencias de transmisiones patrimoniales para un rango de fechas determinado, sin filtrar por vigencia.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la base de datos para el rango de fechas seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página 'Listado de Diferencias'.
2. Selecciona 'Fecha Desde' = '2024-06-01' y 'Fecha Hasta' = '2024-06-30'.
3. Deja el filtro 'Vigencia' en 'Todas'.
4. Pulsa el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los registros de diferencias entre las fechas seleccionadas, sin filtrar por vigencia. Se muestra el total de registros y la suma total.

**Datos de prueba:**
fecha1: '2024-06-01', fecha2: '2024-06-30', vigencia: ''

---

## Caso de Uso 2: Consulta de diferencias solo vigentes

**Descripción:** El usuario desea ver únicamente las diferencias con vigencia 'Vigentes' en un rango de fechas.

**Precondiciones:**
El usuario tiene acceso y existen registros con vigencia 'V' en el rango de fechas.

**Pasos a seguir:**
1. Accede a la página 'Listado de Diferencias'.
2. Selecciona 'Fecha Desde' = '2024-06-01', 'Fecha Hasta' = '2024-06-30'.
3. Selecciona 'Vigencia' = 'Vigentes'.
4. Pulsa 'Buscar'.

**Resultado esperado:**
Se muestran solo los registros con vigencia 'V' (Vigentes) en la tabla.

**Datos de prueba:**
fecha1: '2024-06-01', fecha2: '2024-06-30', vigencia: 'V'

---

## Caso de Uso 3: Exportación de diferencias a Excel

**Descripción:** El usuario desea exportar el listado de diferencias filtrado a un archivo Excel.

**Precondiciones:**
El usuario ha realizado una búsqueda y existen resultados.

**Pasos a seguir:**
1. Realiza una búsqueda con cualquier filtro.
2. Pulsa el botón 'Exportar Excel'.

**Resultado esperado:**
El sistema genera y descarga un archivo Excel con los resultados filtrados.

**Datos de prueba:**
fecha1: '2024-06-01', fecha2: '2024-06-30', vigencia: 'P'

---

## Casos de Prueba

## Casos de Prueba para Listado de Diferencias

### Caso 1: Consulta básica sin filtro de vigencia
- **Entrada:** fecha1 = '2024-06-01', fecha2 = '2024-06-30', vigencia = ''
- **Acción:** Buscar
- **Esperado:** Se muestran todos los registros entre las fechas, sin filtrar por vigencia. El total de registros y suma total son correctos.

### Caso 2: Consulta solo vigentes
- **Entrada:** fecha1 = '2024-06-01', fecha2 = '2024-06-30', vigencia = 'V'
- **Acción:** Buscar
- **Esperado:** Solo se muestran registros con vigencia = 'V'.

### Caso 3: Consulta sin resultados
- **Entrada:** fecha1 = '1990-01-01', fecha2 = '1990-01-31', vigencia = ''
- **Acción:** Buscar
- **Esperado:** Se muestra mensaje 'No se encontraron resultados.'

### Caso 4: Exportación a Excel
- **Entrada:** fecha1 = '2024-06-01', fecha2 = '2024-06-30', vigencia = 'P'
- **Acción:** Exportar Excel
- **Esperado:** Se genera archivo Excel con los datos filtrados.

### Caso 5: Error de parámetros
- **Entrada:** fecha1 = '', fecha2 = '', vigencia = ''
- **Acción:** Buscar
- **Esperado:** Se muestra mensaje de error de validación.

### Caso 6: Error de backend
- **Simulación:** El stored procedure lanza una excepción.
- **Esperado:** Se muestra mensaje de error técnico en el frontend.

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

