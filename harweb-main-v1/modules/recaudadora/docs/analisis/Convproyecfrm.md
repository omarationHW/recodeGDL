# Documentación Técnica: Migración Formulario Proyección de Convenio (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite simular y proyectar la liquidación de adeudos prediales mediante convenios de pago en parcialidades. El usuario ingresa la cuenta catastral, número de mensualidades, importe total, fecha inicial y (opcionalmente) un porcentaje de pago inicial. El sistema calcula la proyección de pagos, mostrando para cada parcialidad los importes de impuesto, recargos, gastos, multa y la fecha de vencimiento.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3+ (SPA), componente de página independiente.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse (entrada/salida JSON).

## 3. API Backend
### Endpoint Unificado
- **Ruta:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getConvenioProyeccion", // o "getConvenioProyeccionPorcentaje"
      "params": {
        "cvecuenta": 12345,
        "mensualidades": 12,
        "importe": 10000.00,
        "fecha_inicial": "2024-07-01",
        "porcentaje_inicial": 20 // opcional
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
          "s_parcial": 1,
          "s_deaxo": 2024,
          "s_debim": 4,
          "s_haaxo": 2024,
          "s_habim": 4,
          "s_impuesto": 700.00,
          "s_recagos": 200.00,
          "s_gastos": 50.00,
          "s_multa": 50.00,
          "s_tbim": 1,
          "fec_venc": "2024-07-01"
        },
        ...
      ],
      "errors": []
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de cálculo de proyección y fechas de vencimiento está en SPs PostgreSQL.
- Los SPs devuelven tablas con los datos de cada parcialidad.

## 5. Frontend (Vue.js)
- Página independiente (NO tabs).
- Formulario de entrada para cuenta, mensualidades, importe, fecha inicial, porcentaje inicial.
- Botón para consultar proyección.
- Tabla con resultados de la proyección.
- Botón para imprimir (usa `window.print()`).
- Manejo de errores y validaciones.

## 6. Seguridad
- Validación de parámetros en backend y frontend.
- Solo usuarios autenticados pueden acceder al endpoint (middleware Laravel).

## 7. Flujo de Datos
1. Usuario ingresa datos y envía formulario.
2. Frontend llama `/api/execute` con acción y parámetros.
3. Backend valida, ejecuta el SP correspondiente y retorna la tabla de proyección.
4. Frontend muestra la tabla y permite imprimir.

## 8. Consideraciones
- El endpoint es único y multipropósito (eRequest/eResponse).
- Los SPs pueden ser refinados para lógica fiscal real.
- El frontend puede ser adaptado a cualquier framework SPA.

## 9. Ejemplo de Llamada
```js
axios.post('/api/execute', {
  eRequest: {
    action: 'getConvenioProyeccion',
    params: {
      cvecuenta: 12345,
      mensualidades: 12,
      importe: 10000.00,
      fecha_inicial: '2024-07-01'
    }
  }
})
```

# Fin de Documentación
