# Casos de Uso - sfrm_alta_ubicaciones

**Categoría:** Form

## Caso de Uso 1: Alta de ubicación tipo Cordon para contrato existente

**Descripción:** El usuario desea agregar una nueva ubicación de tipo 'Cordon' al contrato 123.

**Precondiciones:**
El usuario está autenticado y tiene permisos para agregar ubicaciones. El contrato 123 existe.

**Pasos a seguir:**
1. El usuario accede a la página de Alta de Ubicaciones.
2. Selecciona 'Cordon' como tipo.
3. Ingresa 'AV. PRINCIPAL' en Calle.
4. Ingresa 'CENTRO' en Colonia.
5. Ingresa '20' en Medida.
6. Selecciona 'NORTE' como Acera.
7. Ingresa 'CON 5 DE MAYO' en Intersección.
8. Ingresa '100' en A Partir de.
9. Selecciona 'NORTE' como Hacia.
10. Presiona 'Agregar'.

**Resultado esperado:**
La ubicación se agrega correctamente y se muestra el mensaje 'Alta de Ubicación realizada correctamente.'

**Datos de prueba:**
{
  "opc": 1,
  "contrato_id": 123,
  "tipo_esta": "C",
  "calle": "AV. PRINCIPAL",
  "colonia": "CENTRO",
  "extencion": 20,
  "acera": "N",
  "inter": "CON 5 DE MAYO",
  "apartir": 100,
  "hacia": "N",
  "usuario": 1
}

---

## Caso de Uso 2: Alta de ubicación tipo Bateria con datos mínimos

**Descripción:** El usuario agrega una ubicación de tipo 'Bateria' con los campos mínimos requeridos.

**Precondiciones:**
El usuario está autenticado. El contrato 456 existe.

**Pasos a seguir:**
1. Accede a la página de Alta de Ubicaciones.
2. Selecciona 'Bateria' como tipo.
3. Ingresa 'CALLE 2' en Calle.
4. Ingresa 'COLONIA 2' en Colonia.
5. Ingresa '10' en Medida.
6. Selecciona 'SUR' como Acera.
7. Ingresa 'CON JUAREZ' en Intersección.
8. Ingresa '50' en A Partir de.
9. Selecciona 'SUR' como Hacia.
10. Presiona 'Agregar'.

**Resultado esperado:**
La ubicación se agrega correctamente y se muestra el mensaje de éxito.

**Datos de prueba:**
{
  "opc": 1,
  "contrato_id": 456,
  "tipo_esta": "B",
  "calle": "CALLE 2",
  "colonia": "COLONIA 2",
  "extencion": 10,
  "acera": "S",
  "inter": "CON JUAREZ",
  "apartir": 50,
  "hacia": "S",
  "usuario": 2
}

---

## Caso de Uso 3: Intento de alta con campos obligatorios vacíos

**Descripción:** El usuario intenta agregar una ubicación sin llenar los campos obligatorios.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página de Alta de Ubicaciones.
2. Deja vacíos los campos Calle y Colonia.
3. Presiona 'Agregar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los campos son obligatorios.

**Datos de prueba:**
{
  "opc": 1,
  "contrato_id": 789,
  "tipo_esta": "C",
  "calle": "",
  "colonia": "",
  "extencion": 15,
  "acera": "O",
  "inter": "CON REFORMA",
  "apartir": 200,
  "hacia": "O",
  "usuario": 3
}

---

