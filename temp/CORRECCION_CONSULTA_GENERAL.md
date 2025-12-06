# CORRECCIÓN: CONSULTA GENERAL - Error en la búsqueda

## PROBLEMA IDENTIFICADO

El componente **ConsultaGeneral.vue** estaba usando el formato incorrecto para validar la respuesta de la API genérica.

### Formato INCORRECTO (anterior):
```javascript
if (response.data.success && response.data.data) {
  locales.value = response.data.data
}
```

### Formato CORRECTO (después):
```javascript
if (response.data.eResponse && response.data.eResponse.success === true) {
  locales.value = response.data.eResponse.data.result || []
}
```

## CORRECCIONES APLICADAS

### 1. Función `buscarLocal()` (líneas 627-646)
- ✅ Cambió `response.data.success` → `response.data.eResponse.success`
- ✅ Cambió `response.data.data` → `response.data.eResponse.data.result`
- ✅ Corregido manejo de errores en `catch`

### 2. Función `cargarDatosDetalle()` (líneas 697-746)
- ✅ Corregida validación de respuesta para **adeudos**
- ✅ Corregida validación de respuesta para **pagos**
- ✅ Corregida validación de respuesta para **requerimientos**
- ✅ Corregido orden de parámetros en `showToast()`

## COMBINACIONES DE FILTROS VÁLIDAS PARA PRUEBAS

### OPCIÓN 1 - Local con letra
```
Recaudadora: 1
Mercado: 2
Categoría: 1
Sección: SS
Local: 1
Letra: A
```
**Resultado:** RODRIGUEZ LIRA DIANA PATRICIA

### OPCIÓN 2 - Local con letra B
```
Recaudadora: 1
Mercado: 2
Categoría: 1
Sección: SS
Local: 1
Letra: B
```
**Resultado:** SANCHEZ BARRETO RICARDO

### OPCIÓN 3 - Local sin letra
```
Recaudadora: 1
Mercado: 2
Categoría: 1
Sección: SS
Local: 2
```
**Resultado:** CASILLAS PLASCENCIA ISRAEL

### OPCIÓN 4 - Local con domicilio
```
Recaudadora: 1
Mercado: 2
Categoría: 1
Sección: SS
Local: 3
```
**Resultado:** VELOZ GONZALEZ ANGELICA MARIA DEL ROSARIO

## VERIFICACIÓN DEL SP

El stored procedure `sp_consulta_general_buscar` fue verificado directamente en la BD y está funcionando correctamente:

```sql
✅ SP encontrado en schema: public
✅ Parámetros correctos: p_oficina, p_num_mercado, p_categoria, p_seccion, p_local, p_letra_local, p_bloque
✅ Retorna datos correctamente
```

## ESTADÍSTICAS DE LA BD

- **Total locales:** 13,320
- **Oficinas disponibles:** 1, 2, 3, 4, 5
- **Mercados distintos:** 98
- **Secciones disponibles:** 01, 02, EA, PS, SS, T1, T2
- **Categorías:** 1, 2, 3

## ARCHIVOS MODIFICADOS

- `RefactorX/FrontEnd/src/views/modules/mercados/ConsultaGeneral.vue`

## ARCHIVOS DE VERIFICACIÓN CREADOS

- `temp/buscar_datos_consulta_general.php` - Búsqueda de datos de prueba
- `temp/verificar_sp_consulta_general.php` - Verificación del SP
- `temp/test_api_consulta_general.php` - Test de la API (pendiente servidor)

## RESULTADO ESPERADO

✅ El componente ahora debería funcionar correctamente
✅ La búsqueda debe retornar datos sin errores
✅ Los datos deben mostrarse en la tabla correctamente
✅ El modal de detalle debe cargar adeudos, pagos y requerimientos sin errores

## NOTA IMPORTANTE

El formato de respuesta de la API genérica es consistente con otros componentes como:
- `AdeEnergiaGrl.vue`
- `DatosIndividuales.vue`
- `DatosRequerimientos.vue`

Todos usan el formato: `response.data.eResponse.data.result`
