# Casos de Uso - ABC_Recargos

**Categoría:** Form

## Caso de Uso 1: Alta de Recargo para un Nuevo Periodo

**Descripción:** El usuario desea agregar un nuevo recargo para el periodo 2024-07 con 2.5% de recargo y 1.5% de multa.

**Precondiciones:**
No existe un recargo para el periodo 2024-07.

**Pasos a seguir:**
1. El usuario accede a la página de Recargos.
2. Hace clic en 'Alta'.
3. Ingresa '2024-07' como periodo, 2.5 como % recargo y 1.5 como % multa.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
El recargo se agrega correctamente y aparece en la tabla.

**Datos de prueba:**
{ "aso_mes_recargo": "2024-07-01", "porc_recargo": 2.5, "porc_multa": 1.5 }

---

## Caso de Uso 2: Intento de Alta Duplicada

**Descripción:** El usuario intenta agregar un recargo para un periodo que ya existe.

**Precondiciones:**
Ya existe un recargo para el periodo 2024-07.

**Pasos a seguir:**
1. El usuario accede a la página de Recargos.
2. Hace clic en 'Alta'.
3. Ingresa '2024-07' como periodo, 3.0 como % recargo y 2.0 como % multa.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Ya existe un recargo para ese periodo.'

**Datos de prueba:**
{ "aso_mes_recargo": "2024-07-01", "porc_recargo": 3.0, "porc_multa": 2.0 }

---

## Caso de Uso 3: Eliminación de Recargo Existente

**Descripción:** El usuario elimina un recargo existente para el periodo 2024-07.

**Precondiciones:**
Existe un recargo para el periodo 2024-07.

**Pasos a seguir:**
1. El usuario selecciona el recargo de 2024-07 en la tabla.
2. Hace clic en 'Baja'.
3. Confirma la eliminación.

**Resultado esperado:**
El recargo desaparece de la tabla y el sistema muestra 'Recargo eliminado correctamente.'

**Datos de prueba:**
{ "aso_mes_recargo": "2024-07-01" }

---

