# Casos de Uso - RNuevos

**Categoría:** Form

## Caso de Uso 1: Alta exitosa de un nuevo local

**Descripción:** El usuario registra un nuevo local/concesión con datos válidos y únicos.

**Precondiciones:**
No existe un local con el mismo número y letra.

**Pasos a seguir:**
1. El usuario accede a la página de Alta de Locales.
2. Llena todos los campos requeridos con datos válidos.
3. Presiona el botón 'Aplicar'.
4. El sistema valida que el control no exista y los datos sean correctos.
5. El sistema crea el registro y muestra mensaje de éxito.

**Resultado esperado:**
El local se registra correctamente y se muestra el mensaje 'Se ejecutó correctamente la creación del Local/Concesión'.

**Datos de prueba:**
{
  "numero": "101",
  "letra": "A",
  "concesionario": "JUAN PEREZ",
  "ubicacion": "RASTRO MUNICIPAL DE GUADALAJARA",
  "superficie": "25.5",
  "licencia": "1234567",
  "tipo_local": "INTERNO",
  "aso": "2024",
  "mes": "01"
}

---

## Caso de Uso 2: Intento de alta con número de local duplicado

**Descripción:** El usuario intenta registrar un local con un número y letra ya existentes.

**Precondiciones:**
Ya existe un local con número '101' y letra 'A'.

**Pasos a seguir:**
1. El usuario accede a la página de Alta de Locales.
2. Ingresa número '101' y letra 'A'.
3. Llena los demás campos y presiona 'Aplicar'.
4. El sistema detecta que el control ya existe.

**Resultado esperado:**
El sistema muestra el mensaje 'Ya existe LOCAL con este dato, intentalo de nuevo' y no crea el registro.

**Datos de prueba:**
{
  "numero": "101",
  "letra": "A",
  ...
}

---

## Caso de Uso 3: Validación de año de alta incorrecto

**Descripción:** El usuario intenta registrar un local con un año de alta inválido (ni actual ni anterior).

**Precondiciones:**
No existe el control ingresado.

**Pasos a seguir:**
1. El usuario accede a la página de Alta de Locales.
2. Ingresa un año de alta '2010'.
3. Llena los demás campos y presiona 'Aplicar'.
4. El sistema valida el año y rechaza la operación.

**Resultado esperado:**
El sistema muestra el mensaje 'Revisar el año de alta del LOCAL' y no crea el registro.

**Datos de prueba:**
{
  "numero": "102",
  "letra": "B",
  "aso": "2010",
  ...
}

---

