# Casos de Uso - Propuestatab

**Categoría:** Form

## Caso de Uso 1: Consulta de Cuenta Histórica

**Descripción:** El usuario consulta la información histórica de una cuenta catastral.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el número de cuenta.

**Pasos a seguir:**
1. El usuario accede a la página /propuestatab
2. Ingresa el número de cuenta catastral
3. Presiona 'Buscar'
4. El sistema muestra los datos principales de la cuenta

**Resultado esperado:**
Se muestran los datos de la cuenta, incluyendo ubicación, valores, régimen y observaciones.

**Datos de prueba:**
cvecuenta: 123456

---

## Caso de Uso 2: Visualización de Régimen de Propiedad

**Descripción:** El usuario revisa el régimen de propiedad de la cuenta consultada.

**Precondiciones:**
El usuario ya realizó una búsqueda de cuenta.

**Pasos a seguir:**
1. El usuario observa la sección 'Régimen de Propiedad'
2. El sistema muestra la tabla con los propietarios y porcentajes

**Resultado esperado:**
Se visualiza la lista de propietarios, porcentajes y calidades.

**Datos de prueba:**
cvecuenta: 123456

---

## Caso de Uso 3: Consulta de Observaciones AS-400

**Descripción:** El usuario consulta las observaciones AS-400 asociadas a la cuenta.

**Precondiciones:**
El usuario ya realizó una búsqueda de cuenta.

**Pasos a seguir:**
1. El usuario observa la sección 'Observaciones AS-400'
2. El sistema muestra la tabla de observaciones

**Resultado esperado:**
Se visualizan las observaciones AS-400 correspondientes.

**Datos de prueba:**
recaud: 1, urbrus: 'U', cuenta: 123456

---

