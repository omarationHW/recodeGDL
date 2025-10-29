# Documentación Técnica: Migración de Formulario RptReq_Pba_Aseo

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `RptReq_Pba_Aseo` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es permitir la generación y consulta del reporte de requerimiento de pago y embargo de derechos de aseo contratado, con todos los cálculos y lógica de negocio migrados a procedimientos almacenados.

## 2. Arquitectura
- **Frontend**: Componente Vue.js como página independiente, consulta la API vía endpoint unificado `/api/execute`.
- **Backend**: Laravel Controller único (`ExecuteController`) que recibe peticiones eRequest/eResponse y ejecuta los stored procedures correspondientes.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio y cálculos se implementan en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Formato de entrada**:
  ```json
  {
    "eRequest": {
      "action": "RptReqPbaAseo:getReport",
      "params": {
        "id_rec": 1,
        "tipo_aseo": "ORDINARIO",
        "fecha_corte": "2024-06-01"
      }
    }
  }
  ```
- **Formato de salida**:
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de negocio (queries, cálculos de recargos, gastos, totales) se implementa en funciones de PostgreSQL.
- Los procedimientos almacenados devuelven tablas con los datos requeridos para el frontend.

## 5. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ejemplo: JWT o session).
- Validar los parámetros recibidos antes de ejecutar los procedimientos almacenados.

## 6. Frontend
- El componente Vue.js es una página completa, no usa tabs.
- Permite seleccionar oficina (`id_rec`), tipo de aseo y fecha de corte.
- Muestra los resultados en una tabla, con opción de impresión.

## 7. Extensibilidad
- Para agregar nuevas acciones, basta con implementar el stored procedure y agregar el case correspondiente en el controlador.

## 8. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 9. Consideraciones
- Los nombres de tablas y campos deben existir en la base de datos destino (`BasePHP`).
- Los cálculos de recargos y gastos siguen la lógica original Delphi.

## 10. Ejemplo de llamada desde frontend
```js
fetch('/api/execute', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    eRequest: {
      action: 'RptReqPbaAseo:getReport',
      params: {
        id_rec: 1,
        tipo_aseo: 'ORDINARIO',
        fecha_corte: '2024-06-01'
      }
    }
  })
})
```
