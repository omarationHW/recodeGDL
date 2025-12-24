# Menu

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Módulo de Adeudos de Energía Eléctrica

## Descripción General
Este módulo permite consultar, visualizar y exportar el listado de adeudos de energía eléctrica por oficina, mercado, año y mes. Incluye la visualización de los meses de adeudo por local y la exportación a Excel.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js independiente como página completa.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **API**: Unificada, patrón eRequest/eResponse.

## Endpoints y Acciones
- `/api/execute` (POST)
  - `eRequest.action = getOficinas` → Lista de oficinas recaudadoras
  - `eRequest.action = getMercadosByOficina` → Mercados por oficina
  - `eRequest.action = getAdeudosEnergia` → Listado de adeudos de energía
  - `eRequest.action = getMesesAdeudoEnergia` → Meses de adeudo por local
  - `eRequest.action = exportExcel` → Exportación a Excel (placeholder)

## Stored Procedures
- `sp_get_adeudos_energia(oficina, mercado, axo, mes)`
- `sp_get_meses_adeudo_energia(id_energia, axo, mes)`

## Flujo de Datos
1. El frontend solicita oficinas → backend responde.
2. El usuario selecciona oficina, solicita mercados → backend responde.
3. El usuario selecciona filtros y consulta adeudos → backend ejecuta SP y responde.
4. El usuario puede ver meses de adeudo por local → backend ejecuta SP y responde.
5. El usuario puede exportar a Excel (implementación futura).

## Validaciones
- Todos los campos de filtro son obligatorios.
- El año debe estar en rango válido (ej. 1994-2999).
- El mes debe estar entre 1 y 12.

## Seguridad
- El endpoint debe estar protegido por autenticación Laravel (middleware `auth:api` recomendado).
- Validar y sanitizar todos los parámetros recibidos.

## Consideraciones de Migración
- Los queries Delphi fueron convertidos a stored procedures PostgreSQL.
- El frontend Delphi fue migrado a Vue.js como página independiente.
- El backend Delphi fue migrado a Laravel Controller.

## Exportación a Excel
- Puede implementarse usando Laravel Excel o similar.
- El frontend puede descargar el archivo generado por el backend.

## Errores y Manejo de Excepciones
- Todos los errores se devuelven en el campo `eResponse.error`.
- Los logs de errores se almacenan en el log de Laravel.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser extendidos para nuevos reportes.


## Casos de Uso

# Casos de Uso - Menu

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Energía por Oficina y Mercado

**Descripción:** El usuario desea consultar todos los adeudos de energía eléctrica para una oficina y mercado específicos en un año y mes determinados.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de consulta.

**Pasos a seguir:**
[
  "El usuario accede a la página de Adeudos de Energía.",
  "Selecciona la oficina recaudadora de la lista.",
  "Selecciona el mercado correspondiente.",
  "Ingresa el año y el mes de consulta.",
  "Presiona el botón 'Buscar'."
]

**Resultado esperado:**
Se muestra una tabla con los adeudos de energía eléctrica para los locales del mercado seleccionado en el periodo indicado.

**Datos de prueba:**
{
  "oficina": 3,
  "mercado": 15,
  "axo": 2024,
  "mes": 6
}

---

## Caso de Uso 2: Visualización de Meses de Adeudo por Local

**Descripción:** El usuario desea ver el detalle de los meses de adeudo de energía eléctrica para un local específico.

**Precondiciones:**
El usuario debe haber realizado una consulta de adeudos y tener la tabla de resultados visible.

**Pasos a seguir:**
[
  "El usuario localiza el local de interés en la tabla de adeudos.",
  "Presiona el botón 'Ver' en la columna 'Periodo de Adeudo' correspondiente al local.",
  "Se abre un modal con el detalle de los meses y montos adeudados."
]

**Resultado esperado:**
El modal muestra una lista de meses y los importes adeudados para el local seleccionado.

**Datos de prueba:**
{
  "id_energia": 12345,
  "axo": 2024,
  "mes": 6
}

---

## Caso de Uso 3: Exportación de Adeudos a Excel

**Descripción:** El usuario desea exportar el listado de adeudos de energía eléctrica a un archivo Excel.

**Precondiciones:**
El usuario debe haber realizado una consulta de adeudos y tener resultados visibles.

**Pasos a seguir:**
[
  "El usuario presiona el botón 'Exportar a Excel'.",
  "El sistema genera el archivo Excel y lo descarga al equipo del usuario."
]

**Resultado esperado:**
El usuario obtiene un archivo Excel con el listado de adeudos consultados.

**Datos de prueba:**
{
  "oficina": 3,
  "mercado": 15,
  "axo": 2024,
  "mes": 6
}

---



## Casos de Prueba

# Casos de Prueba: Adeudos de Energía Eléctrica

## Caso 1: Consulta exitosa de adeudos
- **Entrada:** oficina=3, mercado=15, axo=2024, mes=6
- **Acción:** getAdeudosEnergia
- **Esperado:** Respuesta contiene lista de adeudos, sin error.

## Caso 2: Consulta con oficina inexistente
- **Entrada:** oficina=99, mercado=15, axo=2024, mes=6
- **Acción:** getAdeudosEnergia
- **Esperado:** Respuesta contiene lista vacía o error indicando oficina no encontrada.

## Caso 3: Consulta con parámetros faltantes
- **Entrada:** oficina=3, mercado=null, axo=2024, mes=6
- **Acción:** getAdeudosEnergia
- **Esperado:** Respuesta contiene error de validación.

## Caso 4: Visualización de meses de adeudo
- **Entrada:** id_energia=12345, axo=2024, mes=6
- **Acción:** getMesesAdeudoEnergia
- **Esperado:** Respuesta contiene lista de meses y montos, sin error.

## Caso 5: Exportación a Excel
- **Entrada:** oficina=3, mercado=15, axo=2024, mes=6
- **Acción:** exportExcel
- **Esperado:** Respuesta contiene mensaje de éxito o archivo descargable.

## Caso 6: Seguridad - usuario no autenticado
- **Entrada:** Sin token de autenticación
- **Acción:** getAdeudosEnergia
- **Esperado:** Respuesta HTTP 401 Unauthorized.



