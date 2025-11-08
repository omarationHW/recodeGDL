# Documentación Técnica: Migración Formulario Adeudos_Nvo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite consultar e imprimir el estado de cuenta de un contrato de recolección de residuos, mostrando adeudos, recargos, multas, gastos y actualización, tanto en forma concentrada como detallada, para periodos vencidos o cualquier otro periodo.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, componente de página independiente
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "getEstadoCuenta", // o getEstadoCuentaDetallado, getTipoAseo, etc
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "status": "ok|error",
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedures
- **con16_detade_01:** Estado de cuenta concentrado (adeudos, recargos, multas, gastos, actualización)
- **con16_detade_02:** Estado de cuenta detallado (por concepto, cantidades, agrupaciones)
- **sp16_adeudos_f02:** Estado de cuenta F02 (por periodo, concepto, cantidades, etc)

## 5. Flujo de la Página Vue
1. Usuario ingresa número de contrato y selecciona tipo de aseo.
2. Selecciona "Periodos Vencidos" o "Otro Periodo" (si otro, debe indicar año y mes).
3. Al consultar, se llama a `/api/execute` con acción `getEstadoCuenta` o `getEstadoCuentaDetallado`.
4. El backend ejecuta el SP correspondiente y retorna los datos.
5. El usuario puede imprimir en modo concentrado o detallado.

## 6. Validaciones
- Todos los campos requeridos deben estar completos.
- El contrato y tipo de aseo deben existir.
- El año y mes deben ser válidos si se selecciona "Otro Periodo".

## 7. Seguridad
- El endpoint debe estar protegido por autenticación JWT o session según la política del sistema.
- Los parámetros son validados y sanitizados en el backend.

## 8. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones del sistema.
- Los stored procedures pueden ser reutilizados por otros módulos.

## 9. Consideraciones de Migración
- Los nombres de los SP y parámetros se mantienen lo más fiel posible al sistema original.
- Los reportes impresos pueden ser generados en PDF en el backend o exportados desde el frontend.

## 10. Ejemplo de Request para Estado de Cuenta
```json
{
  "eRequest": {
    "action": "getEstadoCuenta",
    "params": {
      "contrato": 12345,
      "ctrol_aseo": 8,
      "vigencia": "V",
      "anio": "2024",
      "mes": "06"
    }
  }
}
```

## 11. Ejemplo de Response
```json
{
  "eResponse": {
    "status": "ok",
    "data": [
      {
        "concepto": "Adeudos",
        "importe_adeudos": 1234.56,
        "importe_recargos": 123.45,
        "importe_multa": 0.00,
        "importe_gastos": 0.00,
        "importe_act": 0.00
      }
    ]
  }
}
```

## 12. Errores Comunes
- Si el contrato no existe, retorna status `error` y message descriptivo.
- Si faltan parámetros, retorna status `error` y message descriptivo.

## 13. Pruebas y QA
- Ver sección de casos de uso y casos de prueba.

---
