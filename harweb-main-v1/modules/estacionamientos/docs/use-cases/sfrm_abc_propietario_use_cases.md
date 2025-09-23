# Casos de Uso - sfrm_abc_propietario

**Categoría:** Form

## Caso de Uso 1: Registro exitoso de persona física

**Descripción:** Un usuario registra una persona física con un RFC no existente.

**Precondiciones:**
El usuario está autenticado y el RFC no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de registro.
2. Ingresa un RFC válido (mínimo 9 caracteres, no existente).
3. Marca la casilla como Persona Física.
4. Ingresa nombre, apellidos y opcionalmente IFE y dirección.
5. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de éxito y limpia el formulario.

**Datos de prueba:**
{
  "rfc": "XEXX010101AAA",
  "sociedad": "F",
  "nombre": "JUAN PEREZ",
  "ap_pater": "PEREZ",
  "ap_mater": "LOPEZ",
  "ife": "123456789012345",
  "direccion": "AV. PRINCIPAL 123",
  "usu_inicial": 1
}

---

## Caso de Uso 2: Intento de registro con RFC duplicado

**Descripción:** El usuario intenta registrar un RFC que ya existe.

**Precondiciones:**
El RFC ya existe en la tabla ta14_personas.

**Pasos a seguir:**
1. El usuario accede a la página de registro.
2. Ingresa un RFC existente.
3. Completa el resto del formulario.
4. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de error indicando que el RFC ya está registrado.

**Datos de prueba:**
{
  "rfc": "TOHI691108LFA",
  "sociedad": "M",
  "nombre": "EMPRESA SA DE CV",
  "ap_pater": "",
  "ap_mater": "",
  "ife": "",
  "direccion": "",
  "usu_inicial": 1
}

---

## Caso de Uso 3: Cancelación de registro

**Descripción:** El usuario decide cancelar el registro antes de guardar.

**Precondiciones:**
El usuario está en la página de registro y ha llenado algunos campos.

**Pasos a seguir:**
1. El usuario llena algunos campos del formulario.
2. Presiona el botón 'Cancelar'.

**Resultado esperado:**
El sistema limpia el formulario y muestra mensaje de operación cancelada.

**Datos de prueba:**
{
  "rfc": "ABCD123456XYZ",
  "sociedad": "F",
  "nombre": "MARIA GARCIA",
  "ap_pater": "GARCIA",
  "ap_mater": "RAMIREZ",
  "ife": "",
  "direccion": "",
  "usu_inicial": 1
}

---

