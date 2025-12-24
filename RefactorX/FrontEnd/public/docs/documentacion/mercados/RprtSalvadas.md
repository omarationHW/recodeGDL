# RprtSalvadas

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario RprtSalvadas

## Descripción General
Este módulo corresponde a la migración del formulario Delphi `RprtSalvadas` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es permitir la generación y visualización de reportes de "salvadas" (registros) entre dos fechas.

## Arquitectura
- **Frontend:** Vue.js SPA, página independiente para el reporte.
- **Backend:** Laravel API, endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedure.

## Flujo de Datos
1. El usuario ingresa un rango de fechas y solicita el reporte.
2. El frontend envía una petición POST a `/api/execute` con un objeto `eRequest` que especifica la operación y los parámetros.
3. El backend interpreta la operación, ejecuta el stored procedure correspondiente y retorna los resultados en un objeto `eResponse`.
4. El frontend muestra los resultados en una tabla.

## Detalles Técnicos
### Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "getSalvadasReport",
      "params": {
        "start_date": "2024-06-01",
        "end_date": "2024-06-30"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        {"fecha": "2024-06-01", "descripcion": "Ejemplo", "valor": 100.0},
        ...
      ],
      "message": ""
    }
  }
  ```

### Stored Procedure
- **Nombre:** report_salvadas
- **Parámetros:** start_date (DATE), end_date (DATE)
- **Retorna:** Tabla con columnas fecha, descripcion, valor

### Frontend
- Página Vue.js independiente
- Formulario para seleccionar fechas
- Tabla de resultados
- Mensajes de error y estado

## Seguridad
- Validación de fechas en frontend y backend
- Manejo de errores y mensajes claros
- El endpoint puede protegerse con autenticación según necesidades del proyecto

## Consideraciones
- El stored procedure debe adaptarse a la estructura real de la tabla `salvadas`.
- El frontend puede ampliarse para exportar a PDF/Excel si se requiere.


## Casos de Uso

# Casos de Uso - RprtSalvadas

**Categoría:** Form

## Caso de Uso 1: Generar reporte de salvadas para el mes actual

**Descripción:** El usuario desea obtener un listado de todas las salvadas registradas durante el mes actual.

**Precondiciones:**
Existen registros en la tabla 'salvadas' para el mes actual.

**Pasos a seguir:**
1. El usuario accede a la página 'Reporte de Salvadas'.
2. Selecciona como fecha de inicio el primer día del mes actual.
3. Selecciona como fecha de fin el último día del mes actual.
4. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con todas las salvadas registradas en el mes actual, incluyendo fecha, descripción y valor.

**Datos de prueba:**
start_date: 2024-06-01
end_date: 2024-06-30

---

## Caso de Uso 2: Reporte sin resultados

**Descripción:** El usuario solicita un reporte para un rango de fechas donde no existen registros.

**Precondiciones:**
No existen registros en la tabla 'salvadas' para el rango seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página 'Reporte de Salvadas'.
2. Selecciona un rango de fechas sin registros (por ejemplo, 2023-01-01 a 2023-01-31).
3. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron resultados para el rango seleccionado.

**Datos de prueba:**
start_date: 2023-01-01
end_date: 2023-01-31

---

## Caso de Uso 3: Error por fechas inválidas

**Descripción:** El usuario intenta generar un reporte ingresando una fecha de inicio posterior a la fecha de fin.

**Precondiciones:**
El formulario permite ingresar fechas manualmente.

**Pasos a seguir:**
1. El usuario accede a la página 'Reporte de Salvadas'.
2. Ingresa como fecha de inicio '2024-07-01' y como fecha de fin '2024-06-01'.
3. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el rango de fechas es inválido.

**Datos de prueba:**
start_date: 2024-07-01
end_date: 2024-06-01

---



## Casos de Prueba

## Casos de Prueba para RprtSalvadas

| #  | Descripción                                      | Datos de Entrada                        | Resultado Esperado                                             |
|----|--------------------------------------------------|-----------------------------------------|---------------------------------------------------------------|
| 1  | Reporte con resultados                           | start_date: 2024-06-01<br>end_date: 2024-06-30 | Tabla con registros de salvadas del mes de junio 2024         |
| 2  | Reporte sin resultados                           | start_date: 2023-01-01<br>end_date: 2023-01-31 | Mensaje: "No se encontraron resultados para el rango seleccionado." |
| 3  | Fechas inválidas (inicio > fin)                  | start_date: 2024-07-01<br>end_date: 2024-06-01 | Mensaje de error: "El rango de fechas es inválido."           |
| 4  | Error de conexión a la API                       | (Desconectar backend)                    | Mensaje de error: "Error de red o del servidor"               |
| 5  | Campos requeridos vacíos                         | start_date: (vacío)<br>end_date: (vacío)   | Mensaje de error: "Campos requeridos" o validación frontend   |



