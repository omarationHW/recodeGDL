## Casos de Prueba RBaja

### Caso 1: Baja exitosa de local sin adeudos
- **Entrada:**
  - Número: 123
  - Letra: A
  - Año: 2024
  - Mes: 06
- **Pasos:**
  1. Buscar local.
  2. Verificar que existe y está vigente.
  3. Verificar que no tiene adeudos pasados ni posteriores.
  4. Aplicar baja.
- **Esperado:**
  - Mensaje de éxito: "Se ejecutó correctamente la Cancelación del Local/Concesión"

### Caso 2: Baja rechazada por adeudos vigentes
- **Entrada:**
  - Número: 456
  - Letra: B
  - Año: 2024
  - Mes: 06
- **Pasos:**
  1. Buscar local.
  2. Verificar que existe y está vigente.
  3. Verificar que tiene adeudos pasados o posteriores.
  4. Intentar aplicar baja.
- **Esperado:**
  - Mensaje de error: "NO ES POSIBLE DARLO DE BAJA PUES TIENE ADEUDOS VIGENTES O POSTERIORES CON OTRO STATUS, intentalo de nuevo"

### Caso 3: Baja rechazada por local inexistente
- **Entrada:**
  - Número: 999
  - Letra: Z
- **Pasos:**
  1. Buscar local.
- **Esperado:**
  - Mensaje de error: "No existe LOCAL con este dato, intentalo de nuevo"
