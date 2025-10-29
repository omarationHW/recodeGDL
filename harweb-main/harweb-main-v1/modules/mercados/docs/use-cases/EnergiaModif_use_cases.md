# Casos de Uso - EnergiaModif

**Categoría:** Form

## Caso de Uso 1: Modificación de cantidad de energía para un local vigente

**Descripción:** El usuario busca un local vigente y modifica la cantidad de kilowhatts.

**Precondiciones:**
El local existe, tiene registro de energía vigente, el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario ingresa los datos del local y selecciona 'Cambio de Datos Generales'.
2. Presiona 'Buscar'.
3. El sistema muestra los datos actuales de energía.
4. El usuario cambia el valor de 'Cantidad' y presiona 'Modificar'.

**Resultado esperado:**
El registro de energía se actualiza, se inserta en historial, los adeudos se recalculan si aplica.

**Datos de prueba:**
{
  "oficina": 1,
  "num_mercado": 34,
  "categoria": 1,
  "seccion": "SS",
  "local": 1202,
  "letra_local": null,
  "bloque": null,
  "movimiento": "C",
  "cantidad": 150.5
}

---

## Caso de Uso 2: Baja total de energía para un local

**Descripción:** El usuario da de baja el registro de energía de un local.

**Precondiciones:**
El local existe, tiene registro de energía vigente.

**Pasos a seguir:**
1. El usuario ingresa los datos del local y selecciona 'Baja Total'.
2. Ingresa periodo de baja (año y mes).
3. Presiona 'Buscar' y luego 'Modificar'.

**Resultado esperado:**
El registro de energía se marca como baja, los adeudos posteriores al periodo de baja se eliminan.

**Datos de prueba:**
{
  "oficina": 1,
  "num_mercado": 34,
  "categoria": 1,
  "seccion": "SS",
  "local": 1202,
  "letra_local": null,
  "bloque": null,
  "movimiento": "B",
  "periodo_baja_axo": 2024,
  "periodo_baja_mes": 6
}

---

## Caso de Uso 3: Cambio de cuota de energía para un local

**Descripción:** El usuario realiza un cambio de cuota (cantidad) para un local y actualiza los adeudos en el rango correspondiente.

**Precondiciones:**
El local existe, tiene registro de energía vigente.

**Pasos a seguir:**
1. El usuario ingresa los datos del local y selecciona 'Cambio de Cuota'.
2. Ingresa periodo de baja (año y mes) para el rango de actualización.
3. Cambia el valor de 'Cantidad'.
4. Presiona 'Modificar'.

**Resultado esperado:**
Los adeudos en el rango especificado se actualizan con la nueva cantidad.

**Datos de prueba:**
{
  "oficina": 1,
  "num_mercado": 34,
  "categoria": 1,
  "seccion": "SS",
  "local": 1202,
  "letra_local": null,
  "bloque": null,
  "movimiento": "D",
  "periodo_baja_axo": 2024,
  "periodo_baja_mes": 3,
  "cantidad": 200.0
}

---

