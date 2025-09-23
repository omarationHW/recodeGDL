# Casos de Uso - Contratos_Upd_UndC

**Categoría:** Form

## Caso de Uso 1: Actualización exitosa de unidades de recolección

**Descripción:** El usuario busca un contrato vigente y actualiza la cantidad de unidades de recolección, adjuntando la documentación probatoria.

**Precondiciones:**
El contrato existe y está vigente. El usuario tiene permisos de actualización.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del contrato.
4. El usuario ingresa la nueva cantidad, ejercicio, mes, documento y descripción.
5. Presiona 'Actualizar Unidades'.

**Resultado esperado:**
La cantidad de unidades se actualiza, los importes de pagos futuros se recalculan, y el documento queda registrado en el historial.

**Datos de prueba:**
{ "contrato": 1803, "ctrol_aseo": 8, "nueva_cantidad": 12, "ejercicio": 2024, "mes": 6, "documento": "DR/2024/06/01", "descripcion_docto": "Cambio por ampliación de servicio" }

---

## Caso de Uso 2: Intento de actualización con cantidad inválida

**Descripción:** El usuario intenta actualizar la cantidad de unidades a cero.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Ingresa '0' como nueva cantidad.
3. Intenta actualizar.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que la cantidad debe ser mayor a cero.

**Datos de prueba:**
{ "contrato": 1803, "ctrol_aseo": 8, "nueva_cantidad": 0, "ejercicio": 2024, "mes": 6, "documento": "DR/2024/06/01", "descripcion_docto": "Intento inválido" }

---

## Caso de Uso 3: Intento de actualización sin documento probatorio

**Descripción:** El usuario intenta actualizar las unidades sin adjuntar documento.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Ingresa la nueva cantidad y ejercicio, pero deja el campo documento vacío.
3. Intenta actualizar.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que el documento es obligatorio.

**Datos de prueba:**
{ "contrato": 1803, "ctrol_aseo": 8, "nueva_cantidad": 15, "ejercicio": 2024, "mes": 6, "documento": "", "descripcion_docto": "" }

---

