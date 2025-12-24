# Documentación Técnica: Cons_Zonas

## Análisis

# Documentación Técnica: Consulta de Zonas (Cons_Zonas)

## Descripción General
Este módulo permite consultar el catálogo de zonas del sistema, mostrando los campos: Control, Zona, Sub-Zona y Descripción. Permite ordenar por cualquiera de estos campos y exportar el resultado a Excel (CSV). La consulta se realiza a través de un endpoint API unificado y un stored procedure en PostgreSQL.

## Arquitectura
- **Backend:** Laravel Controller (ConsZonasController) expone un endpoint unificado `/api/execute` que recibe un objeto `eRequest` con la operación y parámetros.
- **Frontend:** Componente Vue.js de página completa, con navegación breadcrumb, tabla de resultados, selección de orden y exportación a Excel.
- **Base de Datos:** PostgreSQL, con stored procedure `sp_cons_zonas_list` para obtener los datos ordenados dinámicamente.

## API
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "cons_zonas_list",
      "params": { "order": "ctrol_zona" }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        { "ctrol_zona": 1, "zona": 1, "sub_zona": 1, "descripcion": "Centro" },
        ...
      ],
      "message": ""
    }
  }
  ```

## Stored Procedure
- **Nombre:** `sp_cons_zonas_list`
- **Parámetro:** `p_order` (campo por el que se ordena, default `ctrol_zona`)
- **Retorna:** Tabla con los campos principales de la tabla `ta_16_zonas`.
- **Seguridad:** El campo de orden es validado con `quote_ident` para evitar SQL injection.

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Breadcrumb de navegación.
- Tabla con los campos principales.
- Botones para exportar a Excel (CSV) y salir.
- Selección de orden por radio buttons.
- Lógica de exportación a CSV implementada en frontend.

## Backend (Laravel)
- Controlador único, método `execute`.
- Recibe operación y parámetros.
- Llama al stored procedure con el campo de orden.
- Devuelve datos en formato eResponse.
- Manejo de errores y logging.

## Seguridad
- El stored procedure utiliza `quote_ident` para evitar inyección SQL en el campo de orden.
- El endpoint requiere autenticación (no mostrado aquí, pero se recomienda usar middleware auth).

## Extensibilidad
- El endpoint y el patrón eRequest/eResponse permiten agregar más operaciones fácilmente.
- El frontend puede ser extendido para agregar filtros adicionales.

## Exportación a Excel
- El backend retorna los datos en JSON.
- El frontend convierte el JSON a CSV y lo descarga como archivo Excel-compatible.

## Pruebas
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.


## Casos de Uso

# Casos de Uso - Cons_Zonas

**Categoría:** Form

## Caso de Uso 1: Consulta básica de zonas ordenadas por Control

**Descripción:** El usuario accede a la página de Consulta de Zonas y visualiza la lista ordenada por el campo Control.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página 'Consulta de Zonas'.
2. El sistema muestra la tabla de zonas ordenada por 'Control'.
3. El usuario visualiza los datos correctamente.

**Resultado esperado:**
La tabla muestra todas las zonas ordenadas por el campo 'Control'.

**Datos de prueba:**
Tabla ta_16_zonas con al menos 3 registros diferentes.

---

## Caso de Uso 2: Cambio de orden a 'Descripción'

**Descripción:** El usuario selecciona la opción de ordenar por 'Descripción' y la tabla se actualiza.

**Precondiciones:**
El usuario está en la página de Consulta de Zonas.

**Pasos a seguir:**
1. El usuario selecciona el radio button 'Descripción'.
2. El sistema envía la petición al backend con el parámetro order='descripcion'.
3. El sistema muestra la tabla ordenada por 'Descripción'.

**Resultado esperado:**
La tabla se reordena correctamente por el campo 'Descripción'.

**Datos de prueba:**
Registros con descripciones distintas y fácilmente ordenables alfabéticamente.

---

## Caso de Uso 3: Exportar a Excel (CSV)

**Descripción:** El usuario exporta la tabla de zonas a un archivo Excel-compatible (CSV).

**Precondiciones:**
El usuario visualiza la tabla de zonas.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Exportar Excel'.
2. El sistema descarga un archivo CSV con los datos actuales de la tabla.

**Resultado esperado:**
El archivo CSV contiene los mismos datos que la tabla y puede abrirse en Excel.

**Datos de prueba:**
Cualquier conjunto de datos en la tabla ta_16_zonas.

---



## Casos de Prueba

# Casos de Prueba: Consulta de Zonas

## Caso 1: Consulta inicial
- **Acción:** Acceder a la página de Consulta de Zonas.
- **Esperado:** Se muestran todas las zonas ordenadas por 'Control'.
- **Validación:** El primer registro corresponde al menor valor de 'ctrol_zona'.

## Caso 2: Cambio de orden
- **Acción:** Seleccionar 'Descripción' como orden.
- **Esperado:** La tabla se reordena alfabéticamente por 'descripcion'.
- **Validación:** El primer registro corresponde a la descripción alfabéticamente menor.

## Caso 3: Exportar a Excel
- **Acción:** Hacer clic en 'Exportar Excel'.
- **Esperado:** Se descarga un archivo CSV con los datos actuales.
- **Validación:** El archivo contiene los mismos datos que la tabla y puede abrirse en Excel.

## Caso 4: Sin datos
- **Acción:** Si la tabla ta_16_zonas está vacía.
- **Esperado:** La tabla muestra 'No hay datos'.
- **Validación:** No se produce error y el botón de exportar muestra alerta de 'No hay datos para exportar'.

## Caso 5: Error de backend
- **Acción:** Simular error en el stored procedure (por ejemplo, campo de orden inválido).
- **Esperado:** El frontend muestra mensaje de error amigable.
- **Validación:** El usuario ve el mensaje y no se rompe la interfaz.


