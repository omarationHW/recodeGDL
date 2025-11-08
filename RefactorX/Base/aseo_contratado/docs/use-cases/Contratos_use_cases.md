# Casos de Uso - Contratos

**Categoría:** Form

## Caso de Uso 1: Consulta de Contratos Vigentes de Zona Centro

**Descripción:** El usuario desea ver todos los contratos vigentes cuyo tipo de aseo es Zona Centro.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página /contratos
2. Selecciona 'Zona Centro' en Tipo de Aseo
3. Selecciona 'Vigente' en Vigencia
4. Da clic en 'Buscar'

**Resultado esperado:**
Se muestra la lista de contratos vigentes de tipo Zona Centro.

**Datos de prueba:**
{ tipo: 'C', vigencia: 'V' }

---

## Caso de Uso 2: Exportar Contratos Hospitalarios Cancelados a Excel

**Descripción:** El usuario requiere exportar a Excel todos los contratos hospitalarios cancelados.

**Precondiciones:**
El usuario está autenticado y tiene permisos de exportación.

**Pasos a seguir:**
1. Accede a la página /contratos
2. Selecciona 'Hospitalario' en Tipo de Aseo
3. Selecciona 'Cancelado' en Vigencia
4. Da clic en 'Exportar Excel'

**Resultado esperado:**
Se descarga un archivo Excel con los contratos hospitalarios cancelados.

**Datos de prueba:**
{ tipo: 'H', vigencia: 'C' }

---

## Caso de Uso 3: Buscar Contrato Específico

**Descripción:** El usuario busca un contrato específico por número.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página /contratos
2. Ingresa el número de contrato en el campo de búsqueda avanzada
3. Da clic en 'Buscar'

**Resultado esperado:**
Se muestra el contrato solicitado si existe.

**Datos de prueba:**
{ contrato: 12345, tipo: 'T', vigencia: 'T' }

---

