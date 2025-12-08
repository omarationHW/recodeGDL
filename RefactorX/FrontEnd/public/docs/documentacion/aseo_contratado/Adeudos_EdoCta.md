# DocumentaciÃ³n TÃ©cnica: Adeudos_EdoCta

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Adeudos_EdoCta (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación y validación.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **API**: Todas las acciones (init, consulta, procesamiento) se hacen vía `/api/execute` usando el patrón eRequest/eResponse.

## 2. Flujo de Trabajo
1. **Inicialización**: El frontend solicita los catálogos (tipos de aseo, meses, vigencias) usando `action: 'init'`.
2. **Captura de Datos**: El usuario ingresa el número de contrato, selecciona tipo de aseo y vigencia/periodo.
3. **Procesamiento**: Al enviar el formulario, el frontend llama a `action: 'procesarAdeudos'` con los parámetros.
4. **Backend**:
    - Ejecuta los stored procedures necesarios para generar el detalle de pagos y apremios.
    - Consulta los contratos y sus detalles.
    - Devuelve los resultados en `eResponse`.
5. **Visualización**: El frontend muestra los resultados en tablas, con totales.

## 3. API Detallada
### Endpoint
- **POST** `/api/execute`
- **Body**:
  ```json
  {
    "eRequest": {
      "action": "init|getTipoAseo|getContratos|procesarAdeudos|getDetallePagos",
      "params": { ... }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": { ... }
  }
  ```

### Acciones Soportadas
- `init`: Devuelve catálogos iniciales.
- `getTipoAseo`: Devuelve tipos de aseo.
- `getContratos`: Devuelve contratos filtrados.
- `procesarAdeudos`: Ejecuta la lógica principal (stored procedures) y devuelve resultados.
- `getDetallePagos`: Devuelve detalle de pagos para un contrato.

## 4. Stored Procedures
- **sp_creadetp**: Limpia y prepara la tabla de detalle de pagos.
- **sp_detpagos**: Genera el detalle de pagos para un contrato y periodo.
- **sp_detapremios**: Genera el detalle de apremios para un contrato.

## 5. Validaciones
- El número de contrato y tipo de aseo son obligatorios.
- Si la vigencia es 'A' (otro periodo), el año y mes son obligatorios.
- El backend valida la existencia de contratos antes de procesar.

## 6. Seguridad
- El endpoint debe estar protegido por autenticación (no incluido aquí).
- Validar y sanitizar todos los parámetros recibidos.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden evolucionar sin cambiar el frontend.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con los de PostgreSQL.
- Los stored procedures deben ser revisados para lógica específica de negocio.
- El frontend puede ser adaptado a cualquier framework SPA.

## 9. Ejemplo de Llamada API
```json
POST /api/execute
{
  "eRequest": {
    "action": "procesarAdeudos",
    "params": {
      "contrato": "12345",
      "ctrol_aseo": 9,
      "vigencia": "V",
      "ejercicio": 2024,
      "mes": "06"
    }
  }
}
```

## 10. Respuesta Esperada
```json
{
  "eResponse": {
    "resultados": [
      {
        "contrato": { ... },
        "detPagos": [ ... ],
        "detPagosSum": { ... }
      }
    ]
  }
}
```


## Casos de Prueba

# Casos de Prueba para Adeudos_EdoCta

## Caso 1: Consulta Vigente Exitosa
- **Entrada:** contrato=12345, ctrol_aseo=9, vigencia=V
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.resultados contiene al menos un contrato
  - Cada contrato tiene detPagos y detPagosSum

## Caso 2: Consulta Otro Periodo Exitosa
- **Entrada:** contrato=12345, ctrol_aseo=9, vigencia=A, ejercicio=2023, mes=03
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.resultados contiene al menos un contrato
  - detPagos corresponde al periodo solicitado

## Caso 3: Contrato Inexistente
- **Entrada:** contrato=99999, ctrol_aseo=9, vigencia=V
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.error == 'No existen contratos con estos datos'

## Caso 4: Validación de Campos Obligatorios
- **Entrada:** contrato='', ctrol_aseo='', vigencia='V'
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.error indica campos obligatorios faltantes

## Caso 5: SQL Injection Prevention
- **Entrada:** contrato="12345; DROP TABLE ta_16_contratos;--", ctrol_aseo=9, vigencia=V
- **Acción:** procesarAdeudos
- **Esperado:**
  - HTTP 200
  - eResponse.error (no ejecuta SQL malicioso)


## Casos de Uso

# Casos de Uso - Adeudos_EdoCta

**Categoría:** Form

## Caso de Uso 1: Consulta de Estado de Cuenta Vigente

**Descripción:** El usuario consulta el estado de cuenta de un contrato vigente para el periodo actual.

**Precondiciones:**
El contrato existe y está vigente. El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Selecciona 'Periodos Vigentes'.
3. Presiona 'Procesar'.
4. El sistema ejecuta los stored procedures y muestra el detalle de pagos.

**Resultado esperado:**
Se muestra el detalle de pagos y totales para el contrato seleccionado.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9, "vigencia": "V" }

---

## Caso de Uso 2: Consulta de Estado de Cuenta para Otro Periodo

**Descripción:** El usuario consulta el estado de cuenta de un contrato para un periodo específico (año y mes).

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Selecciona 'Otro Periodo'.
3. Ingresa el año y mes deseados.
4. Presiona 'Procesar'.
5. El sistema ejecuta los stored procedures y muestra el detalle de pagos para ese periodo.

**Resultado esperado:**
Se muestra el detalle de pagos y totales para el periodo seleccionado.

**Datos de prueba:**
{ "contrato": "12345", "ctrol_aseo": 9, "vigencia": "A", "ejercicio": 2023, "mes": "03" }

---

## Caso de Uso 3: Error al Consultar Contrato Inexistente

**Descripción:** El usuario intenta consultar un contrato que no existe.

**Precondiciones:**
El contrato no existe en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa un número de contrato inexistente y selecciona el tipo de aseo.
2. Presiona 'Procesar'.
3. El sistema valida y muestra un mensaje de error.

**Resultado esperado:**
Se muestra un mensaje de error indicando que no existen contratos con esos datos.

**Datos de prueba:**
{ "contrato": "99999", "ctrol_aseo": 9, "vigencia": "V" }

---



---
**Componente:** `Adeudos_EdoCta.vue`
**MÃ³dulo:** `aseo_contratado`

