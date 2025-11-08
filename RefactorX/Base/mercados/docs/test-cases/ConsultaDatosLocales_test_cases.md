# Casos de Prueba - ConsultaDatosLocales

## Caso 1: Búsqueda por filtros completos
- **Entrada**: oficina=1, num_mercado=12, categoria=2, seccion='A', local=101, letra_local='B', bloque='C'
- **Acción**: POST /api/execute { action: 'buscarLocales', params: {...} }
- **Resultado esperado**: Lista de locales que cumplen exactamente esos filtros.

## Caso 2: Búsqueda por nombre parcial
- **Entrada**: nombre='JUAN'
- **Acción**: POST /api/execute { action: 'buscarPorNombre', params: { nombre: 'JUAN' } }
- **Resultado esperado**: Lista de locales cuyo nombre inicia con 'JUAN'.

## Caso 3: Consulta individual
- **Entrada**: id_local=123
- **Acción**: POST /api/execute { action: 'getLocalIndividual', params: { id_local: 123 } }
- **Resultado esperado**: Objeto con todos los datos del local 123.

## Caso 4: Catálogos
- **Entrada**: action: 'getCatalogos'
- **Acción**: POST /api/execute { action: 'getCatalogos' }
- **Resultado esperado**: Listado de recaudadoras y secciones.

## Caso 5: Mercados por oficina
- **Entrada**: oficina=1
- **Acción**: POST /api/execute { action: 'getMercadosPorOficina', params: { oficina: 1 } }
- **Resultado esperado**: Lista de mercados de la oficina 1.
