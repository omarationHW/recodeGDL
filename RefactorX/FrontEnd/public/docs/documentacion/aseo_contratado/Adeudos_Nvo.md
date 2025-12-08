# DocumentaciÃ³n TÃ©cnica: Adeudos_Nvo

## AnÃ¡lisis TÃ©cnico

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


## Casos de Prueba

## Casos de Prueba para Adeudos_Nvo

### Caso 1: Consulta Concentrada - Periodos Vencidos
- **Entrada:** contrato=12345, ctrol_aseo=8, vigencia=V
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuenta', params: { contrato:12345, ctrol_aseo:8, vigencia:'V' } } }
- **Esperado:** status=ok, data contiene al menos un objeto con campos concepto, importe_adeudos, importe_recargos, importe_multa, importe_gastos, importe_act

### Caso 2: Consulta Detallada - Otro Periodo
- **Entrada:** contrato=54321, ctrol_aseo=4, vigencia=O, anio=2023, mes=05
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuentaDetallado', params: { contrato:54321, ctrol_aseo:4, vigencia:'O', anio:'2023', mes:'05' } } }
- **Esperado:** status=ok, data contiene array de conceptos, cada uno con cant_recolec, importe_adeudos_multa, importe_recargos_gastos, importe_act

### Caso 3: Impresión F02
- **Entrada:** tipo=O, numero=12345, rep=V, pref=2024-06
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuentaF02', params: { tipo:'O', numero:12345, rep:'V', pref:'2024-06' } } }
- **Esperado:** status=ok, data contiene array con campos periodo, concepto, cant_recolec, importe_adeudos, importe_recargos, importe_multa, importe_gastos, actualizacion

### Caso 4: Contrato No Existente
- **Entrada:** contrato=99999, ctrol_aseo=1, vigencia=V
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuenta', params: { contrato:99999, ctrol_aseo:1, vigencia:'V' } } }
- **Esperado:** status=error, message indica que el contrato no existe

### Caso 5: Parámetros Faltantes
- **Entrada:** contrato=12345
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuenta', params: { contrato:12345 } } }
- **Esperado:** status=error, message indica parámetros faltantes


## Casos de Uso

# Casos de Uso - Adeudos_Nvo

**Categoría:** Form

## Caso de Uso 1: Consulta de Estado de Cuenta Concentrado - Periodos Vencidos

**Descripción:** El usuario consulta el estado de cuenta concentrado de un contrato para los periodos vencidos.

**Precondiciones:**
El contrato y tipo de aseo existen y están vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Selecciona 'Periodos Vencidos'.
3. Da clic en 'Consultar Estado de Cuenta'.
4. El sistema muestra el resumen de adeudos, recargos, multas, gastos y actualización.

**Resultado esperado:**
Se muestra una tabla con los totales por concepto para el contrato seleccionado.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 8, "vigencia": "V" }

---

## Caso de Uso 2: Consulta de Estado de Cuenta Detallado - Otro Periodo

**Descripción:** El usuario consulta el estado de cuenta detallado de un contrato para un periodo específico.

**Precondiciones:**
El contrato y tipo de aseo existen.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Selecciona 'Otro Periodo'.
3. Ingresa año '2023' y mes '05'.
4. Da clic en 'Consultar Estado de Cuenta'.
5. El sistema muestra el detalle por concepto y periodo.

**Resultado esperado:**
Se muestra una tabla detallada con los conceptos, cantidades y montos para el periodo seleccionado.

**Datos de prueba:**
{ "contrato": 54321, "ctrol_aseo": 4, "vigencia": "O", "anio": "2023", "mes": "05" }

---

## Caso de Uso 3: Impresión de Estado de Cuenta F02

**Descripción:** El usuario imprime el estado de cuenta F02 para un contrato y periodo.

**Precondiciones:**
El contrato existe y tiene adeudos en el periodo solicitado.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y tipo de aseo.
2. Selecciona el periodo deseado.
3. Da clic en 'Imprimir Detallado'.
4. El sistema genera la vista previa de impresión F02.

**Resultado esperado:**
Se muestra la vista previa de impresión con los datos F02.

**Datos de prueba:**
{ "tipo": "O", "numero": 12345, "rep": "V", "pref": "2024-06" }

---



---
**Componente:** `Adeudos_Nvo.vue`
**MÃ³dulo:** `aseo_contratado`

