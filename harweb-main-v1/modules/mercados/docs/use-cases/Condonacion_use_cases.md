# Casos de Uso - Condonacion

**Categoría:** Form

## Caso de Uso 1: Condonar Adeudos de un Local

**Descripción:** El usuario busca un local, selecciona adeudos y los condona con un número de oficio.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de condonación.

**Pasos a seguir:**
- Ingresar los datos del local (oficina, mercado, categoría, sección, local, letra, bloque)
- Presionar 'Buscar'
- Visualizar los datos del local
- Presionar 'Listar Adeudos'
- Seleccionar uno o varios adeudos
- Ingresar el número de oficio
- Presionar 'Condonar Seleccionados'

**Resultado esperado:**
Los adeudos seleccionados desaparecen de la lista de adeudos y aparecen en la lista de condonados.

**Datos de prueba:**
{
  "oficina": 1,
  "num_mercado": 2,
  "categoria": 1,
  "seccion": "SS",
  "local": 1,
  "letra_local": null,
  "bloque": null,
  "oficio": "ABC/2024/001"
}

---

## Caso de Uso 2: Deshacer una Condonación

**Descripción:** El usuario selecciona condonaciones previas y las revierte, regresando los adeudos a la lista de adeudos.

**Precondiciones:**
Debe existir al menos una condonación previa para el local.

**Pasos a seguir:**
- Buscar el local
- Presionar 'Listar Condonados'
- Seleccionar uno o varios condonados
- Presionar 'Deshacer Condonación'

**Resultado esperado:**
Los adeudos seleccionados desaparecen de la lista de condonados y reaparecen en la lista de adeudos.

**Datos de prueba:**
{
  "id_local": 1,
  "condonados": [
    { "id_cancelacion": 10, "id_local": 1, "axo": 2023, "periodo": 5, "importe": 100.00 }
  ]
}

---

## Caso de Uso 3: Validación de Número de Oficio

**Descripción:** El usuario intenta condonar adeudos sin ingresar el número de oficio.

**Precondiciones:**
El usuario debe haber seleccionado al menos un adeudo.

**Pasos a seguir:**
- Buscar el local
- Listar adeudos
- Seleccionar uno o varios adeudos
- Dejar el campo de oficio vacío
- Presionar 'Condonar Seleccionados'

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el número de oficio es obligatorio.

**Datos de prueba:**
{
  "id_local": 1,
  "adeudos": [ { "axo": 2023, "periodo": 5, "importe": 100.00 } ],
  "oficio": ""
}

---

