# Casos de Uso - Adeudos_Ins

**Categoría:** Form

## Caso de Uso 1: Registro exitoso de exedencia para contrato vigente

**Descripción:** El usuario registra una exedencia para un contrato vigente, con todos los datos correctos.

**Precondiciones:**
El contrato existe, está vigente, y tiene cuota normal para el periodo.

**Pasos a seguir:**
1. El usuario accede a la página de Captura de Excedencias.
2. Ingresa el número de contrato, selecciona tipo de aseo, año, mes, tipo de movimiento, cantidad de exedencias y oficio.
3. Presiona 'Ejecutar'.
4. El sistema valida el contrato y las reglas de negocio.
5. El sistema inserta el registro y muestra mensaje de éxito.

**Resultado esperado:**
La exedencia se registra correctamente en la base de datos y se muestra mensaje de éxito.

**Datos de prueba:**
{
  "contrato": 1234,
  "ctrol_aseo": 9,
  "ejercicio": 2024,
  "aso": 2024,
  "mes": "06",
  "ctrol_operacion": 7,
  "exedencias": 2,
  "oficio": "OF-1234"
}

---

## Caso de Uso 2: Intento de registro con contrato inexistente

**Descripción:** El usuario intenta registrar una exedencia para un contrato que no existe.

**Precondiciones:**
El contrato no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Captura de Excedencias.
2. Ingresa un número de contrato inexistente y completa el resto del formulario.
3. Presiona 'Ejecutar'.
4. El sistema valida y detecta que el contrato no existe.

**Resultado esperado:**
El sistema muestra mensaje de error: 'Contrato no encontrado o no vigente'.

**Datos de prueba:**
{
  "contrato": 999999,
  "ctrol_aseo": 9,
  "ejercicio": 2024,
  "aso": 2024,
  "mes": "06",
  "ctrol_operacion": 7,
  "exedencias": 2,
  "oficio": "OF-9999"
}

---

## Caso de Uso 3: Intento de registro de exedencia duplicada

**Descripción:** El usuario intenta registrar una exedencia para un periodo donde ya existe una exedencia/contenedor.

**Precondiciones:**
Ya existe un registro de exedencia para el mismo contrato, periodo y tipo de operación.

**Pasos a seguir:**
1. El usuario accede a la página de Captura de Excedencias.
2. Ingresa los datos de un contrato y periodo donde ya existe exedencia.
3. Presiona 'Ejecutar'.
4. El sistema valida y detecta duplicidad.

**Resultado esperado:**
El sistema muestra mensaje de error: 'Ya existe exedencia/contenedor para este periodo'.

**Datos de prueba:**
{
  "contrato": 1234,
  "ctrol_aseo": 9,
  "ejercicio": 2024,
  "aso": 2024,
  "mes": "06",
  "ctrol_operacion": 7,
  "exedencias": 2,
  "oficio": "OF-1234"
}

---

