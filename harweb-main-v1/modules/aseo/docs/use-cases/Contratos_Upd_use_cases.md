# Casos de Uso - Contratos_Upd

**Categoría:** Form

## Caso de Uso 1: Actualización de domicilio y zona de un contrato vigente

**Descripción:** El usuario necesita actualizar el domicilio y la zona de un contrato vigente, registrando el documento de soporte.

**Precondiciones:**
El contrato existe y está vigente. El usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario accede a la página de actualización de contratos.
2. Ingresa el número de contrato y selecciona el tipo de aseo.
3. Presiona 'Buscar Contrato'.
4. El sistema carga los datos actuales del contrato.
5. El usuario modifica el domicilio y selecciona una nueva zona.
6. Ingresa el documento y descripción del cambio.
7. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El contrato es actualizado correctamente, el cambio queda registrado en el historial y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "num_contrato": 12345,
  "ctrol_aseo": 9,
  "domicilio": "AV. NUEVA 123",
  "ctrol_zona": 100002,
  "documento": "DR/2024/001",
  "descripcion_docto": "Cambio de domicilio por reubicación",
  "usuario": 5
}

---

## Caso de Uso 2: Intento de actualización con cantidad de recolección inválida

**Descripción:** El usuario intenta actualizar la cantidad de recolección a cero, lo cual no es permitido.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Intenta poner la cantidad de recolección en 0.
3. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El sistema rechaza la actualización y muestra un mensaje de error indicando que la cantidad debe ser mayor a cero.

**Datos de prueba:**
{
  "num_contrato": 12345,
  "ctrol_aseo": 9,
  "cantidad_recolec": 0,
  "usuario": 5
}

---

## Caso de Uso 3: Actualización de recaudadora y registro de documento

**Descripción:** El usuario cambia la recaudadora asignada al contrato y registra el documento de soporte.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Cambia la recaudadora seleccionada.
3. Ingresa el documento y descripción.
4. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El contrato es actualizado y el cambio queda registrado en el historial.

**Datos de prueba:**
{
  "num_contrato": 12345,
  "ctrol_aseo": 9,
  "id_rec": 3,
  "documento": "DR/2024/002",
  "descripcion_docto": "Cambio de recaudadora por solicitud",
  "usuario": 5
}

---

