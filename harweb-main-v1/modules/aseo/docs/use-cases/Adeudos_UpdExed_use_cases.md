# Casos de Uso - Adeudos_UpdExed

**Categoría:** Form

## Caso de Uso 1: Modificar cantidad de excedencias para un contrato vigente

**Descripción:** El usuario busca una excedencia vigente y actualiza la cantidad.

**Precondiciones:**
El contrato, periodo y tipo de operación existen y están vigentes.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato, tipo de aseo, año, mes y tipo de movimiento.
2. Presiona 'Buscar'.
3. El sistema muestra la cantidad actual de excedencias.
4. El usuario ingresa la nueva cantidad y el oficio.
5. Presiona 'Actualizar'.

**Resultado esperado:**
La cantidad de excedencias y el importe se actualizan correctamente. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9, "ejercicio": 2024, "mes": 6, "ctrol_operacion": 7, "cantidad": 15, "oficio": "OF-2024-001", "usuario": 1 }

---

## Caso de Uso 2: Intentar modificar excedencia inexistente

**Descripción:** El usuario intenta buscar una excedencia que no existe.

**Precondiciones:**
No existe excedencia vigente para los parámetros dados.

**Pasos a seguir:**
1. El usuario ingresa datos de búsqueda incorrectos.
2. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra mensaje de error indicando que no existe excedencia vigente.

**Datos de prueba:**
{ "contrato": 99999, "ctrol_aseo": 9, "ejercicio": 2024, "mes": 6, "ctrol_operacion": 7 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta buscar o actualizar sin llenar todos los campos requeridos.

**Precondiciones:**
El usuario deja campos vacíos o con datos inválidos.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'contrato' y presiona 'Buscar'.
2. El usuario deja vacío el campo 'cantidad' y presiona 'Actualizar'.

**Resultado esperado:**
El sistema muestra mensajes de error de validación.

**Datos de prueba:**
{ "contrato": "", "ctrol_aseo": 9, "ejercicio": 2024, "mes": 6, "ctrol_operacion": 7 }

---

