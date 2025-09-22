# Casos de Uso - AdeudosContratos

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Vigentes por Colonia y Calle

**Descripción:** El usuario desea obtener un listado de todos los contratos vigentes con adeudos en una colonia y calle específica.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los números de colonia y calle.

**Pasos a seguir:**
1. Accede a la página de Listados de Adeudos.
2. Selecciona la opción 'Adeudos'.
3. Ingresa el número de colonia (ej: 101).
4. Ingresa el número de calle (ej: 5).
5. Hace clic en 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla con los contratos vigentes con adeudos para la colonia y calle seleccionadas.

**Datos de prueba:**
{ "colonia": 101, "calle": 5 }

---

## Caso de Uso 2: Listado de Contratos Liquidados por Colonia y Saldo

**Descripción:** El usuario requiere un listado de contratos liquidados en una colonia cuyo saldo es menor o igual a un importe específico.

**Precondiciones:**
El usuario tiene acceso y conoce el número de colonia y el importe límite.

**Pasos a seguir:**
1. Accede a la página de Listados de Adeudos.
2. Selecciona la opción 'Liquidados'.
3. Selecciona la clasificación 'Colonia'.
4. Ingresa el número de colonia (ej: 102).
5. Ingresa el importe límite (ej: 100.00).
6. Hace clic en 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla con los contratos liquidados cuyo saldo es menor o igual al importe indicado.

**Datos de prueba:**
{ "colonia": 102, "importe": 100.00 }

---

## Caso de Uso 3: Listado de Pagos con Descuento por Colonia

**Descripción:** El usuario desea ver todos los contratos que han realizado pagos con descuento en una colonia específica.

**Precondiciones:**
El usuario tiene acceso y conoce el número de colonia.

**Pasos a seguir:**
1. Accede a la página de Listados de Adeudos.
2. Selecciona la opción 'Pagos con Descuento'.
3. Ingresa el número de colonia (ej: 103).
4. Hace clic en 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla con los pagos realizados con descuento en la colonia seleccionada.

**Datos de prueba:**
{ "colonia": 103 }

---

