# Test Plan: ConsRequerimientos - NULL Parameter Fix

## Problema Identificado
Cuando los campos opcionales `letra_local` y `bloque` están vacíos, se estaba enviando el valor "1" en lugar de `null`, causando que el SP no retornara resultados.

## Solución Implementada
Se agregó lógica robusta para convertir strings vacíos o con solo espacios a `null`:

```javascript
const letraLocal = (form.value.letra_local && form.value.letra_local.trim() !== '')
  ? form.value.letra_local.trim()
  : null
```

## Datos de Prueba Reales

Según la base de datos, estos son datos reales que deben funcionar:

### Caso 1: Búsqueda SIN letra ni bloque (debe retornar múltiples resultados)
- **Oficina:** 1
- **Mercado:** 2
- **Sección:** SS
- **Local:** 1
- **Letra:** (dejar vacío)
- **Bloque:** (dejar vacío)
- **Resultado esperado:** 2 locales encontrados
  - Local con letra='A'
  - Local con letra='B'

### Caso 2: Búsqueda CON letra específica (debe retornar 1 resultado)
- **Oficina:** 1
- **Mercado:** 2
- **Sección:** SS
- **Local:** 1
- **Letra:** A
- **Bloque:** (dejar vacío)
- **Resultado esperado:** 1 local encontrado (el que tiene letra='A')

### Caso 3: Búsqueda de local sin letra ni bloque
- **Oficina:** 1
- **Mercado:** 2
- **Sección:** SS
- **Local:** 2
- **Letra:** (dejar vacío)
- **Bloque:** (dejar vacío)
- **Resultado esperado:** 1 local encontrado (id_local=11258)

## Verificación en Consola del Navegador

Al realizar una búsqueda, debes ver en la consola del navegador:

```
=== DEBUG ConsRequerimientos.buscarLocales ===
Valores originales del formulario: { letra_local: "", bloque: "" }
Valores procesados: { letra_local: NULL, bloque: NULL }
Payload completo enviado al API: {
  "eRequest": {
    "Operacion": "sp_cons_requerimientos_buscar",
    "Base": "padron_licencias",
    "Parametros": [
      { "Nombre": "p_oficina", "Valor": 1 },
      { "Nombre": "p_num_mercado", "Valor": 2 },
      { "Nombre": "p_categoria", "Valor": 1 },
      { "Nombre": "p_seccion", "Valor": "SS" },
      { "Nombre": "p_local", "Valor": 1 },
      { "Nombre": "p_letra_local", "Valor": null },  ← Debe ser null, NO "1"
      { "Nombre": "p_bloque", "Valor": null }        ← Debe ser null, NO "1"
    ]
  }
}
```

## Pasos para Probar

1. **Abrir el módulo:** Navegar a "Consulta de Requerimientos"
2. **Abrir DevTools:** Presionar F12 y abrir la pestaña "Console"
3. **Llenar formulario:**
   - Recaudadora: 1
   - Mercado: 2
   - Sección: SS
   - Local: 1
   - Letra: (dejar vacío)
   - Bloque: (dejar vacío)
4. **Hacer clic en "Buscar"**
5. **Verificar en consola:** Que `p_letra_local` y `p_bloque` tengan valor `null`
6. **Verificar resultados:** Debe mostrar "Se encontraron 2 locales"

## Oficinas y Mercados Disponibles

Para referencia, estas son las oficinas con más datos:

| Oficina | Total Locales | Mercados Principales |
|---------|---------------|---------------------|
| 1       | 5,606         | 34 (2,893), 70 (563), 2 (61) |
| 3       | 2,952         | (verificar) |
| 5       | 2,008         | (verificar) |
| 2       | 1,376         | (verificar) |
| 4       | 1,379         | (verificar) |

## Valores que deben convertirse a NULL

Todos estos casos deben enviar `null` al API:
- Campo vacío: `""`
- Solo espacios: `"  "`
- Tab: `"\t"`
- No ingresado (valor inicial)

## Valores que NO deben convertirse a NULL

Estos deben enviarse tal cual:
- Letra válida: `"A"` → enviar `"A"`
- Número válido: `"1"` → enviar `"1"`
- Cualquier carácter: `"X"` → enviar `"X"`
