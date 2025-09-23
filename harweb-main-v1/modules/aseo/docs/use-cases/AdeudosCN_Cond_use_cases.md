# Casos de Uso - AdeudosCN_Cond

**Categoría:** Form

## Caso de Uso 1: Condonar un adeudo de exedencia vigente

**Descripción:** El usuario condona un adeudo de exedencia vigente para un contrato y periodo específico.

**Precondiciones:**
El contrato y el adeudo de exedencia existen y están vigentes. El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de condonación de adeudos.
2. Ingresa el número de contrato, selecciona el tipo de aseo, año, mes, tipo de movimiento y oficio.
3. Presiona 'Ejecutar'.
4. El sistema valida la existencia del contrato y del adeudo vigente.
5. El sistema ejecuta la condonación.
6. El usuario recibe un mensaje de éxito.

**Resultado esperado:**
El adeudo es marcado como condonado (status_vigencia = 'S'), se registra la fecha, usuario y oficio.

**Datos de prueba:**
{
  "num_contrato": "12345",
  "ctrol_aseo": 9,
  "aso": "2024",
  "mes": "06",
  "ctrol_operacion": 8,
  "oficio": "OF-2024-001"
}

---

## Caso de Uso 2: Intentar condonar un adeudo inexistente

**Descripción:** El usuario intenta condonar un adeudo que no existe o no está vigente.

**Precondiciones:**
El contrato existe pero no hay adeudo vigente para el periodo y operación seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página de condonación de adeudos.
2. Ingresa los datos de un contrato y periodo sin adeudo vigente.
3. Presiona 'Ejecutar'.
4. El sistema valida y detecta que no existe adeudo vigente.
5. El usuario recibe un mensaje de error.

**Resultado esperado:**
El sistema muestra un mensaje de error y no realiza ningún cambio.

**Datos de prueba:**
{
  "num_contrato": "12345",
  "ctrol_aseo": 9,
  "aso": "2023",
  "mes": "01",
  "ctrol_operacion": 8,
  "oficio": "OF-2023-002"
}

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta ejecutar la condonación dejando campos obligatorios vacíos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de condonación de adeudos.
2. Deja uno o más campos obligatorios vacíos.
3. Presiona 'Ejecutar'.
4. El sistema valida los campos y detecta la omisión.
5. El usuario recibe un mensaje de error.

**Resultado esperado:**
El sistema no ejecuta la condonación y muestra un mensaje de error indicando los campos faltantes.

**Datos de prueba:**
{
  "num_contrato": "",
  "ctrol_aseo": "",
  "aso": "2024",
  "mes": "06",
  "ctrol_operacion": "",
  "oficio": ""
}

---

