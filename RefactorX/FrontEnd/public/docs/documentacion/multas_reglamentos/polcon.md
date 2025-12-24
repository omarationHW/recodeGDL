# Documentación: polcon

## Análisis Técnico

# Documentación Técnica: Migración Formulario polcon (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de "Póliza Diaria Consolidada de las Recaudadoras" originalmente en Delphi, migrado a una arquitectura moderna con backend Laravel, frontend Vue.js y base de datos PostgreSQL. El reporte muestra, para un rango de fechas, el total de partidas y sumas agrupadas por cuenta de aplicación.

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de reporte en stored procedure.

## 3. Backend
### Endpoint Unificado
- **Ruta:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "polcon_report",
      "params": {
        "date_from": "YYYY-MM-DD",
        "date_to": "YYYY-MM-DD"
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        {
          "cvectaapl": "...",
          "ctaaplicacion": "...",
          "totpar": 123,
          "suma": 4567.89
        },
        ...
      ],
      "message": ""
    }
  }
  ```

### Stored Procedure
- **Nombre:** `report_polcon`
- **Parámetros:** `date_from DATE`, `date_to DATE`
- **Retorna:** Tabla con columnas `cvectaapl`, `ctaaplicacion`, `totpar`, `suma`.
- **Lógica:** Replica el query SQL original, agrupando y sumando por cuenta de aplicación.

## 4. Frontend
- **Página independiente** con ruta propia (ej. `/polcon`).
- **Campos:** Fecha inicial y final (por defecto el día actual).
- **Botón:** "Imprimir" (genera el reporte en pantalla).
- **Tabla:** Muestra los resultados agrupados, con totales al pie.
- **Mensajes:** Manejo de errores y estados de carga.

## 5. Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## 6. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba.

## 7. Consideraciones
- El reporte puede exportarse a PDF/Excel desde el frontend si se requiere (no incluido en esta versión).
- El endpoint es extensible para otros reportes siguiendo el patrón eRequest/eResponse.

## 8. Dependencias
- Laravel >= 9.x
- Vue.js >= 3.x
- PostgreSQL >= 12

## 9. Instalación
- Crear el stored procedure en la base de datos destino.
- Registrar la ruta `/api/execute` en Laravel (`routes/api.php`).
- Agregar el componente Vue.js a la aplicación SPA y registrar la ruta correspondiente.

## 10. Ejemplo de llamada API
```bash
curl -X POST /api/execute \
  -H 'Content-Type: application/json' \
  -d '{
    "eRequest": {
      "action": "polcon_report",
      "params": {
        "date_from": "2024-06-01",
        "date_to": "2024-06-30"
      }
    }
  }'
```

## Casos de Uso

# Casos de Uso - polcon

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de póliza consolidada para un día específico

**Descripción:** El usuario desea obtener el reporte de póliza diaria consolidada para el día 2024-06-10.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en las tablas para la fecha indicada.

**Pasos a seguir:**
1. El usuario accede a la página de Póliza Diaria Consolidada.
2. Selecciona la fecha '2024-06-10' en ambos campos (Desde y Hasta).
3. Presiona el botón 'Imprimir'.
4. El sistema consulta el backend y muestra el reporte en pantalla.

**Resultado esperado:**
Se muestra una tabla con las cuentas de aplicación, descripción, total de partidas y suma de montos para el día seleccionado.

**Datos de prueba:**
date_from: '2024-06-10', date_to: '2024-06-10'

---

## Caso de Uso 2: Consulta de reporte para un rango de fechas sin resultados

**Descripción:** El usuario consulta un rango de fechas donde no existen registros.

**Precondiciones:**
El usuario tiene acceso al sistema. No existen registros en las tablas para el rango 2023-01-01 a 2023-01-05.

**Pasos a seguir:**
1. El usuario accede a la página de reporte.
2. Selecciona '2023-01-01' como Desde y '2023-01-05' como Hasta.
3. Presiona 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron resultados.

**Datos de prueba:**
date_from: '2023-01-01', date_to: '2023-01-05'

---

## Caso de Uso 3: Validación de parámetros obligatorios

**Descripción:** El usuario intenta generar el reporte sin seleccionar una de las fechas.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'Hasta'.
2. Presiona 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que ambos campos de fecha son obligatorios.

**Datos de prueba:**
date_from: '2024-06-01', date_to: ''

---

## Casos de Prueba

# Casos de Prueba: polcon

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| TC01 | Consulta exitosa para un día | date_from: '2024-06-10', date_to: '2024-06-10' | Tabla con resultados agrupados por cuenta de aplicación |
| TC02 | Consulta exitosa para rango de fechas | date_from: '2024-06-01', date_to: '2024-06-15' | Tabla con resultados del rango |
| TC03 | Rango sin resultados | date_from: '2023-01-01', date_to: '2023-01-05' | Mensaje: No se encontraron resultados |
| TC04 | Falta campo obligatorio | date_from: '', date_to: '2024-06-10' | Mensaje de error: Parámetros de fecha requeridos |
| TC05 | Formato de fecha inválido | date_from: '2024-06-XX', date_to: '2024-06-10' | Mensaje de error de validación |
| TC06 | Consulta con datos grandes | date_from: '2024-01-01', date_to: '2024-06-30' | Tabla con muchos resultados, totales correctos |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

