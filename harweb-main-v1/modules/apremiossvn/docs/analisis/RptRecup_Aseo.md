# Documentación Técnica: Migración Formulario RptRecup_Aseo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de "Orden de Requerimiento de Pago y Embargo, Derechos de Aseo Contratado" (RptRecup_Aseo) desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (Base de datos).

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. Flujo de Datos
1. El usuario ingresa los parámetros (folio inicial, folio final, oficina) en la página Vue.
2. Vue envía un POST a `/api/execute` con `eRequest: 'RptRecup_Aseo.getReport'` y los parámetros.
3. Laravel recibe la petición, ejecuta el stored procedure `rptrecup_aseo_report` y obtiene los datos.
4. Laravel también ejecuta `rptrecup_aseo_recaudadora` para obtener los datos de la recaudadora.
5. El resultado se retorna en el campo `eResponse.data`.
6. Vue renderiza la información en tarjetas, mostrando todos los campos relevantes y el texto legal.

## 4. Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "RptRecup_Aseo.getReport",
    "params": {
      "folio1": 1000,
      "folio2": 1010,
      "ofna": 5
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": {
        "adeudos": [ ... ],
        "recaudadora": [ ... ]
      },
      "message": ""
    }
  }
  ```

## 5. Stored Procedures
- **rptrecup_aseo_report:** Devuelve todos los datos de adeudos para el rango de folios y oficina.
- **rptrecup_aseo_recaudadora:** Devuelve los datos de la recaudadora para la oficina.
- **fecha_a_letras:** Convierte una fecha a formato "día de Mes de Año" en español.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse con autenticación (ej: JWT) en producción.
- Validar que los parámetros requeridos estén presentes y sean del tipo correcto.

## 7. Consideraciones de Migración
- Todos los campos y lógica de los queries Delphi han sido trasladados a stored procedures.
- El frontend no utiliza tabs ni componentes tabulares, cada formulario es una página independiente.
- El texto legal y estructura del reporte se mantiene fiel al original.

## 8. Extensibilidad
- Para agregar nuevos formularios, basta con agregar nuevos eRequest y stored procedures.
- El endpoint `/api/execute` es genérico y puede manejar múltiples acciones.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 12

---
