# Casos de Uso - funcion_abstencion

**Categoría:** Form

## Caso de Uso 1: Registrar una abstención de movimiento para una cuenta

**Descripción:** El usuario desea registrar que una cuenta catastral no puede realizar movimientos en un año y bimestre específico.

**Precondiciones:**
El usuario tiene permisos y conoce la cuenta, año y bimestre.

**Pasos a seguir:**
1. Ingresa a la página de Abstención de Movimientos.
2. Llena el formulario con la cuenta, año, bimestre y observación.
3. Presiona 'Agregar'.

**Resultado esperado:**
La abstención se registra y aparece en el listado.

**Datos de prueba:**
{ "cvecuenta": 12345, "anio": 2024, "bimestre": 2, "observacion": "Bloqueo temporal", "usuario": "admin" }

---

## Caso de Uso 2: Eliminar una abstención existente

**Descripción:** El usuario elimina una abstención previamente registrada.

**Precondiciones:**
Existe una abstención para la cuenta, año y bimestre.

**Pasos a seguir:**
1. Busca la cuenta en el buscador.
2. Ubica la abstención en el listado.
3. Presiona 'Eliminar'.

**Resultado esperado:**
La abstención desaparece del listado.

**Datos de prueba:**
{ "cvecuenta": 12345, "anio": 2024, "bimestre": 2, "usuario": "admin" }

---

## Caso de Uso 3: Consultar todas las abstenciones

**Descripción:** El usuario consulta el listado completo de abstenciones.

**Precondiciones:**
Existen abstenciones registradas.

**Pasos a seguir:**
1. Accede a la página de Abstención de Movimientos.
2. Visualiza el listado inicial.

**Resultado esperado:**
Se muestran todas las abstenciones ordenadas por fecha.

**Datos de prueba:**
{}

---

