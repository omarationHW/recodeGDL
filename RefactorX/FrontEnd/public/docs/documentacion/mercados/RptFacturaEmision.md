# RptFacturaEmision

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: RptFacturaEmision

## Descripción General
El formulario **RptFacturaEmision** permite generar la facturación de estados de cuenta para locales de mercados municipales, filtrando por oficina recaudadora, año, periodo y mercado. Incluye lógica de cálculo de importes y reglas de negocio específicas según el tipo de local y mercado.

## Arquitectura
- **Backend (Laravel):**
  - Un único controlador (`RptFacturaEmisionController`) expone el endpoint `/api/execute`.
  - Todas las acciones se envían como un objeto `eRequest` con los campos `action` y `params`.
  - El controlador invoca stored procedures PostgreSQL para obtener los datos requeridos.

- **Frontend (Vue.js):**
  - Un componente de página independiente (`RptFacturaEmisionPage.vue`) permite al usuario ingresar los parámetros y visualizar los resultados en una tabla.
  - No utiliza tabs ni componentes tabulares; cada formulario es una página completa.

- **Base de Datos (PostgreSQL):**
  - Toda la lógica SQL se implementa en stored procedures (`sp_rpt_factura_emision`, `sp_get_vencimiento_rec`).
  - Los cálculos de campos como `importe` y `datoslocal` se realizan en el SP.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "getFacturaEmision",
    "params": {
      "oficina": 1,
      "axo": 2024,
      "periodo": 6,
      "mercado": 5,
      "opc": 1
    }
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success",
    "data": [ ... ],
    "message": "Datos de facturación obtenidos correctamente"
  }
  ```

## Stored Procedures
- **sp_rpt_factura_emision:**
  - Parámetros: oficina, año, periodo, mercado, opción (1=solo mercado, 2=todos)
  - Devuelve: lista de locales con datos calculados y reglas de negocio.
- **sp_get_vencimiento_rec:**
  - Parámetro: mes
  - Devuelve: fechas de vencimiento y acumulados de sábados para el cálculo de importes.

## Validaciones
- Todos los parámetros son requeridos y validados en el backend.
- El frontend valida que los campos sean numéricos y requeridos antes de enviar la petición.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: JWT o session).
- Los parámetros son validados y sanitizados antes de ejecutar los SP.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser reutilizados por otros módulos.

## Navegación
- El componente Vue incluye breadcrumbs para navegación clara.
- Cada formulario es una página independiente y funcional.

## Pruebas
- Se incluyen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del sistema.


## Casos de Uso

# Casos de Uso - RptFacturaEmision

**Categoría:** Form

## Caso de Uso 1: Consulta de Facturación para un Mercado Específico

**Descripción:** El usuario desea obtener la facturación de estados de cuenta para el mercado 5 de la oficina 1, año 2024, periodo 6.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar facturación.

**Pasos a seguir:**
1. Ingresar a la página de Facturación de Estados de Cuenta.
2. Ingresar '1' en Oficina, '2024' en Año, '6' en Periodo, '5' en Mercado, seleccionar 'Solo Mercado Seleccionado' en Opción.
3. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los locales del mercado 5, sus datos, superficie, renta, importe y recaudadora. Se muestran los totales globales.

**Datos de prueba:**
{ "oficina": 1, "axo": 2024, "periodo": 6, "mercado": 5, "opc": 1 }

---

## Caso de Uso 2: Consulta de Facturación para Todos los Mercados

**Descripción:** El usuario desea obtener la facturación de todos los mercados de la oficina 2 para el año 2023, periodo 12.

**Precondiciones:**
El usuario tiene acceso y permisos para consultar todos los mercados.

**Pasos a seguir:**
1. Ingresar a la página de Facturación de Estados de Cuenta.
2. Ingresar '2' en Oficina, '2023' en Año, '12' en Periodo, '0' en Mercado, seleccionar 'Todos los Mercados' en Opción.
3. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los locales de todos los mercados de la oficina 2, con sus datos y totales.

**Datos de prueba:**
{ "oficina": 2, "axo": 2023, "periodo": 12, "mercado": 0, "opc": 2 }

---

## Caso de Uso 3: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta consultar la facturación sin ingresar el campo 'periodo'.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Ingresar a la página de Facturación de Estados de Cuenta.
2. Dejar vacío el campo 'Periodo'.
3. Presionar el botón 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo 'periodo' es requerido y no realiza la consulta.

**Datos de prueba:**
{ "oficina": 1, "axo": 2024, "periodo": "", "mercado": 5, "opc": 1 }

---



## Casos de Prueba

# Casos de Prueba: RptFacturaEmision

## Caso 1: Consulta exitosa para un mercado
- **Entrada:** { "action": "getFacturaEmision", "params": { "oficina": 1, "axo": 2024, "periodo": 6, "mercado": 5, "opc": 1 } }
- **Esperado:** status=success, data contiene lista de locales del mercado 5, message correcto.

## Caso 2: Consulta exitosa para todos los mercados
- **Entrada:** { "action": "getFacturaEmision", "params": { "oficina": 2, "axo": 2023, "periodo": 12, "mercado": 0, "opc": 2 } }
- **Esperado:** status=success, data contiene lista de todos los mercados de oficina 2.

## Caso 3: Parámetro faltante
- **Entrada:** { "action": "getFacturaEmision", "params": { "oficina": 1, "axo": 2024, "periodo": "", "mercado": 5, "opc": 1 } }
- **Esperado:** status=error, message indica que 'periodo' es requerido.

## Caso 4: Error de base de datos
- **Simulación:** Forzar error en el SP (ej: pasar oficina inexistente)
- **Esperado:** status=error, message con detalle del error SQL.

## Caso 5: Consulta de vencimiento de recargos
- **Entrada:** { "action": "getVencimientoRec", "params": { "mes": 6 } }
- **Esperado:** status=success, data contiene fechas de recargo y descuento para el mes 6.



