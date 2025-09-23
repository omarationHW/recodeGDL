# Casos de Uso - LicenciaMicrogenerador

**Categoría:** Form

## Caso de Uso 1: Consulta de Licencia como Microgenerador

**Descripción:** El usuario consulta si una licencia está registrada como microgenerador.

**Precondiciones:**
La licencia existe y está vigente.

**Pasos a seguir:**
1. El usuario accede a la página de Licencia Microgenerador.
2. Selecciona 'Licencia' como tipo.
3. Ingresa el número de licencia.
4. Da clic en 'Consultar'.

**Resultado esperado:**
Se muestra la información de la licencia y el mensaje 'Ya existe como microgenerador' o 'No existe como microgenerador'.

**Datos de prueba:**
{ "tipo": "L", "licencia": 12345 }

---

## Caso de Uso 2: Alta de Licencia como Microgenerador

**Descripción:** El usuario registra una licencia como microgenerador.

**Precondiciones:**
La licencia existe, está vigente y no está registrada como microgenerador.

**Pasos a seguir:**
1. El usuario consulta la licencia como en el caso anterior.
2. Si el mensaje es 'No existe como microgenerador', da clic en 'Registrar como microgenerador'.

**Resultado esperado:**
El sistema muestra el mensaje 'Alta exitosa, Licencia registrada como microgenerador'.

**Datos de prueba:**
{ "tipo": "L", "id": 12345 }

---

## Caso de Uso 3: Cancelación de Licencia como Microgenerador

**Descripción:** El usuario cancela el registro de una licencia como microgenerador.

**Precondiciones:**
La licencia está registrada como microgenerador.

**Pasos a seguir:**
1. El usuario consulta la licencia.
2. Si el mensaje es 'Ya existe como microgenerador', da clic en 'Cancelar microgenerador'.

**Resultado esperado:**
El sistema muestra el mensaje 'Cancelación exitosa, Licencia cancelada como microgenerador'.

**Datos de prueba:**
{ "tipo": "L", "id": 12345 }

---

