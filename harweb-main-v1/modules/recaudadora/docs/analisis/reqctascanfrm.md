# Documentación Técnica: Migración Formulario reqctascanfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario "Listado de folios de requerimiento de cuentas canceladas" (reqctascanfrm) migrado desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, lógica SQL migrada a stored procedures.

## 3. Flujo de la Aplicación
1. El usuario accede a la página del formulario.
2. Selecciona una recaudadora y un rango de fechas.
3. Al hacer clic en "Imprimir", se consulta la API para obtener las cuentas canceladas y, para cada una, los folios asociados.
4. Los resultados se muestran en una tabla, agrupando folios por cuenta.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de petición:**
  ```json
  {
    "eRequest": "reqctascanfrm.get_cancelled_accounts",
    "params": {
      "recaud": 1,
      "fini": "2024-01-01",
      "ffin": "2024-01-31"
    }
  }
  ```
- **Formato de respuesta:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 5. Stored Procedures
- **report_reqctascanfrm:** Devuelve las cuentas canceladas para una recaudadora y rango de fechas.
- **report_reqctascanfrm_folios:** Devuelve los folios vigentes y no cancelados para una cuenta.

## 6. Seguridad
- Validación de parámetros en el backend.
- Manejo de errores y mensajes claros en la respuesta.

## 7. Frontend
- Página Vue.js independiente.
- Validación de campos obligatorios.
- Consulta asincrónica de datos y despliegue en tabla.
- Breadcrumb para navegación.

## 8. Consideraciones
- Las recaudadoras están fijas (4 zonas), pero pueden obtenerse por API para futura escalabilidad.
- El reporte es visualizado en pantalla, pero puede adaptarse para exportar a PDF/Excel si se requiere.

## 9. Extensibilidad
- El endpoint `/api/execute` puede manejar otros formularios y operaciones agregando nuevos valores de `eRequest`.

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11

## 11. Instalación de Stored Procedures
Ejecutar los scripts SQL proporcionados en la base de datos destino.

## 12. Pruebas
Ver sección de casos de uso y casos de prueba.
