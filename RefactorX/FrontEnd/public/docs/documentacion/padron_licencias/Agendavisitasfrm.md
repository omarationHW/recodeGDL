# Documentación Técnica: Agendavisitasfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario Agenda de Visitas

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `Agendavisitasfrm` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original: consulta, exportación e impresión de visitas agendadas por dependencia y rango de fechas.

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` que recibe un `eRequest` y parámetros, y responde con un objeto `eResponse`.
- **Frontend:** Componente Vue.js como página independiente, con navegación, filtros, tabla de resultados, exportación a Excel y función de impresión.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures y funciones.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "get_agenda_visitas",
    "params": {
      "id_dependencia": 1,
      "fechaini": "2024-06-01",
      "fechafin": "2024-06-30"
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures y Funciones
- **sp_get_dependencias:** Devuelve el catálogo de dependencias.
- **sp_get_agenda_visitas:** Devuelve las visitas agendadas filtradas.
- **fn_dialetra:** Devuelve el nombre del día de la semana en español.

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Filtros: rango de fechas y dependencia.
- Tabla de resultados.
- Botones para exportar a Excel (CSV) e imprimir.
- Breadcrumb de navegación.

## 6. Exportación e Impresión
- **Exportar:** Genera un archivo CSV en el frontend con los datos actuales.
- **Imprimir:** Abre una ventana emergente con el reporte listo para impresión.

## 7. Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.

## 8. Consideraciones
- El endpoint `/api/execute` puede ser extendido para otros formularios.
- El frontend puede adaptarse a frameworks como Vuetify o BootstrapVue para mejorar la UI.

## 9. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11
- Axios (frontend)

## 10. Instalación de Stored Procedures
Ejecutar los scripts SQL en la base de datos destino `BasePHP`.

## 11. Pruebas
Ver sección de casos de uso y casos de prueba.

## Casos de Prueba

## Casos de Prueba: Agenda de Visitas

### Caso 1: Consulta exitosa de visitas agendadas
- **Precondición:** Existen visitas agendadas para la dependencia 1 entre 2024-06-01 y 2024-06-30.
- **Acción:**
  - Enviar POST a `/api/execute` con:
    ```json
    {
      "eRequest": "get_agenda_visitas",
      "params": {
        "id_dependencia": 1,
        "fechaini": "2024-06-01",
        "fechafin": "2024-06-30"
      }
    }
    ```
- **Resultado esperado:**
  - `eResponse.success` es `true`.
  - `eResponse.data` contiene al menos una fila con los campos esperados.

### Caso 2: Consulta sin resultados
- **Precondición:** No existen visitas agendadas para la dependencia 99 en el rango dado.
- **Acción:**
  - Enviar POST a `/api/execute` con:
    ```json
    {
      "eRequest": "get_agenda_visitas",
      "params": {
        "id_dependencia": 99,
        "fechaini": "2024-01-01",
        "fechafin": "2024-01-31"
      }
    }
    ```
- **Resultado esperado:**
  - `eResponse.success` es `true`.
  - `eResponse.data` es un arreglo vacío.

### Caso 3: Exportación de resultados
- **Precondición:** Hay resultados en la tabla de visitas.
- **Acción:**
  - El usuario presiona 'Exportar a Excel'.
- **Resultado esperado:**
  - Se descarga un archivo CSV con los datos actuales.

### Caso 4: Impresión del reporte
- **Precondición:** Hay resultados en la tabla de visitas.
- **Acción:**
  - El usuario presiona 'Imprimir'.
- **Resultado esperado:**
  - Se abre una ventana de impresión con el reporte formateado.

### Caso 5: Parámetros faltantes
- **Acción:**
  - Enviar POST a `/api/execute` con:
    ```json
    {
      "eRequest": "get_agenda_visitas",
      "params": {
        "id_dependencia": 1
      }
    }
    ```
- **Resultado esperado:**
  - `eResponse.success` es `false`.
  - `eResponse.message` indica los parámetros faltantes.

## Casos de Uso

# Casos de Uso - Agendavisitasfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de visitas agendadas por dependencia y rango de fechas

**Descripción:** El usuario desea consultar todas las visitas agendadas para una dependencia específica en un rango de fechas.

**Precondiciones:**
El usuario tiene acceso al sistema y existen visitas agendadas en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Agenda de Visitas'.
2. Selecciona una dependencia del listado.
3. Selecciona la fecha de inicio y fin del rango.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todas las visitas agendadas que cumplen con los filtros seleccionados.

**Datos de prueba:**
id_dependencia: 2
fechaini: 2024-06-01
fechafin: 2024-06-30

---

## Caso de Uso 2: Exportación de visitas agendadas a Excel

**Descripción:** El usuario desea exportar el listado de visitas agendadas a un archivo Excel (CSV).

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en la tabla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar a Excel'.
2. El sistema genera y descarga un archivo CSV con los datos mostrados.

**Resultado esperado:**
El archivo CSV contiene todas las filas y columnas visibles en la tabla.

**Datos de prueba:**
Resultado de la consulta anterior.

---

## Caso de Uso 3: Impresión del reporte de visitas agendadas

**Descripción:** El usuario desea imprimir el reporte de visitas agendadas filtradas.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en la tabla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Imprimir'.
2. El sistema abre una ventana de impresión con el reporte formateado.
3. El usuario imprime el reporte.

**Resultado esperado:**
El reporte impreso contiene los datos filtrados y el encabezado correspondiente.

**Datos de prueba:**
Resultado de la consulta anterior.

---
