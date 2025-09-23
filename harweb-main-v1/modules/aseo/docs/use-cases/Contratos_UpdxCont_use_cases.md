# Casos de Uso - Contratos_UpdxCont

**Categoría:** Form

## Caso de Uso 1: Actualización de Domicilio y Zona de un Contrato Existente

**Descripción:** El usuario busca un contrato existente, cambia el domicilio y la zona, y registra el cambio con un documento probatorio.

**Precondiciones:**
El contrato debe existir y estar vigente. El usuario debe estar autenticado.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar Contrato'.
3. El sistema muestra los datos actuales del contrato.
4. El usuario edita el campo 'Domicilio' y selecciona una nueva zona.
5. El usuario ingresa el número de documento y la descripción del cambio.
6. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El contrato se actualiza en la base de datos, el cambio queda registrado en el histórico, y el usuario recibe un mensaje de éxito.

**Datos de prueba:**
{
  "num_contrato": 1234,
  "ctrol_aseo": 9,
  "nuevo_domicilio": "Av. Reforma 100",
  "nueva_zona": 2002,
  "documento": "DR/2024/002",
  "descripcion_docto": "Cambio de domicilio y zona por reubicación"
}

---

## Caso de Uso 2: Alta de Nueva Empresa desde Búsqueda

**Descripción:** El usuario busca una empresa por nombre, no la encuentra y decide darla de alta automáticamente.

**Precondiciones:**
El usuario debe estar autenticado.

**Pasos a seguir:**
1. El usuario abre el modal de búsqueda de empresa.
2. Ingresa el nombre 'EMPRESA NUEVA S.A.' y presiona 'Buscar'.
3. El sistema indica que no existe y pregunta si desea darla de alta.
4. El usuario confirma.
5. El sistema da de alta la empresa y la selecciona para el contrato.

**Resultado esperado:**
La empresa se crea en la base de datos y se asocia al contrato en edición.

**Datos de prueba:**
{
  "nombre": "EMPRESA NUEVA S.A."
}

---

## Caso de Uso 3: Validación de Campos Obligatorios

**Descripción:** El usuario intenta actualizar un contrato sin llenar todos los campos obligatorios.

**Precondiciones:**
El contrato debe existir. El usuario debe estar autenticado.

**Pasos a seguir:**
1. El usuario busca un contrato y deja vacío el campo 'documento'.
2. Presiona 'Actualizar Contrato'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que falta el campo 'documento'.

**Datos de prueba:**
{
  "control_contrato": 1,
  "num_empresa": 2,
  "ctrol_emp": 9,
  "domicilio": "Calle 123",
  "sector": "H",
  "ctrol_zona": 1001,
  "id_rec": 1,
  "documento": "",
  "descripcion_docto": "Cambio de domicilio",
  "usuario": 1
}

---

