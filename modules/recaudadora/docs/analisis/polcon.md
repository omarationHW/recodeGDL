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
