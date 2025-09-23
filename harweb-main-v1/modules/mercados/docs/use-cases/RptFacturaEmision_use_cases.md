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

