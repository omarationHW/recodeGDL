# Casos de Uso - sfrm_prop_exclusivo

**Categoría:** Form

## Caso de Uso 1: Alta de Propietario Persona Física

**Descripción:** Registrar un nuevo propietario persona física con RFC único.

**Precondiciones:**
El RFC no debe existir en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de registro.
2. Llena los campos requeridos (sociedad: F, RFC, nombre, domicilio, etc).
3. Da clic en 'Aceptar'.
4. El sistema valida que el RFC no exista y guarda el registro.

**Resultado esperado:**
El registro es guardado exitosamente y se muestra el mensaje 'Fue dado de alta el registro.'

**Datos de prueba:**
{
  "sociedad": "F",
  "rfc": "XEXX010101000",
  "propietario": "MARIA LOPEZ",
  "domicilio": "CALLE 10 #100",
  "colonia": "CENTRO",
  "telefono": "5551234567",
  "celular": "5559876543",
  "email": "maria@mail.com"
}

---

## Caso de Uso 2: Edición de Propietario Persona Moral

**Descripción:** Editar los datos de un propietario existente (persona moral).

**Precondiciones:**
El propietario debe existir en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de edición con el ID del propietario.
2. El sistema carga los datos actuales.
3. El usuario modifica los campos requeridos.
4. Da clic en 'Aceptar'.
5. El sistema actualiza el registro.

**Resultado esperado:**
El registro es actualizado y se muestra el mensaje 'Cambio efectuado.'

**Datos de prueba:**
{
  "id": 2,
  "sociedad": "M",
  "rfc": "AAA010101AAA",
  "propietario": "EMPRESA XYZ SA DE CV",
  "domicilio": "AV. INDUSTRIAL 200",
  "colonia": "INDUSTRIAL",
  "telefono": "5551112233",
  "celular": "5553332211",
  "email": "contacto@xyz.com"
}

---

## Caso de Uso 3: Intento de Alta con RFC Duplicado

**Descripción:** Intentar registrar un propietario con un RFC que ya existe.

**Precondiciones:**
El RFC ya debe existir en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de registro.
2. Llena los campos con un RFC existente.
3. Da clic en 'Aceptar'.
4. El sistema valida y detecta el duplicado.

**Resultado esperado:**
El sistema muestra el mensaje 'Este RFC ya está registrado.' y no guarda el registro.

**Datos de prueba:**
{
  "sociedad": "F",
  "rfc": "TOHI691108LFA",
  "propietario": "JUAN PEREZ",
  "domicilio": "AV. PRINCIPAL 123",
  "colonia": "CENTRO",
  "telefono": "5551234567",
  "celular": "5559876543",
  "email": "juan@mail.com"
}

---

