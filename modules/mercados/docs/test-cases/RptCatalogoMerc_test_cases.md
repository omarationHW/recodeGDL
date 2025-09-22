# Casos de Prueba: Catálogo de Mercados Municipales

## Caso 1: Alta de Mercado
- **Entrada:**
  - oficina: 2
  - num_mercado_nvo: 20
  - categoria: 1
  - descripcion: "Mercado San Juan"
  - cuenta_ingreso: 44502
  - cuenta_energia: 0
  - id_zona: 2
  - tipo_emision: "M"
  - usuario_id: 1
- **Acción:** createCatalogoMercado
- **Esperado:**
  - Respuesta: success: true
  - El mercado aparece en el listado

## Caso 2: Edición de Mercado
- **Entrada:**
  - oficina: 2
  - num_mercado_nvo: 20
  - categoria: 1
  - descripcion: "Mercado San Juan Actualizado"
  - cuenta_ingreso: 44503
  - cuenta_energia: 0
  - id_zona: 2
  - tipo_emision: "M"
  - usuario_id: 1
- **Acción:** updateCatalogoMercado
- **Esperado:**
  - Respuesta: success: true
  - El mercado muestra los datos actualizados

## Caso 3: Eliminación de Mercado
- **Entrada:**
  - oficina: 2
  - num_mercado_nvo: 20
- **Acción:** deleteCatalogoMercado
- **Esperado:**
  - Respuesta: success: true
  - El mercado ya no aparece en el listado

## Caso 4: Consulta de Listado
- **Entrada:**
  - (sin parámetros)
- **Acción:** getCatalogoMercados
- **Esperado:**
  - Respuesta: success: true
  - Se retorna un array de mercados

## Caso 5: Generación de Reporte
- **Entrada:**
  - (sin parámetros)
- **Acción:** getCatalogoMercadosReporte
- **Esperado:**
  - Respuesta: success: true
  - data.pdf_url contiene la URL del PDF

## Caso 6: Error por parámetros faltantes
- **Entrada:**
  - (parámetros incompletos)
- **Acción:** createCatalogoMercado
- **Esperado:**
  - Respuesta: success: false
  - Mensaje de error indicando parámetros faltantes
