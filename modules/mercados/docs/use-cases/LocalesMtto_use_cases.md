# Casos de Uso - LocalesMtto

**Categoría:** Form

## Caso de Uso 1: Alta de Local Nuevo

**Descripción:** Un usuario desea dar de alta un nuevo local en un mercado específico.

**Precondiciones:**
El usuario tiene permisos y conoce los datos del local. El local no existe.

**Pasos a seguir:**
1. El usuario ingresa a la página de Altas de Locales.
2. Selecciona la recaudadora, mercado, categoría, sección, local, letra y bloque.
3. Presiona 'Buscar'.
4. El sistema indica que el local no existe.
5. El usuario llena los datos: nombre, giro, sector, domicilio, superficie, zona, descripción, clave cuota, fecha alta, número memo.
6. Presiona 'Alta Local'.
7. El sistema valida y da de alta el local, movimientos y adeudos.

**Resultado esperado:**
El local se da de alta correctamente y aparece en la base de datos.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado": 10,
  "categoria": 1,
  "seccion": "SS",
  "local": 123,
  "letra_local": "A",
  "bloque": "B",
  "nombre": "JUAN PEREZ",
  "giro": 5,
  "sector": "J",
  "domicilio": "CALLE 123",
  "zona": 1,
  "descripcion_local": "PUESTO DE FRUTAS",
  "superficie": 12.5,
  "fecha_alta": "2024-06-01",
  "clave_cuota": 1001,
  "numero_memo": 456,
  "vigencia": "A",
  "id_usuario": 1,
  "axo": 2024
}

---

## Caso de Uso 2: Intento de Alta de Local Existente

**Descripción:** El usuario intenta dar de alta un local que ya existe.

**Precondiciones:**
El local ya existe en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa los datos de un local existente y presiona 'Buscar'.
2. El sistema indica que el local ya existe.
3. El usuario no puede continuar con el alta.

**Resultado esperado:**
El sistema bloquea el alta y muestra mensaje de error.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado": 10,
  "categoria": 1,
  "seccion": "SS",
  "local": 123,
  "letra_local": "A",
  "bloque": "B"
}

---

## Caso de Uso 3: Validación de Campos Obligatorios

**Descripción:** El usuario omite campos obligatorios y trata de dar de alta un local.

**Precondiciones:**
El usuario está en el formulario de alta.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'nombre' y presiona 'Alta Local'.
2. El sistema valida y muestra mensaje de error.

**Resultado esperado:**
El sistema no permite el alta y muestra el mensaje 'The nombre field is required.'

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado": 10,
  "categoria": 1,
  "seccion": "SS",
  "local": 124,
  "letra_local": "B",
  "bloque": "C",
  "nombre": "",
  "giro": 5,
  "sector": "J",
  "domicilio": "CALLE 123",
  "zona": 1,
  "descripcion_local": "PUESTO DE FRUTAS",
  "superficie": 12.5,
  "fecha_alta": "2024-06-01",
  "clave_cuota": 1001,
  "numero_memo": 456,
  "vigencia": "A",
  "id_usuario": 1,
  "axo": 2024
}

---

