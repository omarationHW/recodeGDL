# Casos de Uso - Contratos_Upd_Und

**Categoría:** Form

## Caso de Uso 1: Actualización exitosa de unidades de recolección

**Descripción:** El usuario busca un contrato vigente y actualiza la cantidad de unidades de recolección, registrando el cambio con documentación.

**Precondiciones:**
El contrato existe y está vigente. El usuario está autenticado.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. El sistema muestra los datos del contrato.
3. El usuario selecciona la nueva unidad de recolección y cantidad.
4. El usuario ingresa el ejercicio, mes, documento y descripción.
5. El usuario confirma la actualización.
6. El sistema actualiza el contrato, los pagos y guarda el histórico.

**Resultado esperado:**
El contrato se actualiza correctamente, los pagos futuros reflejan la nueva cantidad y el movimiento queda registrado en el histórico.

**Datos de prueba:**
{
  "num_contrato": 1803,
  "ctrol_aseo": 8,
  "ctrol_recolec": 5,
  "cantidad": 4,
  "ejercicio": 2024,
  "mes": 7,
  "documento": "DR/2024/001",
  "descripcion": "Cambio por ampliación de servicio"
}

---

## Caso de Uso 2: Intento de actualización con cantidad inválida

**Descripción:** El usuario intenta actualizar el contrato con una cantidad de unidades igual a cero.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. El usuario ingresa cantidad igual a 0.
3. El usuario intenta confirmar la actualización.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que la cantidad es inválida.

**Datos de prueba:**
{
  "num_contrato": 1803,
  "ctrol_aseo": 8,
  "ctrol_recolec": 5,
  "cantidad": 0,
  "ejercicio": 2024,
  "mes": 7,
  "documento": "DR/2024/002",
  "descripcion": "Prueba cantidad cero"
}

---

## Caso de Uso 3: Intento de actualización sin documento

**Descripción:** El usuario intenta actualizar el contrato sin ingresar el documento probatorio.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. El usuario ingresa todos los datos excepto el documento.
3. El usuario intenta confirmar la actualización.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que el documento es requerido.

**Datos de prueba:**
{
  "num_contrato": 1803,
  "ctrol_aseo": 8,
  "ctrol_recolec": 5,
  "cantidad": 3,
  "ejercicio": 2024,
  "mes": 7,
  "documento": "",
  "descripcion": "Sin documento"
}

---

