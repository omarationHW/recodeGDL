# Casos de Uso - GAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta de Estado de Cuenta por Expediente

**Descripción:** El usuario consulta el estado de cuenta de un concesionario usando el número de expediente.

**Precondiciones:**
El usuario está autenticado y conoce el número de expediente válido.

**Pasos a seguir:**
1. Ingresa a la página de Estado de Cuenta.
2. Selecciona 'Por Expediente'.
3. Ingresa el número de expediente (ej: 12345).
4. Selecciona 'Periodos Vencidos'.
5. Hace clic en 'Buscar'.

**Resultado esperado:**
Se muestra la información del concesionario y el detalle de adeudos vencidos.

**Datos de prueba:**
{ "tipoBusqueda": "expediente", "numExpediente": "12345", "periodo": "vencidos" }

---

## Caso de Uso 2: Consulta de Estado de Cuenta por Local con Letra

**Descripción:** El usuario consulta el estado de cuenta usando número de local y letra.

**Precondiciones:**
El usuario está autenticado y conoce el número y letra de local válidos.

**Pasos a seguir:**
1. Ingresa a la página de Estado de Cuenta.
2. Selecciona 'Por Local'.
3. Ingresa número de local (ej: 12) y letra (ej: B).
4. Selecciona 'Otro Periodo', ingresa año (2023) y mes (03).
5. Hace clic en 'Buscar'.

**Resultado esperado:**
Se muestra la información del local y el detalle de adeudos para el periodo seleccionado.

**Datos de prueba:**
{ "tipoBusqueda": "local", "numLocal": "12", "letraLocal": "B", "periodo": "otro", "anio": "2023", "mes": "03" }

---

## Caso de Uso 3: Intento de Consulta con Datos Inválidos

**Descripción:** El usuario intenta consultar un expediente inexistente.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Ingresa a la página de Estado de Cuenta.
2. Selecciona 'Por Expediente'.
3. Ingresa un número de expediente inexistente (ej: 99999).
4. Hace clic en 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que no existe registro con ese dato.

**Datos de prueba:**
{ "tipoBusqueda": "expediente", "numExpediente": "99999", "periodo": "vencidos" }

---

